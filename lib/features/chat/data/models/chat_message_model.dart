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
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json, {required int currentUserId}) {
    final senderId = int.tryParse(json['sender_id']?.toString() ?? '') ?? 0;
    return ChatMessageModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      text: json['message']?.toString() ?? '',
      isMe: senderId == currentUserId,
      time: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      status: json['is_read'] == true ? 'seen' : 'sent',
      type: json['type']?.toString() ?? 'text',
      attachmentUrl: json['attachment_url']?.toString(),
      image: json['type'] == 'image' ? json['attachment_url']?.toString() : null,
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
    return ChatSessionModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      durationSeconds: int.tryParse(json['duration_seconds']?.toString() ?? '') ?? 0,
      totalCost: double.tryParse(json['total_cost']?.toString() ?? '') ?? 0.0,
    );
  }
}
