import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_service.dart';
import '../../data/models/user_model.dart';

class AuthService {
  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _headers([String? token]) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<String> _base() async {
    final custom = await StorageService.getBaseUrl();
    return custom ?? ApiConfig.baseUrl;
  }

  Future<AuthResponse> _decodeAuth(http.Response response) async {
    Map<String, dynamic> data = {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) data = decoded;
    } catch (_) {
      return AuthResponse.error(
        'Server returned ${response.statusCode}',
      );
    }

    final authResponse = AuthResponse.fromJson(data);
    if (authResponse.success &&
        authResponse.token != null &&
        authResponse.user != null) {
      await StorageService.saveAuthData(
        token: authResponse.token!,
        userId: authResponse.user!.id,
        role: authResponse.user!.role,
        name: authResponse.user!.fullName,
        phone: authResponse.user!.phoneNumber,
        email: authResponse.user!.email,
      );
    }
    return authResponse;
  }

  /// Normalize Ethiopian phone to E.164 (+251…).
  static String normalizePhone(String raw) {
    var digits = raw.replaceAll(RegExp(r'[\s\-()]'), '');
    if (digits.startsWith('+')) return digits;
    if (digits.startsWith('251')) return '+$digits';
    if (digits.startsWith('0')) digits = digits.substring(1);
    return '+251$digits';
  }

  /// Request OTP code for a phone number (existing user).
  Future<AuthResponse> sendOtp({required String phoneNumber}) async {
    try {
      final uri = Uri.parse('${await _base()}${ApiConfig.sendOtp}');
      final response = await _client
          .post(
            uri,
            headers: _headers(),
            body: jsonEncode({'phone_number': normalizePhone(phoneNumber)}),
          )
          .timeout(const Duration(seconds: 20));
      return AuthResponse.fromJson(_safeJson(response));
    } catch (e) {
      return AuthResponse.error('Network error requesting OTP: $e');
    }
  }

  /// Resend OTP (email or phone).
  Future<AuthResponse> resendOtp({String? phoneNumber, String? email}) async {
    try {
      final uri = Uri.parse('${await _base()}${ApiConfig.resendOtp}');
      final body = <String, dynamic>{};
      if (email != null && email.isNotEmpty) {
        body['email'] = email.trim().toLowerCase();
      } else if (phoneNumber != null && phoneNumber.isNotEmpty) {
        body['phone_number'] = normalizePhone(phoneNumber);
      }
      final response = await _client
          .post(uri, headers: _headers(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 20));
      return AuthResponse.fromJson(_safeJson(response));
    } catch (e) {
      return AuthResponse.error('Network error resending OTP: $e');
    }
  }

  /// Verify 6-digit OTP (phone or email).
  Future<AuthResponse> verifyOtp({
    String? phoneNumber,
    String? email,
    required String otpCode,
  }) async {
    try {
      final uri = Uri.parse('${await _base()}${ApiConfig.verifyOtp}');
      final body = <String, dynamic>{'otp_code': otpCode.trim()};
      if (email != null && email.isNotEmpty) {
        body['email'] = email.trim().toLowerCase();
      } else if (phoneNumber != null && phoneNumber.isNotEmpty) {
        body['phone_number'] = normalizePhone(phoneNumber);
      }

      final response = await _client
          .post(uri, headers: _headers(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 20));
      return _decodeAuth(response);
    } catch (e) {
      return AuthResponse.error('Network error verifying OTP: $e');
    }
  }

  /// Password login using phone or email.
  Future<AuthResponse> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final uri = Uri.parse('${await _base()}${ApiConfig.login}');
      final trimmed = identifier.trim();
      final isEmail = trimmed.contains('@');
      final payload = isEmail
          ? {'email': trimmed.toLowerCase(), 'password': password}
          : {
              'phone_number': normalizePhone(trimmed),
              'password': password,
            };

      final response = await _client
          .post(uri, headers: _headers(), body: jsonEncode(payload))
          .timeout(const Duration(seconds: 20));
      return _decodeAuth(response);
    } catch (e) {
      return AuthResponse.error('Network error during login: $e');
    }
  }

  /// Telebirr quick authentication for a registered phone.
  Future<AuthResponse> telebirrLogin({required String phoneNumber}) async {
    try {
      final uri = Uri.parse('${await _base()}${ApiConfig.telebirr}');
      final response = await _client
          .post(
            uri,
            headers: _headers(),
            body: jsonEncode({'phone_number': normalizePhone(phoneNumber)}),
          )
          .timeout(const Duration(seconds: 20));
      return _decodeAuth(response);
    } catch (e) {
      return AuthResponse.error('Network error during Telebirr auth: $e');
    }
  }

  /// Register a new user (from main).
  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? phoneNumber,
  }) async {
    try {
      final uri = Uri.parse('${await _base()}${ApiConfig.register}');
      final cleanPhone = normalizePhone(phoneNumber);
      final generatedEmail = email ??
          'user_${cleanPhone.replaceAll('+', '')}@habeshafreight.et';
      final generatedPass = password ?? 'HabeshaFreight2026!';

      final response = await _client
          .post(
            uri,
            headers: _headers(),
            body: jsonEncode({
              'full_name': fullName.trim(),
              'phone_number': cleanPhone,
              'email': generatedEmail.toLowerCase(),
              'password': generatedPass,
              'role': role,
            }),
          )
          .timeout(const Duration(seconds: 25));
      return AuthResponse.fromJson(_safeJson(response));
    } catch (e) {
      return AuthResponse.error('Network error during registration: $e');
    }
  }

  /// Current user profile (`GET /auth/me`).
  Future<UserModel?> getMe() async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) return null;

      final uri = Uri.parse('${await _base()}${ApiConfig.me}');
      final response = await _client
          .get(uri, headers: _headers(token))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 401 || response.statusCode == 403) {
        await StorageService.clearAuthData();
        return null;
      }
      if (response.statusCode != 200) return null;

      final body = _safeJson(response);
      if (body['success'] == true && body['data'] is Map) {
        final user = UserModel.fromJson(
          (body['data'] as Map).cast<String, dynamic>(),
        );
        await StorageService.saveAuthData(
          token: token,
          userId: user.id,
          role: user.role,
          name: user.fullName,
          phone: user.phoneNumber,
          email: user.email,
        );
        return user;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Logout — clears local session (and notifies backend).
  Future<void> logout() async {
    try {
      final token = await StorageService.getToken();
      final uri = Uri.parse('${await _base()}${ApiConfig.logout}');
      await _client
          .post(uri, headers: _headers(token))
          .timeout(const Duration(seconds: 8));
    } catch (_) {}
    await StorageService.clearAuthData();
  }

  Map<String, dynamic> _safeJson(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return {
      'success': false,
      'message': 'Request failed (${response.statusCode})',
    };
  }
}
