// ============================================================================
// AUTH & USER MODELS
// Consolidated authentication and user data models
// ============================================================================

class UserModel {
  final String id;
  final String fullName;
  final String? email;
  final String phoneNumber;
  final String role;
  final bool isVerified;
  final String kycStatus;
  final String status;

  UserModel({
    required this.id,
    required this.fullName,
    this.email,
    required this.phoneNumber,
    required this.role,
    this.isVerified = false,
    this.kycStatus = 'PENDING',
    this.status = 'ACTIVE',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      phoneNumber: json['phone_number']?.toString() ?? '',
      role: (json['role']?.toString() ?? 'SHIPPER').toUpperCase(),
      isVerified: json['is_verified'] == true,
      kycStatus: (json['kyc_status']?.toString() ?? 'PENDING').toUpperCase(),
      status: (json['status']?.toString() ?? 'ACTIVE').toUpperCase(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'role': role,
      'is_verified': isVerified,
      'kyc_status': kycStatus,
      'status': status,
    };
  }
}

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
