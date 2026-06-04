import 'package:astro_astrologer/features/chat/domain/repositories/i_chat_repository.dart';

class SyncMessageStatusUseCase {
  final IChatRepository _repository;

  SyncMessageStatusUseCase(this._repository);

  Future<void> execute({required int sessionId, required List<int> messageIds, required String status}) async {
    return await _repository.syncMessageStatus(
      sessionId: sessionId,
      messageIds: messageIds,
      status: status,
    );
  }
}
