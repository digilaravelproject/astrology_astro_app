class NotificationItemModel {
  final int id;
  final int userId;
  final String title;
  final String body;
  final dynamic meta;
  final bool isRead;
  final String createdAt;

  NotificationItemModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.meta,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      meta: json['meta'],
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: json['created_at'] ?? '',
    );
  }

  /// Returns a human-readable relative time string
  String get timeAgo {
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return '1 day ago';
      return '${diff.inDays} days ago';
    } catch (_) {
      return '';
    }
  }
}
