class TrainingVideoModel {
  final int id;
  final String title;
  final String type;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  final bool isActive;
  final int sortOrder;
  final String createdAt;
  final String updatedAt;

  TrainingVideoModel({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TrainingVideoModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return TrainingVideoModel.empty();
    return TrainingVideoModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      isActive: json['is_active'] ?? false,
      sortOrder: json['sort_order'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  factory TrainingVideoModel.empty() {
    return TrainingVideoModel(
      id: 0,
      title: '',
      type: '',
      description: '',
      videoUrl: '',
      thumbnailUrl: '',
      isActive: false,
      sortOrder: 0,
      createdAt: '',
      updatedAt: '',
    );
  }
}