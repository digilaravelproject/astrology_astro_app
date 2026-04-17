import '../../../../core/constants/app_urls.dart';

class RemedyModel {
  final int id;
  final String title;
  final String description;
  final String? image;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  RemedyModel({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RemedyModel.fromJson(Map<String, dynamic> json) {
    String? imagePath = json['image_path']?.toString() ?? json['image']?.toString();
    String? fullImageUrl;
    
    if (imagePath != null && imagePath.isNotEmpty) {
      if (imagePath.startsWith('http')) {
        fullImageUrl = imagePath;
      } else {
        // Clean leading slashes and storage/ prefix
        String cleanedPath = imagePath;
        if (cleanedPath.startsWith('/')) cleanedPath = cleanedPath.substring(1);
        if (cleanedPath.startsWith('storage/')) cleanedPath = cleanedPath.replaceFirst('storage/', '');
        if (cleanedPath.startsWith('/')) cleanedPath = cleanedPath.substring(1);
        
        fullImageUrl = "${AppUrls.baseImageUrl}$cleanedPath";
      }
    }

    return RemedyModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: fullImageUrl,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
