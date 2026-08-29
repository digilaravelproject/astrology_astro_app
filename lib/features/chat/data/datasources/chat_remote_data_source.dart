import 'dart:io';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/services/network/multipart.dart';
import 'package:astro_astrologer/core/services/network/response_model.dart';

abstract class IChatRemoteDataSource {
  Future<ResponseModel> getChatHistory(int sessionId, {int perPage = 50});
  Future<ResponseModel> sendTextMessage(
    int sessionId,
    String text, {
    int? replyToId,
  });
  Future<ResponseModel> uploadImageAttachment(int sessionId, dynamic xFile);
  Future<ResponseModel> uploadDocumentAttachment(
    int sessionId,
    String fileName,
    dynamic pickerResult,
  );
  Future<ResponseModel> sendAttachmentMessage({
    required int sessionId,
    required String message,
    required String type,
    required String attachmentUrl,
  });
  Future<ResponseModel> markMessagesRead(int sessionId);
  Future<ResponseModel> syncMessageStatus(
    int sessionId,
    List<int> messageIds,
    String status,
  );
  Future<ResponseModel> endChatSession(int sessionId);
  Future<ResponseModel> getChatSessions(int page);

  // Default Messages
  Future<ResponseModel> getAllDefaultMessages();
  Future<ResponseModel> getActiveDefaultMessage();
  Future<ResponseModel> createDefaultMessage(
    String title,
    String content,
    bool isDefault,
  );
  Future<ResponseModel> updateDefaultMessage(
    int id,
    String title,
    String content,
    bool isDefault,
  );
  Future<ResponseModel> setDefaultMessageActive(int id);
  Future<ResponseModel> deleteDefaultMessage(int id);
}

class ChatRemoteDataSourceImpl implements IChatRemoteDataSource {
  final ApiClient _apiClient;

  ChatRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<ResponseModel> getChatHistory(
    int sessionId, {
    int perPage = 50,
  }) async {
    // per_page limit: prevents OOM crash on low-memory devices (32-bit ARM)
    final url = '${AppUrls.getChatMessages(sessionId)}?per_page=$perPage';
    return await _apiClient.get(url, handleError: false, showToaster: false);
  }

  @override
  Future<ResponseModel> sendTextMessage(
    int sessionId,
    String text, {
    int? replyToId,
  }) async {
    final Map<String, dynamic> data = {'message': text, 'type': 'text'};
    if (replyToId != null) {
      data['reply_to_id'] = replyToId;
    }
    return await _apiClient.post(
      AppUrls.sendChatMessage(sessionId),
      data: data,
      handleError: false,
      showToaster: false,
    );
  }

  @override
  Future<ResponseModel> sendAttachmentMessage({
    required int sessionId,
    required String message,
    required String type,
    required String attachmentUrl,
  }) async {
    return await _apiClient.post(
      AppUrls.sendChatMessage(sessionId),
      data: {'message': message, 'type': type, 'attachment_url': attachmentUrl},
      handleError: false,
      showToaster: false,
    );
  }

  @override
  Future<ResponseModel> uploadImageAttachment(
    int sessionId,
    dynamic xFile,
  ) async {
    return await _apiClient.postMultipartData(
      AppUrls.uploadAttachment,
      {'chat_session_id': sessionId.toString(), 'type': 'image'},
      [MultipartBody('file', xFile)],
      [],
      handleError: false,
      showToaster: false,
    );
  }

  @override
  Future<ResponseModel> uploadDocumentAttachment(
    int sessionId,
    String fileName,
    dynamic pickerResult,
  ) async {
    return await _apiClient.postMultipartData(
      AppUrls.uploadAttachment,
      {'chat_session_id': sessionId.toString(), 'type': 'document'},
      [],
      [MultipartDocument('file', pickerResult)],
      handleError: false,
      showToaster: false,
      fromChat: true,
    );
  }

  @override
  Future<ResponseModel> markMessagesRead(int sessionId) async {
    return await _apiClient.post(
      AppUrls.markChatRead(sessionId),
      data: {},
      handleError: false,
      showToaster: false,
    );
  }

  @override
  Future<ResponseModel> syncMessageStatus(
    int sessionId,
    List<int> messageIds,
    String status,
  ) async {
    return await _apiClient.post(
      AppUrls.syncChatStatus(sessionId),
      data: {'status': status, 'message_ids': messageIds},
      handleError: false,
      showToaster: false,
    );
  }

  @override
  Future<ResponseModel> endChatSession(int sessionId) async {
    return await _apiClient.post(
      AppUrls.endChatSession(sessionId),
      data: {},
      handleError: false,
      showToaster: false,
    );
  }

  @override
  Future<ResponseModel> getChatSessions(int page) async {
    return await _apiClient.get(
      '${AppUrls.astrologerChatSessions}?page=$page',
      handleError: true,
      showToaster: false,
    );
  }

  @override
  Future<ResponseModel> getAllDefaultMessages() async {
    return await _apiClient.get(AppUrls.defaultMessages);
  }

  @override
  Future<ResponseModel> getActiveDefaultMessage() async {
    return await _apiClient.get(AppUrls.activeDefaultMessage);
  }

  @override
  Future<ResponseModel> createDefaultMessage(
    String title,
    String content,
    bool isDefault,
  ) async {
    return await _apiClient.post(
      AppUrls.defaultMessages,
      data: {'title': title, 'content': content, 'is_default': isDefault},
    );
  }

  @override
  Future<ResponseModel> updateDefaultMessage(
    int id,
    String title,
    String content,
    bool isDefault,
  ) async {
    return await _apiClient.put(
      AppUrls.defaultMessageUpdate(id),
      data: {'title': title, 'content': content, 'is_default': isDefault},
    );
  }

  @override
  Future<ResponseModel> setDefaultMessageActive(int id) async {
    return await _apiClient.post(AppUrls.setDefaultMessageActive(id), data: {});
  }

  @override
  Future<ResponseModel> deleteDefaultMessage(int id) async {
    return await _apiClient.delete(AppUrls.defaultMessageDelete(id));
  }
}
