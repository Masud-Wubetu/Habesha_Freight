import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String _defaultBaseUrl() {
    if (kIsWeb) return 'http://localhost:5001/api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:5001/api';
    } catch (_) {}
    return 'http://localhost:5001/api';
  }

  // Active Base URL
  static String baseUrl = _defaultBaseUrl();

  // Authentication Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String sendOtp = '/auth/otp/send';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String telebirr = '/auth/telebirr';
  static const String me = '/auth/me';

  // Freight & Logistics Endpoints
  static const String loads = '/loads';
  static const String shipments = '/shipments';
  static const String vehicles = '/vehicles';

  // System & Health Endpoints
  static const String health = '/health';
}
