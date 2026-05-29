class RemedyModel {
  final int id;
  final String title;
  final String description;
  final String? image;
  final String? imagePath;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  RemedyModel({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    this.imagePath,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RemedyModel.fromJson(Map<String, dynamic> json) {
    return RemedyModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'],
      imagePath: json['image_path'],
      isActive: json['is_active'] == true || json['is_active'] == 1,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'image_path': imagePath,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
