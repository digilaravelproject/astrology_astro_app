import 'package:astro_astrologer/features/chat/domain/entities/chat_message.dart';
import 'package:astro_astrologer/features/chat/domain/repositories/i_chat_repository.dart';

class LoadChatHistoryUseCase {
  final IChatRepository _repository;
  const LoadChatHistoryUseCase(this._repository);

  Future<({List<ChatMessage> messages, String? startedAt})> execute({
    required int sessionId,
    required int currentUserId,
  }) {
    return _repository.getChatHistory(
      sessionId: sessionId,
      currentUserId: currentUserId,
    );
  }
}
