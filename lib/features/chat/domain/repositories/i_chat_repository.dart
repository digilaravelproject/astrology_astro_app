import 'package:astro_astrologer/features/chat/domain/entities/chat_message.dart';
import 'package:astro_astrologer/features/chat/domain/entities/chat_session.dart';
import 'package:astro_astrologer/features/chat/domain/models/chat_session_model.dart';

abstract class IChatRepository {
  Future<({List<ChatMessage> messages, String? startedAt, int? peerId})> getChatHistory({
    required int sessionId,
    required int currentUserId,
  });
  Future<int?> sendTextMessage({
    required int sessionId,
    required String text,
    int? replyToId,
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
  Future<void> syncMessageStatus({required int sessionId, required List<int> messageIds, required String status});
  Future<ChatSession?> endChatSession(int sessionId);
  Future<ChatSessionListResponse> getChatSessions({int page = 1});

  // Default Messages
  Future<List<dynamic>> getAllDefaultMessages();
  Future<dynamic> getActiveDefaultMessage();
  Future<dynamic> createDefaultMessage({required String title, required String content, required bool isDefault});
  Future<dynamic> updateDefaultMessage({required int id, required String title, required String content, required bool isDefault});
  Future<bool> setDefaultMessageActive(int id);
  Future<bool> deleteDefaultMessage(int id);
}
