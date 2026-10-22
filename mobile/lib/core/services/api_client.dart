import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_service.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<String> _base() async {
    final custom = await StorageService.getBaseUrl();
    if (custom != null && custom.isNotEmpty) return custom;
    return ApiConfig.baseUrl;
  }

  /// Prefer a reachable API (local :5000, Docker :5001, or custom).
  Future<String> resolveHealthyBaseUrl() async {
    final custom = await StorageService.getBaseUrl();
    final candidates = <String>[
      if (custom != null && custom.isNotEmpty) custom,
      ApiConfig.baseUrl,
      if (!ApiConfig.baseUrl.contains(':5001'))
        ApiConfig.baseUrl.replaceFirst(':5000', ':5001'),
      if (!ApiConfig.baseUrl.contains(':5000'))
        ApiConfig.baseUrl.replaceFirst(':5001', ':5000'),
    ];

    for (final base in candidates.toSet()) {
      try {
        final root = base.replaceAll(RegExp(r'/api/?$'), '');
        final response = await _client
            .get(Uri.parse('$root${ApiConfig.health}'))
            .timeout(const Duration(seconds: 4));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          if (base != ApiConfig.baseUrl) {
            await StorageService.setBaseUrl(base);
            ApiConfig.baseUrl = base;
          }
          return base;
        }
      } catch (_) {}
    }
    return custom ?? ApiConfig.baseUrl;
  }

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await StorageService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    bool auth = true,
    Map<String, String>? query,
  }) async {
    final base = await _base();
    final uri = Uri.parse('$base$path').replace(queryParameters: query);
    final response = await _client
        .get(uri, headers: await _headers(auth: auth))
        .timeout(const Duration(seconds: 20));
    return _decode(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final base = await _base();
    final uri = Uri.parse('$base$path');
    final response = await _client
        .post(
          uri,
          headers: await _headers(auth: auth),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));
    return _decode(response);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final base = await _base();
    final uri = Uri.parse('$base$path');
    final response = await _client
        .patch(
          uri,
          headers: await _headers(auth: auth),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));
    return _decode(response);
  }

  /// Health is mounted at /health (not under /api).
  Future<bool> pingHealth() async {
    try {
      await resolveHealthyBaseUrl();
      final base = await _base();
      final root = base.replaceAll(RegExp(r'/api/?$'), '');
      final uri = Uri.parse('$root${ApiConfig.health}');
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 8));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic> body = {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) body = decoded;
    } catch (_) {
      body = {'success': false, 'message': response.body};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    throw ApiException(
      body['message']?.toString() ??
          'Request failed (${response.statusCode})',
      statusCode: response.statusCode,
    );
  }
}
