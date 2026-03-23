class NoticeModel {
  final bool isSuccess;
  final List<NoticeData> notices;

  NoticeModel({required this.isSuccess, required this.notices});

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      isSuccess: true,
      notices: (json['notices'] as List)
          .map((e) => NoticeData.fromJson(e))
          .toList(),
    );
  }
}

class NoticeData {
  final int id;
  final String title;
  final String body;
  final String tag;
  final bool isUrgent;
  final String icon;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoticeData({
    required this.id,
    required this.title,
    required this.body,
    required this.tag,
    required this.isUrgent,
    required this.icon,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoticeData.fromJson(Map<String, dynamic> json) {
    return NoticeData(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      tag: json['tag'],
      isUrgent: json['is_urgent'] ?? false,
      icon: json['icon'] ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
