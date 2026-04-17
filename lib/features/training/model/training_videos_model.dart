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
    
    String vUrl = (json['video_url'] ?? '').toString();
    String tUrl = (json['thumbnail_url'] ?? '').toString();
    
    // Comprehensive URL cleaning for both storage paths and leading slashes
    String cleanPath(String path) {
      if (path.isEmpty) return '';
      String result = path;
      if (result.startsWith('/')) result = result.substring(1);
      if (result.startsWith('storage/')) result = result.replaceFirst('storage/', '');
      if (result.startsWith('/')) result = result.substring(1);
      return result;
    }

    vUrl = cleanPath(vUrl);
    tUrl = cleanPath(tUrl);

    return TrainingVideoModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      type: (json['type'] == null || json['type'].toString().isEmpty) ? 'Call/Chat' : json['type'],
      description: json['description'] ?? '',
      videoUrl: vUrl,
      thumbnailUrl: tUrl,
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