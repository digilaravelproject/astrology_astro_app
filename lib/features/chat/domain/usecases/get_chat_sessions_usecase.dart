import 'package:astro_astrologer/features/chat/domain/repositories/i_chat_repository.dart';
import 'package:astro_astrologer/features/chat/domain/models/chat_session_model.dart';

class GetChatSessionsUseCase {
  final IChatRepository _repository;

  GetChatSessionsUseCase(this._repository);

  Future<ChatSessionListResponse> execute({int page = 1}) {
    return _repository.getChatSessions(page: page);
  }
}
