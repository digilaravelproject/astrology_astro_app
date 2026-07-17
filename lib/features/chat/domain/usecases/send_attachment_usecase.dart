import 'package:astro_astrologer/features/chat/domain/repositories/i_chat_repository.dart';

class SendAttachmentUseCase {
  final IChatRepository _repository;
  const SendAttachmentUseCase(this._repository);

  /// Send an image (pass image_picker XFile as [file])
  Future<({int id, String url})?> executeImage({
    required int sessionId,
    required dynamic file,
  }) {
    return _repository.sendImageAttachment(sessionId: sessionId, xFile: file);
  }

  /// Send a document (pass file_picker FilePickerResult as [result])
  Future<({int id, String url})?> executeDocument({
    required int sessionId,
    required String fileName,
    required dynamic result,
  }) {
    return _repository.sendDocumentAttachment(
      sessionId: sessionId,
      fileName: fileName,
      pickerResult: result,
    );
  }
}
