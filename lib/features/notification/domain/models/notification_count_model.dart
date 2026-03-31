class NotificationCountModel {
  final int total;
  final int unread;

  NotificationCountModel({
    required this.total,
    required this.unread,
  });

  factory NotificationCountModel.fromJson(Map<String, dynamic> json) {
    return NotificationCountModel(
      total: json['total'] ?? 0,
      unread: json['unread'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'unread': unread,
    };
  }
}
