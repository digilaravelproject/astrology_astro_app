import 'dart:convert';

class FollowerResponse {
  final String status;
  final String message;
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final List<FollowerModel> followers;

  FollowerResponse({
    required this.status,
    required this.message,
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    required this.followers,
  });

  factory FollowerResponse.fromJson(Map<String, dynamic> json) {
    // The 'json' here is likely 'response.body', which is the 'data' object from the API
    final List<dynamic> followerList = json['followers'] ?? json['favorites'] ?? [];

    return FollowerResponse(
      status: 'success', // Assuming success if we got here
      message: '', 
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 10,
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      followers: followerList.map((e) => FollowerModel.fromJson(e)).toList(),
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
