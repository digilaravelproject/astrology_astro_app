import 'package:astro_astrologer/features/chat/domain/entities/chat_session.dart';
import 'package:astro_astrologer/features/chat/domain/repositories/i_chat_repository.dart';

class EndChatSessionUseCase {
  final IChatRepository _repository;
  const EndChatSessionUseCase(this._repository);

  Future<ChatSession?> execute(int sessionId) {
    return _repository.endChatSession(sessionId);
  }
}
