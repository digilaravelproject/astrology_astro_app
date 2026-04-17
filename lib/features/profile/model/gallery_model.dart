import 'package:astro_astrologer/core/constants/app_urls.dart';

class GalleryImage {
  final int id;
  final String url;
  final String status;
  final bool isVisible;
  final DateTime? createdAt;

  GalleryImage({
    required this.id,
    required this.url,
    required this.status,
    required this.isVisible,
    this.createdAt,
  });

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    String imagePath = json['image_path']?.toString() ?? '';
    
    if (imagePath.isNotEmpty && !imagePath.startsWith('http')) {
      // Clean leading slashes and storage/ prefix
      if (imagePath.startsWith('/')) imagePath = imagePath.substring(1);
      if (imagePath.startsWith('storage/')) imagePath = imagePath.replaceFirst('storage/', '');
      if (imagePath.startsWith('/')) imagePath = imagePath.substring(1);
      
      imagePath = AppUrls.baseImageUrl + imagePath;
    }
    
    return GalleryImage(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      url: imagePath,
      status: json['status']?.toString() ?? 'pending',
      isVisible: json['is_visible'] == 1 || json['is_visible'] == true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': url,
      'status': status,
      'is_visible': isVisible ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
