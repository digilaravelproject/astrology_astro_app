class AstrologerOrderModel {
  final int sessionId;
  final int orderId;
  final int userId;
  final String userName;
  final String? userProfileImage;
  final String requestType;
  final String status;
  final String? requestedAt;
  final String? startedAt;
  final String? endedAt;
  final int durationSeconds;
  final double amount;
  final double ratePerMinute;
  final String paymentStatus;
  final String? lastMessage;
  final int? queuePosition;

  AstrologerOrderModel({
    required this.sessionId,
    required this.orderId,
    required this.userId,
    required this.userName,
    this.userProfileImage,
    required this.requestType,
    required this.status,
    this.requestedAt,
    this.startedAt,
    this.endedAt,
    required this.durationSeconds,
    required this.amount,
    required this.ratePerMinute,
    required this.paymentStatus,
    this.lastMessage,
    this.queuePosition,
  });

  factory AstrologerOrderModel.fromJson(Map<String, dynamic> json) {
    return AstrologerOrderModel(
      sessionId: json['session_id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? 'User',
      userProfileImage: json['user_profile_image'],
      requestType: json['request_type'] ?? 'chat',
      status: json['status'] ?? 'pending',
      requestedAt: json['requested_at'],
      startedAt: json['started_at'],
      endedAt: json['ended_at'],
      durationSeconds: json['duration_seconds'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      ratePerMinute: (json['rate_per_minute'] ?? 0).toDouble(),
      paymentStatus: json['payment_status'] ?? 'pending',
      lastMessage: json['last_message'],
      queuePosition: json['queue_position'],
    );
  }
}
