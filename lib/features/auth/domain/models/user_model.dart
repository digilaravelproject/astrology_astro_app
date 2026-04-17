import 'dart:convert';
import 'package:astro_astrologer/features/profile/model/skill_model.dart';
import 'package:astro_astrologer/features/profile/model/other_details_model.dart';
import '../../../../core/utils/logger.dart';

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
    final user = UserModel(
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
    Logger.d('UserModel.fromJson keys: ${json.keys.toList()}');
    Logger.d('UserModel.fromJson: Mapping complete. id: ${user.id}, Has astrologer: ${user.astrologer != null}');
    return user;
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? city,
    String? country,
    String? profilePhoto,
    String? gender,
    String? dateOfBirth,
    String? timeOfBirth,
    String? placeOfBirth,
    String? languages,
    bool? profileCompleted,
    String? userType,
    String? createdAt,
    String? updatedAt,
    AstrologerModel? astrologer,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      country: country ?? this.country,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      timeOfBirth: timeOfBirth ?? this.timeOfBirth,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      languages: languages ?? this.languages,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      astrologer: astrologer ?? this.astrologer,
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
  final AstrologerSkillsModel? skill;
  final OtherDetailsModel? otherDetails;

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
    this.skill,
    this.otherDetails,
  });

  factory AstrologerModel.fromJson(Map<String, dynamic> json) {
    final ast = AstrologerModel(
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
      skill: json['skill'] != null ? AstrologerSkillsModel.fromJson(json['skill']) : null,
      otherDetails: json['other_details'] != null ? OtherDetailsModel.fromJson(json['other_details']) : null,
    );
    Logger.d('AstrologerModel.fromJson keys: ${json.keys.toList()}');
    Logger.d('AstrologerModel.fromJson: Mapping complete. id: ${ast.id}, Has otherDetails: ${ast.otherDetails != null}');
    return ast;
  }

  AstrologerModel copyWith({
    int? id,
    int? userId,
    int? yearsOfExperience,
    List<String>? areasOfExpertise,
    List<String>? languages,
    String? profilePhoto,
    String? bio,
    String? idProof,
    String? certificate,
    String? idProofNumber,
    String? dateOfBirth,
    String? status,
    bool? isChatEnabled,
    bool? isCallEnabled,
    bool? isVideoCallEnabled,
    String? chatRate,
    String? callRate,
    String? videoCallRate,
    bool? po5Enabled,
    String? po5UserRate,
    String? po5AstrologerRate,
    String? otpVerifiedAt,
    String? otpExpiresAt,
    String? createdAt,
    String? updatedAt,
    AstrologerSkillsModel? skill,
    OtherDetailsModel? otherDetails,
  }) {
    return AstrologerModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      areasOfExpertise: areasOfExpertise ?? this.areasOfExpertise,
      languages: languages ?? this.languages,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      bio: bio ?? this.bio,
      idProof: idProof ?? this.idProof,
      certificate: certificate ?? this.certificate,
      idProofNumber: idProofNumber ?? this.idProofNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      status: status ?? this.status,
      isChatEnabled: isChatEnabled ?? this.isChatEnabled,
      isCallEnabled: isCallEnabled ?? this.isCallEnabled,
      isVideoCallEnabled: isVideoCallEnabled ?? this.isVideoCallEnabled,
      chatRate: chatRate ?? this.chatRate,
      callRate: callRate ?? this.callRate,
      videoCallRate: videoCallRate ?? this.videoCallRate,
      po5Enabled: po5Enabled ?? this.po5Enabled,
      po5UserRate: po5UserRate ?? this.po5UserRate,
      po5AstrologerRate: po5AstrologerRate ?? this.po5AstrologerRate,
      otpVerifiedAt: otpVerifiedAt ?? this.otpVerifiedAt,
      otpExpiresAt: otpExpiresAt ?? this.otpExpiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      skill: skill ?? this.skill,
      otherDetails: otherDetails ?? this.otherDetails,
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
      'skill': skill?.toJson(),
      'other_details': otherDetails?.toJson(),
    };
  }
}
