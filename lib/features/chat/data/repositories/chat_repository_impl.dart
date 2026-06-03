import 'package:astro_astrologer/features/chat/data/datasources/chat_local_data_source.dart';
import 'package:astro_astrologer/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:astro_astrologer/features/chat/data/models/chat_message_model.dart';
import 'package:astro_astrologer/features/chat/domain/entities/chat_message.dart';
import 'package:astro_astrologer/features/chat/domain/entities/chat_session.dart';
import 'package:astro_astrologer/features/chat/domain/repositories/i_chat_repository.dart';

class ChatRepositoryImpl implements IChatRepository {
  final IChatRemoteDataSource _remoteDataSource;
  final IChatLocalDataSource _localDataSource;

  ChatRepositoryImpl({
    required IChatRemoteDataSource remoteDataSource,
    required IChatLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<({List<ChatMessage> messages, String? startedAt})> getChatHistory({
    required int sessionId,
    required int currentUserId,
  }) async {
    final cached = _localDataSource.getCachedMessages(sessionId);
    if (cached.isNotEmpty) {
      return (messages: cached, startedAt: null);
    }

    final response = await _remoteDataSource.getChatHistory(sessionId);
    if (response.isSuccess && response.body != null) {
      final body = response.body;
      final dynamic messagesData = body['messages'] ?? body['data'] ?? [];
      final List<ChatMessage> messagesList = [];

      if (messagesData is List) {
        for (var item in messagesData) {
          if (item is Map<String, dynamic>) {
            messagesList.add(ChatMessageModel.fromJson(item, currentUserId: currentUserId));
          }
        }
      }

      final String? startedAt = body['started_at']?.toString();
      _localDataSource.cacheMessages(sessionId, messagesList);
      return (messages: messagesList, startedAt: startedAt);
    }

    return (messages: <ChatMessage>[], startedAt: null);
  }

  @override
  Future<int?> sendTextMessage({
    required int sessionId,
    required String text,
  }) async {
    final response = await _remoteDataSource.sendTextMessage(sessionId, text);
    if (response.isSuccess && response.body != null) {
      final data = response.body['data'] ?? response.body;
      if (data != null && data['id'] != null) {
        return int.tryParse(data['id'].toString());
      }
    }
    return null;
  }

  @override
  Future<({int id, String url})?> sendImageAttachment({
    required int sessionId,
    required dynamic xFile,
  }) async {
    final response = await _remoteDataSource.uploadImageAttachment(sessionId, xFile);
    if (response.isSuccess && response.body != null) {
      final data = response.body['data'] ?? response.body;
      if (data != null) {
        final url = data['attachment_url']?.toString() ?? '';
        
        // Now send the actual message with the attachment url
        final msgResponse = await _remoteDataSource.sendAttachmentMessage(
          sessionId: sessionId,
          message: '📷 Image',
          type: 'image',
          attachmentUrl: url,
        );
        
        if (msgResponse.isSuccess && msgResponse.body != null) {
          final msgData = msgResponse.body['data'] ?? msgResponse.body;
          if (msgData != null) {
            final id = int.tryParse(msgData['id']?.toString() ?? '') ?? 0;
            return (id: id, url: url);
          }
        }
      }
    }
    return null;
  }

  @override
  Future<({int id, String url})?> sendDocumentAttachment({
    required int sessionId,
    required String fileName,
    required dynamic pickerResult,
  }) async {
    final response = await _remoteDataSource.uploadDocumentAttachment(sessionId, fileName, pickerResult);
    if (response.isSuccess && response.body != null) {
      final data = response.body['data'] ?? response.body;
      if (data != null) {
        final url = data['attachment_url']?.toString() ?? '';
        
        // Now send the actual message with the attachment url
        final msgResponse = await _remoteDataSource.sendAttachmentMessage(
          sessionId: sessionId,
          message: '📄 $fileName',
          type: 'document',
          attachmentUrl: url,
        );
        
        if (msgResponse.isSuccess && msgResponse.body != null) {
          final msgData = msgResponse.body['data'] ?? msgResponse.body;
          if (msgData != null) {
            final id = int.tryParse(msgData['id']?.toString() ?? '') ?? 0;
            return (id: id, url: url);
          }
        }
      }
    }
    return null;
  }

  @override
  Future<void> markMessagesRead(int sessionId) async {
    await _remoteDataSource.markMessagesRead(sessionId);
  }

  @override
  Future<ChatSession?> endChatSession(int sessionId) async {
    final response = await _remoteDataSource.endChatSession(sessionId);
    if (response.isSuccess && response.body != null) {
      final data = response.body['data'] ?? response.body;
      if (data != null) {
        final sessionData = data['session'] ?? data;
        return ChatSessionModel.fromJson(sessionData);
      }
    }
    return null;
  }
}
