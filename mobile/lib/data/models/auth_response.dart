import 'user_model.dart';

class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final UserModel? user;
  final String? demoOtp;
  final bool requiresOtpVerification;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
    this.demoOtp,
    this.requiresOtpVerification = false,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    UserModel? user;
    String? token;
    String? demoOtp;

    if (json['data'] is Map<String, dynamic>) {
      final data = json['data'] as Map<String, dynamic>;
      token = data['token']?.toString();
      demoOtp = data['demo_otp']?.toString();

      if (data['user'] is Map<String, dynamic>) {
        user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      } else if (data['id'] != null) {
        user = UserModel.fromJson(data);
      }
    }

    return AuthResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      token: token,
      user: user,
      demoOtp: demoOtp,
      requiresOtpVerification: json['requires_otp_verification'] == true,
    );
  }

  factory AuthResponse.error(String message) {
    return AuthResponse(
      success: false,
      message: message,
    );
  }
}
