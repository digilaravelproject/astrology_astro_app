import 'package:astro_astrologer/features/chat/domain/repositories/i_chat_repository.dart';

class MarkMessagesReadUseCase {
  final IChatRepository _repository;
  const MarkMessagesReadUseCase(this._repository);

  Future<void> execute(int sessionId) {
    return _repository.markMessagesRead(sessionId);
  }
}
