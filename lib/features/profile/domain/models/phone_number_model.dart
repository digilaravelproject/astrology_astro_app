class PhoneNumberModel {
  final int id;
  final int astrologerId;
  final String countryCode;
  final String phone;
  final bool isVerified;
  final bool isDefault;
  final String? otp;
  final String? otpExpiresAt;
  final String? otpVerifiedAt;
  final String createdAt;
  final String updatedAt;

  PhoneNumberModel({
    required this.id,
    required this.astrologerId,
    required this.countryCode,
    required this.phone,
    required this.isVerified,
    required this.isDefault,
    this.otp,
    this.otpExpiresAt,
    this.otpVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PhoneNumberModel.fromJson(Map<String, dynamic> json) {
    return PhoneNumberModel(
      id: json['id'] ?? 0,
      astrologerId: json['astrologer_id'] ?? 0,
      countryCode: json['country_code'] ?? '+91',
      phone: json['phone'] ?? '',
      isVerified: json['is_verified'] ?? false,
      isDefault: json['is_default'] ?? false,
      otp: json['otp'],
      otpExpiresAt: json['otp_expires_at'],
      otpVerifiedAt: json['otp_verified_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'astrologer_id': astrologerId,
      'country_code': countryCode,
      'phone': phone,
      'is_verified': isVerified,
      'is_default': isDefault,
      'otp': otp,
      'otp_expires_at': otpExpiresAt,
      'otp_verified_at': otpVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
