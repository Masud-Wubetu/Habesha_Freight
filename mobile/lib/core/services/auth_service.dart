import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_service.dart';
import '../../data/models/user_model.dart';

class AuthService {
  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _headers([String? token]) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Request OTP code for a phone number
  Future<AuthResponse> sendOtp({required String phoneNumber}) async {
    try {
      final customUrl = await StorageService.getBaseUrl();
      final base = customUrl ?? ApiConfig.baseUrl;
      final uri = Uri.parse('$base${ApiConfig.sendOtp}');

      final response = await _client.post(
        uri,
        headers: _headers(),
        body: jsonEncode({'phone_number': phoneNumber.trim()}),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);
      return AuthResponse.fromJson(data);
    } catch (e) {
      return AuthResponse.error('Network error requesting OTP: $e');
    }
  }

  /// Verify 6-digit OTP code sent to email or phone number
  Future<AuthResponse> verifyOtp({
    String? email,
    String? phoneNumber,
    required String otpCode,
  }) async {
    try {
      final customUrl = await StorageService.getBaseUrl();
      final base = customUrl ?? ApiConfig.baseUrl;
      final uri = Uri.parse('$base${ApiConfig.verifyOtp}');

      final Map<String, dynamic> payload = {
        'otp_code': otpCode.trim(),
      };
      if (email != null && email.trim().isNotEmpty) {
        payload['email'] = email.trim().toLowerCase();
      }
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
        payload['phone_number'] = phoneNumber.trim();
      }

      final response = await _client.post(
        uri,
        headers: _headers(),
        body: jsonEncode(payload),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);

      if (authResponse.success && authResponse.token != null && authResponse.user != null) {
        await StorageService.saveAuthData(
          token: authResponse.token!,
          userId: authResponse.user!.id,
          role: authResponse.user!.role,
          name: authResponse.user!.fullName,
          phone: authResponse.user!.phoneNumber,
        );
      }

      return authResponse;
    } catch (e) {
      return AuthResponse.error('Network error verifying OTP: $e');
    }
  }

  /// Resend OTP code to email or phone number
  Future<AuthResponse> resendOtp({
    String? email,
    String? phoneNumber,
  }) async {
    try {
      final customUrl = await StorageService.getBaseUrl();
      final base = customUrl ?? ApiConfig.baseUrl;
      final uri = Uri.parse('$base${ApiConfig.resendOtp}');

      final Map<String, dynamic> payload = {};
      if (email != null && email.trim().isNotEmpty) {
        payload['email'] = email.trim().toLowerCase();
      }
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
        payload['phone_number'] = phoneNumber.trim();
      }

      final response = await _client.post(
        uri,
        headers: _headers(),
        body: jsonEncode(payload),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);
      return AuthResponse.fromJson(data);
    } catch (e) {
      return AuthResponse.error('Network error resending OTP: $e');
    }
  }

  /// Password login using phone or email
  Future<AuthResponse> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final customUrl = await StorageService.getBaseUrl();
      final base = customUrl ?? ApiConfig.baseUrl;
      final uri = Uri.parse('$base${ApiConfig.login}');

      final isEmail = identifier.contains('@');
      final payload = isEmail
          ? {'email': identifier.trim(), 'password': password}
          : {'phone_number': identifier.trim(), 'password': password};

      final response = await _client.post(
        uri,
        headers: _headers(),
        body: jsonEncode(payload),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);

      if (authResponse.success && authResponse.token != null && authResponse.user != null) {
        await StorageService.saveAuthData(
          token: authResponse.token!,
          userId: authResponse.user!.id,
          role: authResponse.user!.role,
          name: authResponse.user!.fullName,
          phone: authResponse.user!.phoneNumber,
        );
      }

      return authResponse;
    } catch (e) {
      return AuthResponse.error('Network error during login: $e');
    }
  }

  /// Telebirr quick authentication
  Future<AuthResponse> telebirrLogin({required String phoneNumber}) async {
    try {
      final customUrl = await StorageService.getBaseUrl();
      final base = customUrl ?? ApiConfig.baseUrl;
      final uri = Uri.parse('$base${ApiConfig.telebirr}');

      final response = await _client.post(
        uri,
        headers: _headers(),
        body: jsonEncode({'phone_number': phoneNumber.trim()}),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);

      if (authResponse.success && authResponse.token != null && authResponse.user != null) {
        await StorageService.saveAuthData(
          token: authResponse.token!,
          userId: authResponse.user!.id,
          role: authResponse.user!.role,
          name: authResponse.user!.fullName,
          phone: authResponse.user!.phoneNumber,
        );
      }

      return authResponse;
    } catch (e) {
      return AuthResponse.error('Network error during Telebirr auth: $e');
    }
  }

  /// Register a new user with full name, email, and password
  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? phoneNumber,
  }) async {
    try {
      final customUrl = await StorageService.getBaseUrl();
      final base = customUrl ?? ApiConfig.baseUrl;
      final uri = Uri.parse('$base${ApiConfig.register}');

      final Map<String, dynamic> payload = {
        'full_name': fullName.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'role': role,
      };

      if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
        payload['phone_number'] = phoneNumber.replaceAll(RegExp(r'\s+'), '');
      }

      final response = await _client.post(
        uri,
        headers: _headers(),
        body: jsonEncode(payload),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);
      return AuthResponse.fromJson(data);
    } catch (e) {
      return AuthResponse.error('Network error during registration: $e');
    }
  }

  /// Get current user profile
  Future<UserModel?> getMe() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return null;

      final customUrl = await StorageService.getBaseUrl();
      final base = customUrl ?? ApiConfig.baseUrl;
      final uri = Uri.parse('$base${ApiConfig.me}');

      final response = await _client.get(uri, headers: _headers(token));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return UserModel.fromJson(body['data']);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      final token = await StorageService.getToken();
      final customUrl = await StorageService.getBaseUrl();
      final base = customUrl ?? ApiConfig.baseUrl;
      final uri = Uri.parse('$base/auth/logout');

      await _client.post(uri, headers: _headers(token));
    } catch (_) {}
    await StorageService.clearAuthData();
  }
}
