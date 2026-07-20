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
  final num ratePerMinute;
  final int durationSeconds;
  final num totalCost;
  final String createdAt;
  final int unreadCount;
  final int? chatAssistanceSessionId;
  
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
    this.chatAssistanceSessionId,
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
      chatAssistanceSessionId: json['chat_assistance_session_id'],
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
  final String? gender;
  final String? dateOfBirth;
  final String? timeOfBirth;
  final String? placeOfBirth;
  final num chatRatePerMinute;
  final int? chatAssistanceSessionId;

  ChatSessionUserModel({
    required this.id,
    required this.name,
    this.profilePhoto,
    this.gender,
    this.dateOfBirth,
    this.timeOfBirth,
    this.placeOfBirth,
    required this.chatRatePerMinute,
    this.chatAssistanceSessionId,
  });

  factory ChatSessionUserModel.fromJson(Map<String, dynamic> json) {
    num chatRate = 0;
    if (json['astrologer'] != null && json['astrologer']['chat_rate_per_minute'] != null) {
      chatRate = json['astrologer']['chat_rate_per_minute'];
    }
    return ChatSessionUserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      profilePhoto: json['profile_photo']?.toString(),
      gender: json['gender']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      timeOfBirth: json['time_of_birth']?.toString(),
      placeOfBirth: json['place_of_birth']?.toString(),
      chatRatePerMinute: chatRate,
      chatAssistanceSessionId: json['chat_assistance_session_id'] is int 
          ? json['chat_assistance_session_id'] 
          : int.tryParse(json['chat_assistance_session_id']?.toString() ?? ''),
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
