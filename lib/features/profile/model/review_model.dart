class ReviewModel {
  final int id;
  final int astrologerId;
  final int userId;
  final double rating;
  final String review;
  final String? reply;
  final DateTime? replyAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ReviewUserModel? user;

  ReviewModel({
    required this.id,
    required this.astrologerId,
    required this.userId,
    required this.rating,
    required this.review,
    this.reply,
    this.replyAt,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? 0,
      astrologerId: json['astrologer_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      review: json['review'] ?? '',
      reply: json['reply'],
      replyAt: json['reply_at'] != null ? DateTime.tryParse(json['reply_at'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now() : DateTime.now(),
      user: json['user'] != null ? ReviewUserModel.fromJson(json['user']) : null,
    );
  }
}

class ReviewUserModel {
  final int id;
  final String name;
  final String? profilePhoto;

  ReviewUserModel({
    required this.id,
    required this.name,
    this.profilePhoto,
  });

  factory ReviewUserModel.fromJson(Map<String, dynamic> json) {
    return ReviewUserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      profilePhoto: json['profile_photo'],
    );
  }
}
