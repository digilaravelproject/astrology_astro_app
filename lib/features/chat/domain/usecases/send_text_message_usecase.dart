import 'package:astro_astrologer/features/chat/domain/repositories/i_chat_repository.dart';

class SendTextMessageUseCase {
  final IChatRepository _repository;
  const SendTextMessageUseCase(this._repository);

  Future<int?> execute({required int sessionId, required String text}) {
    return _repository.sendTextMessage(sessionId: sessionId, text: text);
  }
}
