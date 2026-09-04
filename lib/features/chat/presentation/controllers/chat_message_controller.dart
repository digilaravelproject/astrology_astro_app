import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:astro_astrologer/features/chat/domain/entities/chat_message.dart';
import 'package:astro_astrologer/features/chat/data/models/chat_message_model.dart';
import 'package:astro_astrologer/features/chat/domain/usecases/load_chat_history_usecase.dart';
import 'package:astro_astrologer/features/chat/domain/usecases/send_text_message_usecase.dart';
import 'package:astro_astrologer/features/chat/domain/usecases/send_attachment_usecase.dart';
import 'package:astro_astrologer/features/chat/domain/usecases/mark_messages_read_usecase.dart';
import 'package:astro_astrologer/core/services/websocket/websocket_service.dart';
import 'package:astro_astrologer/core/enums/session_status_enums.dart';
import 'chat_controller.dart';

class ChatMessageController extends GetxController {
  final LoadChatHistoryUseCase _loadChatHistoryUseCase;
  final SendTextMessageUseCase _sendTextMessageUseCase;
  final SendAttachmentUseCase _sendAttachmentUseCase;
  final MarkMessagesReadUseCase _markMessagesReadUseCase;

  ChatMessageController({
    required LoadChatHistoryUseCase loadChatHistoryUseCase,
    required SendTextMessageUseCase sendTextMessageUseCase,
    required SendAttachmentUseCase sendAttachmentUseCase,
    required MarkMessagesReadUseCase markMessagesReadUseCase,
  }) : _loadChatHistoryUseCase = loadChatHistoryUseCase,
       _sendTextMessageUseCase = sendTextMessageUseCase,
       _sendAttachmentUseCase = sendAttachmentUseCase,
       _markMessagesReadUseCase = markMessagesReadUseCase;

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final Rx<ChatMessage?> replyingToMessage = Rx<ChatMessage?>(null);
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  StreamSubscription? _msgSub;
  StreamSubscription? _statusUpdateSub;

  ChatController get _orchestrator => Get.find<ChatController>();

  void setReply(ChatMessage message) => replyingToMessage.value = message;
  void cancelReply() => replyingToMessage.value = null;

  void setupMessageListeners() {
    _msgSub?.cancel();
    _msgSub = WebSocketService.incomingMessages.listen((list) {
      if (list.isNotEmpty) {
        final lastMsg = list.last;
        final msgSessionId = int.tryParse(lastMsg['chat_session_id']?.toString() ?? '') ?? 0;
        final int senderId = int.tryParse(lastMsg['sender_id']?.toString() ?? '') ?? 0;
        final int receiverId = int.tryParse(lastMsg['receiver_id']?.toString() ?? '') ?? 0;

        final isSameUserPair = (_orchestrator.peerId != null && _orchestrator.currentUserId != null) &&
            ((senderId == _orchestrator.currentUserId && receiverId == _orchestrator.peerId) ||
                (senderId == _orchestrator.peerId && receiverId == _orchestrator.currentUserId));

        if (msgSessionId == _orchestrator.sessionId || isSameUserPair) {
          final bool isMe = senderId == _orchestrator.currentUserId;
          final int msgId = int.tryParse(lastMsg['id']?.toString() ?? '') ?? 0;
          final String msgText = lastMsg['message']?.toString() ?? '';
          final String msgType = lastMsg['type']?.toString() ?? 'text';

          if (messages.any((m) => m.id == msgId)) return;

          if (isMe) {
            final pendingIndex = messages.indexWhere((m) =>
                m.isMe &&
                m.status == 'sending...' &&
                (m.text == msgText ||
                    m.text.replaceAll('<<reply<<', '') == msgText.replaceAll('<<reply<<', '') ||
                    (m.type == 'image' && msgType == 'image') ||
                    (m.type == 'file' && msgType == 'file')));
            if (pendingIndex != -1) {
              messages[pendingIndex] = messages[pendingIndex].copyWith(
                id: msgId,
                status: 'sent',
                time: DateTime.tryParse(lastMsg['created_at']?.toString() ?? '') ?? messages[pendingIndex].time,
                attachmentUrl: lastMsg['attachment_url']?.toString(),
                image: msgType == 'image' ? lastMsg['attachment_url']?.toString() : null,
                type: msgType,
              );
              messages.refresh();
            } else {
              if (_orchestrator.currentUserId != null) {
                messages.add(ChatMessageModel.fromJson(lastMsg, currentUserId: _orchestrator.currentUserId!));
                scrollToBottom();
              }
            }
          } else {
            if (_orchestrator.currentUserId != null) {
              messages.add(ChatMessageModel.fromJson(lastMsg, currentUserId: _orchestrator.currentUserId!));
              scrollToBottom();
              markRead();
            }
          }
        }
      }
    });

    _statusUpdateSub?.cancel();
    _statusUpdateSub = WebSocketService.messageStatusUpdates.listen((list) {
      if (list.isNotEmpty) {
        bool changed = false;
        for (var lastUpdate in list) {
          final updateSessionId = int.tryParse(lastUpdate['session_id']?.toString() ?? lastUpdate['chat_session_id']?.toString() ?? lastUpdate['chat_assistance_session_id']?.toString() ?? lastUpdate['sessionId']?.toString() ?? '') ?? 0;
          if (updateSessionId == _orchestrator.sessionId) {
            final newStatus = lastUpdate['status']?.toString();
            final messageIdsList = (lastUpdate['message_ids'] ?? lastUpdate['messageIds']) as List<dynamic>?;
            if (newStatus != null && messageIdsList != null && messageIdsList.isNotEmpty) {
              final messageIds = messageIdsList.map((e) => int.tryParse(e.toString()) ?? 0).toList();
              for (int i = 0; i < messages.length; i++) {
                if (messageIds.contains(messages[i].id)) {
                  if (newStatus == 'seen' && messages[i].status != 'seen') {
                    messages[i] = messages[i].copyWith(status: 'seen');
                    changed = true;
                  } else if (newStatus == 'delivered' && messages[i].status == 'sent') {
                    messages[i] = messages[i].copyWith(status: 'delivered');
                    changed = true;
                  }
                }
              }
            }
          }
        }
        if (changed) messages.refresh();
      }
    });
  }

