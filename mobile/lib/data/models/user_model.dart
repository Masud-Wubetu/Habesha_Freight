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
