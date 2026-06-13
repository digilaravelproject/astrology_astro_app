class BlogModel {
  final int id;
  final String title;
  final String subtitle;
  final String content;
  final String author;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? blogImage;
  final String? type;

  BlogModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.author,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.blogImage,
    this.type,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    return BlogModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      isActive: json['is_active'] == true || json['is_active'] == 1,
      blogImage: json['blog_image']?.toString(),
      type: json['type']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'author': author,
      'is_active': isActive,
      'blog_image': blogImage,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
