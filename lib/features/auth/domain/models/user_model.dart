import 'dart:convert';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? city;
  final String? country;
  final String? profilePhoto;
  final String? gender;
  final String? dateOfBirth;
  final String? timeOfBirth;
  final String? placeOfBirth;
  final String? languages;
  final bool profileCompleted;
  final String userType;
  final String createdAt;
  final String updatedAt;
  final AstrologerModel? astrologer;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.city,
    this.country,
    this.profilePhoto,
    this.gender,
    this.dateOfBirth,
    this.timeOfBirth,
    this.placeOfBirth,
    this.languages,
    required this.profileCompleted,
    required this.userType,
    required this.createdAt,
    required this.updatedAt,
    this.astrologer,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      city: json['city'],
      country: json['country'],
      profilePhoto: json['profile_photo'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'],
      timeOfBirth: json['time_of_birth'],
      placeOfBirth: json['place_of_birth'],
      languages: json['languages'],
      profileCompleted: json['profile_completed'] == true || json['profile_completed'] == 1,
      userType: json['user_type'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      astrologer: json['astrologer'] != null 
          ? AstrologerModel.fromJson(json['astrologer']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'city': city,
      'country': country,
      'profile_photo': profilePhoto,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'time_of_birth': timeOfBirth,
      'place_of_birth': placeOfBirth,
      'languages': languages,
      'profile_completed': profileCompleted,
      'user_type': userType,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'astrologer': astrologer?.toJson(),
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  static UserModel? fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    return UserModel.fromJson(jsonDecode(jsonString));
  }
}

class AstrologerModel {
  final int id;
  final int userId;
  final int yearsOfExperience;
  final List<String> areasOfExpertise;
  final List<String> languages;
  final String? profilePhoto;
  final String? bio;
  final String? idProof;
  final String? certificate;
  final String? idProofNumber;
  final String? dateOfBirth;
  final String status;
  final bool isChatEnabled;
  final bool isCallEnabled;
  final bool isVideoCallEnabled;
  final String chatRate;
  final String callRate;
  final String videoCallRate;
  final bool po5Enabled;
  final String? po5UserRate;
  final String? po5AstrologerRate;
  final String? otpVerifiedAt;
  final String? otpExpiresAt;
  final String createdAt;
  final String updatedAt;

  AstrologerModel({
    required this.id,
    required this.userId,
    required this.yearsOfExperience,
    required this.areasOfExpertise,
    required this.languages,
    this.profilePhoto,
    this.bio,
    this.idProof,
    this.certificate,
    this.idProofNumber,
    this.dateOfBirth,
    required this.status,
    required this.isChatEnabled,
    required this.isCallEnabled,
    required this.isVideoCallEnabled,
    required this.chatRate,
    required this.callRate,
    required this.videoCallRate,
    required this.po5Enabled,
    this.po5UserRate,
    this.po5AstrologerRate,
    this.otpVerifiedAt,
    this.otpExpiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AstrologerModel.fromJson(Map<String, dynamic> json) {
    return AstrologerModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      yearsOfExperience: json['years_of_experience'] ?? 0,
      areasOfExpertise: json['areas_of_expertise'] != null 
          ? List<String>.from(json['areas_of_expertise']) 
          : [],
      languages: json['languages'] != null 
          ? List<String>.from(json['languages']) 
          : [],
      profilePhoto: json['profile_photo'],
      bio: json['bio'],
      idProof: json['id_proof'],
      certificate: json['certificate'],
      idProofNumber: json['id_proof_number'],
      dateOfBirth: json['date_of_birth'],
      status: json['status'] ?? '',
      isChatEnabled: json['is_chat_enabled'] == 1 || json['is_chat_enabled'] == true,
      isCallEnabled: json['is_call_enabled'] == 1 || json['is_call_enabled'] == true,
      isVideoCallEnabled: json['is_video_call_enabled'] == 1 || json['is_video_call_enabled'] == true,
      chatRate: json['chat_rate']?.toString() ?? '0.00',
      callRate: json['call_rate']?.toString() ?? '0.00',
      videoCallRate: json['video_call_rate']?.toString() ?? '0.00',
      po5Enabled: json['po5_enabled'] == 1 || json['po5_enabled'] == true,
      po5UserRate: json['po5_user_rate']?.toString(),
      po5AstrologerRate: json['po5_astrologer_rate']?.toString(),
      otpVerifiedAt: json['otp_verified_at'],
      otpExpiresAt: json['otp_expires_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'years_of_experience': yearsOfExperience,
      'areas_of_expertise': areasOfExpertise,
      'languages': languages,
      'profile_photo': profilePhoto,
      'bio': bio,
      'id_proof': idProof,
      'certificate': certificate,
      'id_proof_number': idProofNumber,
      'date_of_birth': dateOfBirth,
      'status': status,
      'is_chat_enabled': isChatEnabled ? 1 : 0,
      'is_call_enabled': isCallEnabled ? 1 : 0,
      'is_video_call_enabled': isVideoCallEnabled ? 1 : 0,
      'chat_rate': chatRate,
      'call_rate': callRate,
      'video_call_rate': videoCallRate,
      'po5_enabled': po5Enabled ? 1 : 0,
      'po5_user_rate': po5UserRate,
      'po5_astrologer_rate': po5AstrologerRate,
      'otp_verified_at': otpVerifiedAt,
      'otp_expires_at': otpExpiresAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
