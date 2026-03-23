import 'dart:convert';

class FollowerResponse {
  final String status;
  final int count;
  final List<FollowerModel> followers;

  FollowerResponse({
    required this.status,
    required this.count,
    required this.followers,
  });

  factory FollowerResponse.fromJson(dynamic json) {
    if (json is List) {
      return FollowerResponse(
        status: 'success',
        count: json.length,
        followers: json.map((e) => FollowerModel.fromJson(e)).toList(),
      );
    }
    final Map<String, dynamic> data = json as Map<String, dynamic>;
    return FollowerResponse(
      status: data['status'] ?? '',
      count: data['count'] ?? 0,
      followers: (data['data'] as List? ?? [])
          .map((e) => FollowerModel.fromJson(e))
          .toList(),
    );
  }
}

class FollowerModel {
  final int userId;
  final String name;
  final String? email;
  final String phone;
  final bool isLiked;
  final String? likedAt;
  final String? followedAt;

  FollowerModel({
    required this.userId,
    required this.name,
    this.email,
    required this.phone,
    required this.isLiked,
    this.likedAt,
    this.followedAt,
  });

  factory FollowerModel.fromJson(Map<String, dynamic> json) {
    return FollowerModel(
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'] ?? '',
      isLiked: json['is_liked'] ?? false,
      likedAt: json['liked_at'],
      followedAt: json['followed_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'is_liked': isLiked,
      'liked_at': likedAt,
      'followed_at': followedAt,
    };
  }

  FollowerModel copyWith({
    int? userId,
    String? name,
    String? email,
    String? phone,
    bool? isLiked,
    String? likedAt,
    String? followedAt,
  }) {
    return FollowerModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isLiked: isLiked ?? this.isLiked,
      likedAt: likedAt ?? this.likedAt,
      followedAt: followedAt ?? this.followedAt,
    );
  }
}
