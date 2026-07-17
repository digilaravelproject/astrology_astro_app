import 'package:astro_astrologer/features/chat/domain/entities/chat_message.dart';

abstract class IChatLocalDataSource {
  List<ChatMessage> getCachedMessages(int sessionId);
  void cacheMessages(int sessionId, List<ChatMessage> messages);
}

class ChatLocalDataSourceImpl implements IChatLocalDataSource {
  final Map<int, List<ChatMessage>> _cache = {};

  @override
  List<ChatMessage> getCachedMessages(int sessionId) {
    return _cache[sessionId] ?? [];
  }

  @override
  void cacheMessages(int sessionId, List<ChatMessage> messages) {
    _cache[sessionId] = messages;
  }
}
