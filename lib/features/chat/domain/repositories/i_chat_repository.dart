import 'package:astro_astrologer/features/chat/domain/entities/chat_message.dart';
import 'package:astro_astrologer/features/chat/domain/entities/chat_session.dart';

abstract class IChatRepository {
  Future<({List<ChatMessage> messages, String? startedAt})> getChatHistory({
    required int sessionId,
    required int currentUserId,
  });
  Future<int?> sendTextMessage({
    required int sessionId,
    required String text,
  });
  Future<({int id, String url})?> sendImageAttachment({
    required int sessionId,
    required dynamic xFile,
  });
  Future<({int id, String url})?> sendDocumentAttachment({
    required int sessionId,
    required String fileName,
    required dynamic pickerResult,
  });
  Future<void> markMessagesRead(int sessionId);
  Future<ChatSession?> endChatSession(int sessionId);
}
