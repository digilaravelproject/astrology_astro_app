import 'package:astro_astrologer/features/chat/domain/repositories/i_chat_repository.dart';

class AcceptChatSessionUseCase {
  final IChatRepository _repository;

  AcceptChatSessionUseCase(this._repository);

  Future<void> execute(int sessionId) async {
    return await _repository.acceptChatSession(sessionId);
  }
}
