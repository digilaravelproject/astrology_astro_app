import 'dart:io';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/services/network/multipart.dart';
import 'package:astro_astrologer/core/services/network/response_model.dart';

abstract class IChatRemoteDataSource {
  Future<ResponseModel> getChatHistory(int sessionId);
  Future<ResponseModel> sendTextMessage(int sessionId, String text);
  Future<ResponseModel> uploadImageAttachment(int sessionId, dynamic xFile);
  Future<ResponseModel> uploadDocumentAttachment(int sessionId, String fileName, dynamic pickerResult);
  Future<ResponseModel> sendAttachmentMessage({
    required int sessionId,
    required String message,
    required String type,
    required String attachmentUrl,
  });
  Future<ResponseModel> markMessagesRead(int sessionId);
  Future<ResponseModel> endChatSession(int sessionId);
  Future<ResponseModel> getChatSessions(int page);
}

class ChatRemoteDataSourceImpl implements IChatRemoteDataSource {
  final ApiClient _apiClient;

  ChatRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<ResponseModel> getChatHistory(int sessionId) async {
    return await _apiClient.get(
      AppUrls.getChatMessages(sessionId),
      handleError: false,
      showToaster: false,
    );
  }

  @override
  Future<ResponseModel> sendTextMessage(int sessionId, String text) async {
    return await _apiClient.post(
      AppUrls.sendChatMessage(sessionId),
      data: {'message': text, 'type': 'text'},
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
      data: {
        'message': message,
        'type': type,
        'attachment_url': attachmentUrl,
      },
      handleError: false,
      showToaster: false,
    );
  }

  @override
  Future<ResponseModel> uploadImageAttachment(int sessionId, dynamic xFile) async {
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
  Future<ResponseModel> uploadDocumentAttachment(int sessionId, String fileName, dynamic pickerResult) async {
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
}
