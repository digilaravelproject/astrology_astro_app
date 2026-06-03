import 'package:astro_astrologer/core/services/local_notification_service.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:astro_astrologer/core/services/network/websocket_service.dart';
import 'package:astro_astrologer/features/chat/domain/entities/chat_message.dart';
import 'package:astro_astrologer/features/chat/domain/usecases/end_chat_session_usecase.dart';
import 'package:astro_astrologer/features/chat/domain/usecases/load_chat_history_usecase.dart';
import 'package:astro_astrologer/features/chat/domain/usecases/mark_messages_read_usecase.dart';
import 'package:astro_astrologer/features/chat/domain/usecases/send_attachment_usecase.dart';
import 'package:astro_astrologer/features/chat/domain/usecases/send_text_message_usecase.dart';
import 'package:astro_astrologer/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_astrologer/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_astrologer/core/services/storage/shared_prefs.dart';
import 'package:astro_astrologer/core/constants/app_constants.dart';
import 'package:astro_astrologer/features/auth/domain/models/user_model.dart';

import 'package:astro_astrologer/features/chat/presentation/widgets/chat_summary_dialog.dart';
import 'package:astro_astrologer/features/chat/presentation/bindings/chat_binding.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';

class ChatController extends GetxController {
  final LoadChatHistoryUseCase _loadChatHistoryUseCase;
  final SendTextMessageUseCase _sendTextMessageUseCase;
  final SendAttachmentUseCase _sendAttachmentUseCase;
  final MarkMessagesReadUseCase _markMessagesReadUseCase;
  final EndChatSessionUseCase _endChatSessionUseCase;

  ChatController({
    required LoadChatHistoryUseCase loadChatHistoryUseCase,
    required SendTextMessageUseCase sendTextMessageUseCase,
    required SendAttachmentUseCase sendAttachmentUseCase,
    required MarkMessagesReadUseCase markMessagesReadUseCase,
    required EndChatSessionUseCase endChatSessionUseCase,
  })  : _loadChatHistoryUseCase = loadChatHistoryUseCase,
        _sendTextMessageUseCase = sendTextMessageUseCase,
        _sendAttachmentUseCase = sendAttachmentUseCase,
        _markMessagesReadUseCase = markMessagesReadUseCase,
        _endChatSessionUseCase = endChatSessionUseCase;

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxString status = 'connecting'.obs; // ongoing, ended
  final RxInt elapsedSeconds = 0.obs;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  int? _sessionId;
  int? _currentUserId;
  String? _userName;
  Timer? _timer;
  String? _startedAt;
  StreamSubscription? _msgSub;
  StreamSubscription? _endSub;
  StreamSubscription? _statusSub;
  StreamSubscription? _dismissSub;

  int? get sessionId => _sessionId;

