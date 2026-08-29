import 'package:astro_astrologer/features/chat/domain/entities/chat_message.dart';
import 'package:astro_astrologer/features/chat/domain/entities/chat_session.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.text,
    required super.isMe,
    required super.time,
    required super.status,
    super.image,
    required super.type,
    super.attachmentUrl,
    super.replyToId,
    super.replyTo,
  });

  factory ChatMessageModel.fromJson(
    Map<String, dynamic> json, {
    required int currentUserId,
  }) {
    final senderId = int.tryParse(json['sender_id']?.toString() ?? '') ?? 0;

    ChatMessageModel? parsedReplyTo;
    if (json['reply_to'] != null && json['reply_to'] is Map<String, dynamic>) {
      parsedReplyTo = ChatMessageModel.fromJson(
        json['reply_to'] as Map<String, dynamic>,
        currentUserId: currentUserId,
      );
    }

    return ChatMessageModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      text: json['message']?.toString() ?? '',
      isMe: senderId == currentUserId,
      time:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      status:
          (json['is_read'] == true ||
                  json['is_read'] == 1 ||
                  json['is_read']?.toString() == '1' ||
                  json['is_read']?.toString() == 'true')
              ? 'seen'
              : ((json['is_delivered'] == true ||
                      json['is_delivered'] == 1 ||
                      json['is_delivered']?.toString() == '1' ||
                      json['is_delivered']?.toString() == 'true')
                  ? 'delivered'
                  : 'sent'),
      type: json['type']?.toString() ?? 'text',
      attachmentUrl: json['attachment_url']?.toString(),
      image:
          json['type'] == 'image' ? json['attachment_url']?.toString() : null,
      replyToId:
          json['reply_to_id'] != null
              ? int.tryParse(json['reply_to_id'].toString())
              : null,
      replyTo: parsedReplyTo,
    );
  }
}

class ChatSessionModel extends ChatSession {
  const ChatSessionModel({
    required super.id,
    required super.durationSeconds,
    required super.totalCost,
  });

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    final sessionData = json.containsKey('session') ? json['session'] : json;
    return ChatSessionModel(
      id: int.tryParse(sessionData['id']?.toString() ?? '') ?? 0,
      durationSeconds:
          int.tryParse(sessionData['duration_seconds']?.toString() ?? '') ?? 0,
      totalCost:
          double.tryParse(sessionData['total_cost']?.toString() ?? '') ?? 0.0,
    );
  }
}
