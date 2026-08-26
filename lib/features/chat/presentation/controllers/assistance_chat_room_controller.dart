import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:astro_astrologer/core/services/network/multipart.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/services/network/websocket_service.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/features/chat/domain/entities/chat_message.dart';
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';
import 'package:flutter/material.dart';

class AssistanceChatRoomController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool limitReached = false.obs;
  final RxInt remainingMessages = 0.obs;

  final Rx<ChatMessage?> replyingToMessage = Rx<ChatMessage?>(null);

  void setReply(ChatMessage message) {
    replyingToMessage.value = message;
  }

  void cancelReply() {
    replyingToMessage.value = null;
  }

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  late int _sessionId;
  int _currentUserId = 0;

  StreamSubscription? _msgSub;
  StreamSubscription? _statusUpdateSub;

  int get sessionId => _sessionId;

  void initSession(int sessionId) {
    _sessionId = sessionId;
    _currentUserId = WebSocketService.currentUserId ?? 0;
    WebSocketService.activeSessionId = sessionId;
    fetchMessages();
    fetchAstrologerStatus();
    _setupWebsocketListeners();
    // Subscribe to dedicated chat room channel
    try {
      Get.find<WebSocketService>().subscribeToChannel('private-chat-assistance.$sessionId');
    } catch (e) {
      debugPrint('Error subscribing to chat assistance channel: $e');
    }
  }

  Future<void> fetchAstrologerStatus() async {
    try {
      final response = await _apiClient.get(AppUrls.getAstrologerChatAssistanceStatus);
      if (response.isSuccess && response.body['data'] != null) {
        final data = response.body['data'];
        limitReached.value = (data['remaining'] ?? 0) <= 0;
        remainingMessages.value = data['remaining'] ?? 0;
      }
    } catch (e) {
      debugPrint('Error fetching astrologer status: $e');
    }
  }

  Future<void> fetchMessages() async {
    isLoading.value = true;
    try {
      final response = await _apiClient.get(AppUrls.getChatAssistanceMessages(_sessionId));
      if (response.isSuccess) {
        dynamic rawData = response.body;
        List<dynamic> dataList = [];
        if (rawData is List) {
          dataList = rawData;
        } else if (rawData is Map) {
          if (rawData['data'] is List) {
            dataList = rawData['data'] as List;
          } else if (rawData['data'] is Map && rawData['data']['data'] is List) {
            dataList = rawData['data']['data'] as List;
          } else if (rawData['messages'] is List) {
            dataList = rawData['messages'] as List;
          }
        }

        messages.assignAll(dataList.map((msg) {
          final int senderId = int.tryParse(msg['sender_id']?.toString() ?? '') ?? 0;
          final bool isMe = senderId == _currentUserId;
          final bool isRead = msg['is_read'] == true || msg['is_read'] == 1 || msg['is_read']?.toString() == '1' || msg['is_read']?.toString() == 'true';
          final bool isDelivered = msg['is_delivered'] == true || msg['is_delivered'] == 1 || msg['is_delivered']?.toString() == '1' || msg['is_delivered']?.toString() == 'true';
          ChatMessage? replyToMsg;
          if (msg['reply_to'] != null) {
            final replyData = msg['reply_to'];
            final int replySenderId = int.tryParse(replyData['sender_id']?.toString() ?? '') ?? 0;
            replyToMsg = ChatMessage(
              id: int.tryParse(replyData['id']?.toString() ?? '') ?? 0,
              text: replyData['message']?.toString() ?? '',
              isMe: replySenderId == _currentUserId,
              time: DateTime.tryParse(replyData['created_at']?.toString() ?? '') ?? DateTime.now(),
              status: 'delivered', // fallback
              type: replyData['type']?.toString() ?? 'text',
              attachmentUrl: replyData['attachment_url']?.toString(),
            );
          }

          return ChatMessage(
            id: int.tryParse(msg['id']?.toString() ?? '') ?? 0,
            text: msg['message']?.toString() ?? '',
            isMe: isMe,
            time: DateTime.tryParse(msg['created_at']?.toString() ?? '') ?? DateTime.now(),
            status: isRead ? 'seen' : (isDelivered ? 'delivered' : 'sent'),
            type: msg['type']?.toString() ?? 'text',
            image: msg['type'] == 'image' ? msg['attachment_url']?.toString() : null,
            attachmentUrl: msg['attachment_url']?.toString(),
            replyToId: int.tryParse(msg['reply_to_id']?.toString() ?? ''),
            replyTo: replyToMsg,
          );
        }).toList().reversed);
        _scrollToBottom();
        syncReadStatus();
      }
    } catch (e) {
      debugPrint('Error fetching chat assistance messages: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    String text = messageController.text.trim();
    if (text.isEmpty || limitReached.value) return;

    int? replyToIdVal;
    ChatMessage? replyMsgVal;

    if (replyingToMessage.value != null) {
      replyMsgVal = replyingToMessage.value!;
      replyToIdVal = replyMsgVal.id;
      cancelReply();
    }

    messageController.clear();

    final tempId = DateTime.now().millisecondsSinceEpoch;
    final localMsg = ChatMessage(
      id: tempId,
      text: text,
      isMe: true,
      time: DateTime.now(),
      status: 'sending...',
      type: 'text',
      replyToId: replyToIdVal,
      replyTo: replyMsgVal,
    );
    messages.insert(0, localMsg);
    _scrollToBottom();

    try {
      final body = {
        'message': text,
        'type': 'text',
        if (replyToIdVal != null) 'reply_to_id': replyToIdVal,
      };

      final response = await _apiClient.post(AppUrls.sendChatAssistanceMessage(_sessionId), data: body);

      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        if (response.isSuccess) {
          final data = response.body['data']['message'];
          final serverId = int.tryParse(data['id']?.toString() ?? '') ?? 0;
          messages[index] = messages[index].copyWith(id: serverId, status: 'sent');
          fetchAstrologerStatus();
        } else {
          messages[index] = messages[index].copyWith(status: 'failed');
          if (response.message.toLowerCase().contains('limit')) {
            limitReached.value = true;
          } else {
            CustomSnackBar.showError(response.message);
          }
        }
        messages.refresh();
      }
    } catch (e) {
      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(status: 'failed');
        messages.refresh();
      }
    }
  }

  Future<void> sendImageAttachment(XFile xFile) async {
    if (limitReached.value) return;

    final tempId = DateTime.now().millisecondsSinceEpoch;
    final localMsg = ChatMessage(
      id: tempId,
      text: '📷 Sending Image...',
      isMe: true,
      time: DateTime.now(),
      status: 'sending...',
      image: xFile.path,
      type: 'image',
    );
    messages.insert(0, localMsg);
    _scrollToBottom();

    try {
      final response = await _apiClient.postMultipartData(
        AppUrls.sendChatAssistanceMessage(_sessionId),
        {'type': 'image', 'message': ''},
        [MultipartBody('file', xFile)],
        [],
      );

      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        if (response.isSuccess) {
          final data = response.body['data']['message'];
          final serverId = int.tryParse(data['id']?.toString() ?? '') ?? 0;
          final attachmentUrl = data['attachment_url']?.toString();
          messages[index] = messages[index].copyWith(
            id: serverId, 
            status: 'sent',
            image: attachmentUrl,
            attachmentUrl: attachmentUrl,
            text: '',
          );
          fetchAstrologerStatus();
        } else {
          messages[index] = messages[index].copyWith(status: 'failed');
          if (response.message.toLowerCase().contains('limit')) {
            limitReached.value = true;
          } else {
            CustomSnackBar.showError(response.message);
          }
        }
        messages.refresh();
      }
    } catch (e) {
      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(status: 'failed');
        messages.refresh();
      }
    }
  }

  Future<void> sendDocumentAttachment(PlatformFile platformFile) async {
    if (limitReached.value) return;

    final tempId = DateTime.now().millisecondsSinceEpoch;
    final localMsg = ChatMessage(
      id: tempId,
      text: '📄 ${platformFile.name}',
      isMe: true,
      time: DateTime.now(),
      status: 'sending...',
      type: 'document',
    );
    messages.insert(0, localMsg);
    _scrollToBottom();

    try {
      final pickerResult = FilePickerResult([platformFile]);
      final response = await _apiClient.postMultipartData(
        AppUrls.sendChatAssistanceMessage(_sessionId),
        {'type': 'document', 'message': platformFile.name},
        [],
        [MultipartDocument('file', pickerResult)],
      );

      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        if (response.isSuccess) {
          final data = response.body['data']['message'];
          final serverId = int.tryParse(data['id']?.toString() ?? '') ?? 0;
          final attachmentUrl = data['attachment_url']?.toString();
          messages[index] = messages[index].copyWith(
            id: serverId, 
            status: 'sent',
            attachmentUrl: attachmentUrl,
          );
          fetchAstrologerStatus();
        } else {
          messages[index] = messages[index].copyWith(status: 'failed');
          if (response.message.toLowerCase().contains('limit')) {
            limitReached.value = true;
          } else {
            CustomSnackBar.showError(response.message);
          }
        }
        messages.refresh();
      }
    } catch (e) {
      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(status: 'failed');
        messages.refresh();
      }
    }
  }

  Future<void> syncReadStatus() async {
    final unreadIds = messages
        .where((m) => !m.isMe && m.status != 'seen')
        .map((m) => m.id)
        .toList();

    if (unreadIds.isEmpty) return;

    try {
      final body = {
        'status': 'seen',
        'message_ids': unreadIds,
      };
      await _apiClient.post(AppUrls.syncChatAssistanceStatus(_sessionId), data: body);

      for (int i = 0; i < messages.length; i++) {
        if (unreadIds.contains(messages[i].id)) {
          messages[i] = messages[i].copyWith(status: 'seen');
        }
      }
      messages.refresh();
    } catch (e) {
      debugPrint('Error syncing read status: $e');
    }
  }

  void _setupWebsocketListeners() {
    _msgSub?.cancel();
    _msgSub = WebSocketService.incomingMessages.listen((list) {
      if (list.isNotEmpty) {
        final lastMsg = list.last;
        final msgSessionId = int.tryParse(lastMsg['chat_assistance_session_id']?.toString() ?? '') ?? 0;
        if (msgSessionId == _sessionId) {
          final int senderId = int.tryParse(lastMsg['sender_id']?.toString() ?? '') ?? 0;
          final bool isMe = senderId == _currentUserId;

          final int msgId = int.tryParse(lastMsg['id']?.toString() ?? '') ?? 0;
          final String msgText = lastMsg['message']?.toString() ?? '';
          final String msgType = lastMsg['type']?.toString() ?? 'text';

          ChatMessage? replyToMsg;
          if (lastMsg['reply_to'] != null) {
            final replyData = lastMsg['reply_to'];
            final int replySenderId = int.tryParse(replyData['sender_id']?.toString() ?? '') ?? 0;
            replyToMsg = ChatMessage(
              id: int.tryParse(replyData['id']?.toString() ?? '') ?? 0,
              text: replyData['message']?.toString() ?? '',
              isMe: replySenderId == _currentUserId,
              time: DateTime.tryParse(replyData['created_at']?.toString() ?? '') ?? DateTime.now(),
              status: 'delivered',
              type: replyData['type']?.toString() ?? 'text',
              attachmentUrl: replyData['attachment_url']?.toString(),
            );
          }
          final int? msgReplyToId = int.tryParse(lastMsg['reply_to_id']?.toString() ?? '');

          // Guard: already in list with the real server id → skip
          if (messages.any((m) => m.id == msgId)) return;

          if (isMe) {
            // ── My own message echoed back from WebSocket ──────────────────
            // Find the optimistic placeholder and upgrade it in-place
            // to prevent the duplicate (race: echo arrives before API updates tempId).
            final pendingIndex = messages.indexWhere(
              (m) => m.isMe && m.status == 'sending...' && 
                     (m.text == msgText || 
                      m.text.replaceAll('<<reply<<', '') == msgText.replaceAll('<<reply<<', '') ||
                      (m.type == 'image' && msgType == 'image') || 
                      (m.type == 'document' && msgType == 'document')),
            );
            if (pendingIndex != -1) {
              messages[pendingIndex] = messages[pendingIndex].copyWith(
                id: msgId,
                status: 'sent',
                time: DateTime.tryParse(lastMsg['created_at']?.toString() ?? '') ?? messages[pendingIndex].time,
                attachmentUrl: lastMsg['attachment_url']?.toString(),
                image: msgType == 'image' ? lastMsg['attachment_url']?.toString() : null,
                type: msgType,
                replyToId: msgReplyToId,
                replyTo: replyToMsg,
              );
              messages.refresh();
            } else {
              // No placeholder found (another device or late echo) — add normally
              messages.insert(0, ChatMessage(
                id: msgId,
                text: msgText,
                isMe: true,
                time: DateTime.tryParse(lastMsg['created_at']?.toString() ?? '') ?? DateTime.now(),
                status: 'sent',
                type: msgType,
                attachmentUrl: lastMsg['attachment_url']?.toString(),
                replyToId: msgReplyToId,
                replyTo: replyToMsg,
              ));
              _scrollToBottom();
            }
          } else {
            // ── Message from the other side ─────────────────────────────
            messages.insert(0, ChatMessage(
              id: msgId,
              text: msgText,
              isMe: false,
              time: DateTime.tryParse(lastMsg['created_at']?.toString() ?? '') ?? DateTime.now(),
              status: 'delivered',
              type: msgType,
              image: msgType == 'image' ? lastMsg['attachment_url']?.toString() : null,
              attachmentUrl: lastMsg['attachment_url']?.toString(),
              replyToId: msgReplyToId,
              replyTo: replyToMsg,
            ));
            _scrollToBottom();
            syncReadStatus();
          }
        }
      }
    });

    _statusUpdateSub?.cancel();
    _statusUpdateSub = WebSocketService.messageStatusUpdates.listen((list) {
      if (list.isNotEmpty) {
        final lastUpdate = list.last;
        final updateSessionId = int.tryParse(lastUpdate['sessionId']?.toString() ?? 
                                             lastUpdate['session_id']?.toString() ?? 
                                             lastUpdate['chat_assistance_session_id']?.toString() ?? '') ?? 0;
        if (updateSessionId == _sessionId) {
          final newStatus = lastUpdate['status']?.toString();
          final mappedStatus = newStatus == 'seen' ? 'seen' : (newStatus ?? 'sent');
          final messageIdsList = (lastUpdate['messageIds'] ?? lastUpdate['message_ids']) as List<dynamic>?;
          if (messageIdsList != null && messageIdsList.isNotEmpty) {
            final messageIds = messageIdsList.map((e) => int.tryParse(e.toString()) ?? 0).toList();
            bool changed = false;
            for (int i = 0; i < messages.length; i++) {
              if (messageIds.contains(messages[i].id)) {
                if (messages[i].status != 'seen') {
                  messages[i] = messages[i].copyWith(status: mappedStatus);
                  changed = true;
                }
              }
            }
            if (changed) messages.refresh();
          }
        }
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    _msgSub?.cancel();
    _statusUpdateSub?.cancel();
    messageController.dispose();
    scrollController.dispose();
    if (WebSocketService.activeSessionId == _sessionId) {
      WebSocketService.activeSessionId = null;
    }
    try {
      Get.find<WebSocketService>().unsubscribeFromChannel('private-chat-assistance.$_sessionId');
    } catch (_) {}
    super.onClose();
  }
}