  void initSession({
    required int sessionId,
    required int currentUserId,
    required String initialStatus,
    required String userName,
    String? startedAtString,
  }) {
    _sessionId = sessionId;
    if (currentUserId != 0) {
      _currentUserId = currentUserId;
    } else {
      _currentUserId = WebSocketService.currentUserId;
      if (_currentUserId == null || _currentUserId == 0) {
        try {
          final userDataStr = SharedPrefs.getString(AppConstants.userData);
          if (userDataStr != null && userDataStr.isNotEmpty) {
            final userModel = UserModel.fromJsonString(userDataStr);
            _currentUserId = userModel?.id;
            WebSocketService.currentUserId = _currentUserId;
          }
        } catch (_) {}
      }
    }
    _userName = userName;
    status.value = initialStatus;
    _startedAt = startedAtString;

    WebSocketService.activeSessionId = sessionId;

    // Load Chat history
    loadHistory();

    // Setup timer if started at is known
    _setupTimer(startedAtString);

    final startedAtStr = startedAtString ?? WebSocketService.sessionStartTimes[_sessionId];
    int? startedAtMillis;
    if (startedAtStr != null) {
      final startedAt = DateTime.tryParse(startedAtStr);
      if (startedAt != null) {
        startedAtMillis = startedAt.millisecondsSinceEpoch;
      }
    }

    // Show ongoing local notification
    if (status.value == 'ongoing') {
      LocalNotificationService.showOngoingChatNotification(
        sessionId: sessionId,
        title: 'Chat in progress',
        body: 'Active chat with $userName',
        startedAtMillis: startedAtMillis,
      );
    }

    ever(status, (val) {
      if (FloatingChatBubble.isActive && FloatingChatBubble.sessionId == _sessionId) {
        FloatingChatBubble.chatStatus.value = val;
      }
    });

    // Listen to WebSocket Incoming Messages
    _msgSub?.cancel();
    _msgSub = WebSocketService.incomingMessages.listen((list) {
      if (list.isNotEmpty) {
        final lastMsg = list.last;
        final msgSessionId = int.tryParse(lastMsg['chat_session_id']?.toString() ?? '') ?? 0;
        if (msgSessionId == _sessionId) {
          final int senderId = int.tryParse(lastMsg['sender_id']?.toString() ?? '') ?? 0;
          final bool isMe = senderId == _currentUserId;

          // Don't add if it's sent by me since we already added local/sending state or handle duplicates
          final int msgId = int.tryParse(lastMsg['id']?.toString() ?? '') ?? 0;
          final alreadyExists = messages.any((m) => m.id == msgId);
          if (!alreadyExists) {
            messages.add(ChatMessage(
              id: msgId,
              text: lastMsg['message']?.toString() ?? '',
              isMe: isMe,
              time: DateTime.tryParse(lastMsg['created_at']?.toString() ?? '') ?? DateTime.now(),
              status: 'seen',
              image: lastMsg['type'] == 'image' ? lastMsg['attachment_url']?.toString() : null,
              type: lastMsg['type']?.toString() ?? 'text',
              attachmentUrl: lastMsg['attachment_url']?.toString(),
            ));
            _scrollToBottom();
            markRead();
          }
        }
      }
    });

    // Listen to WebSocket Chat Ended Event
    _endSub?.cancel();
    _endSub = WebSocketService.chatEndedSessionId.listen((endedSessionId) {
      if (endedSessionId == _sessionId) {
        status.value = 'ended';
        _timer?.cancel();
        if (_sessionId != null) {
          LocalNotificationService.cancelOngoingChatNotification(_sessionId!);
        }
      }
    });

    // Listen to WebSocket Chat Dismissed Event
    _dismissSub?.cancel();
    _dismissSub = WebSocketService.chatDismissedSessionId.listen((dismissedSessionId) {
      if (dismissedSessionId == _sessionId) {
        status.value = 'ended'; // or 'dismissed'
        _timer?.cancel();
        if (_sessionId != null) {
          LocalNotificationService.cancelOngoingChatNotification(_sessionId!);
        }
        Get.back();
        Get.snackbar("Chat Cancelled", "The chat request was cancelled or timed out.");
      }
    });

    // Listen to WebSocket Session Status Updates (e.g. ChatAccepted)
    _statusSub?.cancel();
    _statusSub = WebSocketService.sessionStatusUpdates.listen((updates) {
      if (_sessionId != null && updates.containsKey(_sessionId)) {
        final newStatus = updates[_sessionId!];
        if (newStatus != null && status.value != newStatus) {
          status.value = newStatus;
          if (newStatus == 'ongoing') {
            _setupTimer(null); // start timer since it's now accepted
            
            final startedAtStr = WebSocketService.sessionStartTimes[_sessionId];
            int? startedAtMillis;
            if (startedAtStr != null) {
              final startedAt = DateTime.tryParse(startedAtStr);
              if (startedAt != null) {
                startedAtMillis = startedAt.millisecondsSinceEpoch;
              }
            }
            LocalNotificationService.showOngoingChatNotification(
        sessionId: sessionId,
        title: 'Chat in progress',
        body: 'Active chat with $userName',
        startedAtMillis: startedAtMillis,
      );
          }
        }
      }
    });
  }

