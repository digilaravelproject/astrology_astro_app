class OtherDetailsModel {
  int? id;
  int? astrologerId;
  String? gender;
  String? currentAddress;
  String? bio;
  String? dateOfBirth;
  String? websiteLink;
  String? instagramUsername;
  String? createdAt;
  String? updatedAt;

  OtherDetailsModel({
    this.id,
    this.astrologerId,
    this.gender,
    this.currentAddress,
    this.bio,
    this.dateOfBirth,
    this.websiteLink,
    this.instagramUsername,
    this.createdAt,
    this.updatedAt,
  });

  factory OtherDetailsModel.fromJson(Map<String, dynamic> json) => OtherDetailsModel(
    id: json['id'],
    astrologerId: json['astrologer_id'],
    gender: json['gender'],
    currentAddress: json['current_address'],
    bio: json['bio'],
    dateOfBirth: json['date_of_birth'],
    websiteLink: json['website_link'],
    instagramUsername: json['instagram_username'],
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
  );

  Map<String, dynamic> toJson() => {
    "gender": gender,
    "current_address": currentAddress,
    "bio": bio,
    "date_of_birth": dateOfBirth,
    "website_link": websiteLink,
    "instagram_username": instagramUsername,
  };
}