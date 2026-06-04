class ChatSessionListResponse {
  final int currentPage;
  final int lastPage;
  final String? nextPageUrl;
  final List<ChatSessionModel> data;

  ChatSessionListResponse({
    required this.currentPage,
    required this.lastPage,
    this.nextPageUrl,
    required this.data,
  });

  factory ChatSessionListResponse.fromJson(Map<String, dynamic> json) {
    return ChatSessionListResponse(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      nextPageUrl: json['next_page_url']?.toString(),
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => ChatSessionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ChatSessionModel {
  final int id;
  final int consumerId;
  final int providerId;
  final String status;
  final int ratePerMinute;
  final int durationSeconds;
  final num totalCost;
  final String createdAt;
  final int unreadCount;
  
  // Either consumer or provider will be populated depending on the API side
  final ChatSessionUserModel? provider;
  final ChatSessionUserModel? consumer;
  
  final ChatSessionLatestMessage? latestMessage;

  ChatSessionModel({
    required this.id,
    required this.consumerId,
    required this.providerId,
    required this.status,
    required this.ratePerMinute,
    required this.durationSeconds,
    required this.totalCost,
    required this.createdAt,
    required this.unreadCount,
    this.provider,
    this.consumer,
    this.latestMessage,
  });

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      id: json['id'] ?? 0,
      consumerId: json['consumer_id'] ?? 0,
      providerId: json['provider_id'] ?? 0,
      status: json['status'] ?? '',
      ratePerMinute: json['rate_per_minute'] ?? 0,
      durationSeconds: json['duration_seconds'] ?? 0,
      totalCost: json['total_cost'] ?? 0.0,
      createdAt: json['created_at'] ?? '',
      unreadCount: json['unread_count'] ?? 0,
      provider: json['provider'] != null ? ChatSessionUserModel.fromJson(json['provider']) : null,
      consumer: json['consumer'] != null ? ChatSessionUserModel.fromJson(json['consumer']) : null,
      latestMessage: json['latest_message'] != null ? ChatSessionLatestMessage.fromJson(json['latest_message']) : null,
    );
  }
}

class ChatSessionUserModel {
  final int id;
  final String name;
  final String? profilePhoto;
  final int chatRatePerMinute;

  ChatSessionUserModel({
    required this.id,
    required this.name,
    this.profilePhoto,
    required this.chatRatePerMinute,
  });

  factory ChatSessionUserModel.fromJson(Map<String, dynamic> json) {
    int chatRate = 0;
    if (json['astrologer'] != null && json['astrologer']['chat_rate_per_minute'] != null) {
      chatRate = json['astrologer']['chat_rate_per_minute'];
    }
    return ChatSessionUserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      profilePhoto: json['profile_photo']?.toString(),
      chatRatePerMinute: chatRate,
    );
  }
}

class ChatSessionLatestMessage {
  final int id;
  final int chatSessionId;
  final int senderId;
  final int receiverId;
  final String message;
  final String type;
  final String createdAt;

  ChatSessionLatestMessage({
    required this.id,
    required this.chatSessionId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.type,
    required this.createdAt,
  });

  factory ChatSessionLatestMessage.fromJson(Map<String, dynamic> json) {
    return ChatSessionLatestMessage(
      id: json['id'] ?? 0,
      chatSessionId: json['chat_session_id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      receiverId: json['receiver_id'] ?? 0,
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