  void _setupTimer(String? startedAtString) {
    _timer?.cancel();
    final startedAtStr = startedAtString ?? WebSocketService.sessionStartTimes[_sessionId];
    if (startedAtStr != null) {
      final startedAt = DateTime.tryParse(startedAtStr);
      if (startedAt != null) {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          elapsedSeconds.value = DateTime.now().difference(startedAt).inSeconds;
        });
      }
    }
  }

  Future<void> loadHistory() async {
    if (_sessionId == null || _currentUserId == null) return;
    isLoading.value = true;
    try {
      final result = await _loadChatHistoryUseCase.execute(
        sessionId: _sessionId!,
        currentUserId: _currentUserId!,
      );
      messages.assignAll(result.messages);
      if (result.startedAt != null) {
        _startedAt = result.startedAt;
        _setupTimer(result.startedAt);
      }
      _scrollToBottom();
      markRead();
    } catch (e) {
      debugPrint("Error loading chat history: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendTextMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || _sessionId == null) return;

    messageController.clear();

    // Local temporary ID for UI responsiveness
    final tempId = DateTime.now().millisecondsSinceEpoch;
    final localMsg = ChatMessage(
      id: tempId,
      text: text,
      isMe: true,
      time: DateTime.now(),
      status: 'sending...',
      type: 'text',
    );
    messages.add(localMsg);
    _scrollToBottom();

    try {
      final serverId = await _sendTextMessageUseCase.execute(
        sessionId: _sessionId!,
        text: text,
      );

      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        if (serverId != null) {
          messages[index] = messages[index].copyWith(id: serverId, status: 'sent');
        } else {
          messages[index] = messages[index].copyWith(status: 'failed');
        }
      }
    } catch (_) {
      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(status: 'failed');
      }
    }
  }

  Future<void> sendImageAttachment(XFile xFile) async {
    if (_sessionId == null) return;

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
    messages.add(localMsg);
    _scrollToBottom();

    try {
      final result = await _sendAttachmentUseCase.executeImage(
        sessionId: _sessionId!,
        file: xFile,
      );

      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        if (result != null) {
          messages[index] = messages[index].copyWith(
            id: result!.id,
            status: 'sent',
            attachmentUrl: result!.url,
            image: result!.url,
          );
        } else {
          messages[index] = messages[index].copyWith(status: 'failed');
        }
      }
    } catch (_) {
      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(status: 'failed');
      }
    }
  }

  Future<void> sendDocumentAttachment(PlatformFile platformFile) async {
    if (_sessionId == null) return;

    final tempId = DateTime.now().millisecondsSinceEpoch;
    final localMsg = ChatMessage(
      id: tempId,
      text: '📄 ${platformFile.name}',
      isMe: true,
      time: DateTime.now(),
      status: 'sending...',
      type: 'document',
    );
    messages.add(localMsg);
    _scrollToBottom();

    try {
      final pickerResult = FilePickerResult([platformFile]);
      final result = await _sendAttachmentUseCase.executeDocument(
        sessionId: _sessionId!,
        fileName: platformFile.name,
        result: pickerResult,
      );

      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        if (result != null) {
          messages[index] = messages[index].copyWith(
            id: result!.id,
            status: 'sent',
            attachmentUrl: result!.url,
          );
        } else {
          messages[index] = messages[index].copyWith(status: 'failed');
        }
      }
    } catch (_) {
      final index = messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(status: 'failed');
      }
    }
  }

  Future<void> markRead() async {
    if (_sessionId == null) return;
    try {
      await _markMessagesReadUseCase.execute(_sessionId!);
    } catch (e) {
      debugPrint("Error marking messages read: $e");
    }
  }

  Future<void> endChatSession() async {
    if (_sessionId == null) return;
    isLoading.value = true;
    try {
      final session = await _endChatSessionUseCase.execute(_sessionId!);
      status.value = 'ended';
      _timer?.cancel();
      FloatingChatBubble.dismiss();
      if (session != null) {
        ChatSummaryDialog.show(
          sessionId: session.id,
          durationSeconds: session.durationSeconds,
          totalCost: session.totalCost,
        );
      }
    } catch (e) {
      debugPrint("Error ending chat session: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptChat(int incomingSessionId) async {
    try {
      final response = await ApiClient.post(
        AppUrls.acceptChatSession(incomingSessionId),
      );
      if (response.success) {
        // Find user data to open screen or let WebSocket handle it
      }
    } catch (e) {
      debugPrint("Error accepting chat: $e");
    }
  }

  Future<void> rejectChat(int incomingSessionId) async {
    try {
      await ApiClient.post(
        AppUrls.rejectChatSession(incomingSessionId),
      );
    } catch (e) {
      debugPrint("Error rejecting chat: $e");
    }
  }

  void minimizeToBubble(BuildContext context, String name, String image, {bool shouldPop = true}) {
    if (_sessionId == null) return;
    WebSocketService.activeSessionId = null;
    FloatingChatBubble.show(
      context: context,
      sessionId: _sessionId!,
      name: name,
      imageUrl: image,
      startedAt: _startedAt ?? WebSocketService.sessionStartTimes[_sessionId],
      status: status.value,
      onTap: () {
        final currentStatus = FloatingChatBubble.chatStatus.value;
        final startedAtStr = WebSocketService.sessionStartTimes[_sessionId!];
        FloatingChatBubble.dismiss();
        Get.to(
          () => ChatScreen(
            userName: name,
            userImage: image,
            sessionId: _sessionId!,
            initialStatus: currentStatus,
            startedAtString: startedAtStr,
          ),
          binding: ChatBinding(),
        );
      },
    );
    if (shouldPop) {
      Navigator.of(context).pop();
    }
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
    _timer?.cancel();
    _msgSub?.cancel();
    _endSub?.cancel();
    _statusSub?.cancel();
    _dismissSub?.cancel();
    if (WebSocketService.activeSessionId == _sessionId) {
      WebSocketService.activeSessionId = null;
    }
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