  Future<void> loadHistory() async {
    if (_orchestrator.sessionId == null || _orchestrator.currentUserId == null) return;
    _orchestrator.session.isLoading.value = true;
    try {
      final result = await _loadChatHistoryUseCase.execute(sessionId: _orchestrator.sessionId!, currentUserId: _orchestrator.currentUserId!);
      messages.assignAll(result.messages);
      _orchestrator.peerId = result.peerId;
      if (result.startedAt != null && _orchestrator.session.status.value == ChatStatus.ongoing) {
        _orchestrator.session.startedAt = result.startedAt;
        _orchestrator.session.setupTimer(result.startedAt);
      }
      scrollToBottom();
      markRead();
    } catch (_) {} finally {
      _orchestrator.session.isLoading.value = false;
    }
  }

  String _getLatestStatus(int messageId, String defaultStatus) {
    String currentStatus = defaultStatus;
    for (var event in WebSocketService.messageStatusUpdates) {
      final updateSessionId = int.tryParse(event['session_id']?.toString() ?? event['chat_session_id']?.toString() ?? event['chat_assistance_session_id']?.toString() ?? event['sessionId']?.toString() ?? '') ?? 0;
      if (updateSessionId == _orchestrator.sessionId) {
        final messageIdsList = (event['message_ids'] ?? event['messageIds']) as List<dynamic>?;
        if (messageIdsList != null) {
          final messageIds = messageIdsList.map((e) => int.tryParse(e.toString()) ?? 0).toList();
          if (messageIds.contains(messageId)) {
            final newStatus = event['status']?.toString();
            if (newStatus == 'seen' || (newStatus == 'delivered' && currentStatus != 'seen')) {
              currentStatus = newStatus!;
            }
          }
        }
      }
    }
    return currentStatus;
  }

  Future<void> sendTextMessage() async {
    String text = messageController.text.trim();
    if (text.isEmpty || _orchestrator.sessionId == null) return;

    final replyToMessage = replyingToMessage.value;
    final replyToId = replyToMessage?.id;
    cancelReply();
    messageController.clear();

    final tempId = DateTime.now().millisecondsSinceEpoch;
    final localMsg = ChatMessage(id: tempId, text: text, isMe: true, time: DateTime.now(), status: 'sending...', type: 'text', replyToId: replyToId, replyTo: replyToMessage);
    messages.add(localMsg);
    scrollToBottom();

    try {
      final serverId = await _sendTextMessageUseCase.execute(sessionId: _orchestrator.sessionId!, text: text, replyToId: replyToId);
      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        if (serverId != null) {
          final newStatus = _getLatestStatus(serverId, 'sent');
          messages[index] = messages[index].copyWith(id: serverId, status: newStatus);
        } else {
          messages[index] = messages[index].copyWith(status: 'failed');
        }
      }
    } catch (_) {
      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) messages[index] = messages[index].copyWith(status: 'failed');
    }
  }

  Future<void> sendImageAttachment(XFile xFile) async {
    if (_orchestrator.sessionId == null) return;
    final tempId = DateTime.now().millisecondsSinceEpoch;
    final localMsg = ChatMessage(id: tempId, text: '📷 Sending Image...', isMe: true, time: DateTime.now(), status: 'sending...', image: xFile.path, type: 'image');
    messages.add(localMsg);
    scrollToBottom();

    try {
      final result = await _sendAttachmentUseCase.executeImage(sessionId: _orchestrator.sessionId!, file: xFile);
      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        if (result != null) {
          final newStatus = _getLatestStatus(result.id, 'sent');
          messages[index] = messages[index].copyWith(id: result.id, status: newStatus, image: result.url, attachmentUrl: result.url);
        } else {
          messages[index] = messages[index].copyWith(status: 'failed');
        }
      }
    } catch (_) {
      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) messages[index] = messages[index].copyWith(status: 'failed');
    }
  }

  Future<void> sendDocumentAttachment(PlatformFile platformFile) async {
    if (_orchestrator.sessionId == null) return;
    final tempId = DateTime.now().millisecondsSinceEpoch;
    final localMsg = ChatMessage(id: tempId, text: '📄 ${platformFile.name}', isMe: true, time: DateTime.now(), status: 'sending...', type: 'document');
    messages.add(localMsg);
    scrollToBottom();

    try {
      final pickerResult = FilePickerResult([platformFile]);
      final result = await _sendAttachmentUseCase.executeDocument(sessionId: _orchestrator.sessionId!, fileName: platformFile.name, result: pickerResult);
      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        if (result != null) {
          final newStatus = _getLatestStatus(result.id, 'sent');
          messages[index] = messages[index].copyWith(id: result.id, status: newStatus, attachmentUrl: result.url);
        } else {
          messages[index] = messages[index].copyWith(status: 'failed');
        }
      }
    } catch (_) {
      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) messages[index] = messages[index].copyWith(status: 'failed');
    }
  }

  Future<void> markRead() async {
    if (_orchestrator.sessionId == null) return;
    try {
      await _markMessagesReadUseCase.execute(_orchestrator.sessionId!);
    } catch (_) {}
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  void onClose() {
    _msgSub?.cancel();
    _statusUpdateSub?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
