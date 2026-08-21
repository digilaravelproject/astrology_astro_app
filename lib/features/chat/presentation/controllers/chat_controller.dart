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
import 'package:astro_astrologer/features/auth/controllers/auth_controller.dart';
import 'package:astro_astrologer/core/services/foreground_task_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';

class ChatController extends GetxController with WidgetsBindingObserver {
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
  int? _peerId;
  String? _userName;
  Timer? _timer;
  String? _startedAt;
  StreamSubscription? _msgSub;
  StreamSubscription? _endSub;
  StreamSubscription? _statusSub;
  StreamSubscription? _dismissSub;
  StreamSubscription? _statusUpdateSub;

  int? get sessionId => _sessionId;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    ForegroundTaskService.listenTaskData((data) {
      if (data is Map && data['action'] == 'hangup') {
        if (_sessionId != null) {
          endChatSession();
        }
      }
    });
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if ((status.value == 'ongoing' || status.value == 'initiated') && _sessionId != null && _userName != null) {
        minimizeToBubble(Get.context!, _userName!, "", shouldPop: false);
      }
    } else if (state == AppLifecycleState.resumed) {
      FloatingChatBubble.dismiss(stopForegroundService: false);
    }
  }

  void initSession({
    required int sessionId,
    required int currentUserId,
    required String initialStatus,
    required String userName,
    String? startedAtString,
  }) {
    if (_sessionId != sessionId) {
      messages.clear();
      _sessionId = sessionId;
    }
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
    if (status.value == 'ongoing' || status.value == 'initiated' || status.value == 'ringing') {
      LocalNotificationService.showOngoingChatNotification(
        sessionId: sessionId,
        title: status.value == 'ongoing' ? 'Active Chat with $userName' : 'Incoming Chat Request from $userName',
        body: 'Tap to return to chat session',
        startedAtMillis: startedAtMillis,
      );
    }

    ever(status, (val) {
      if (FloatingChatBubble.isActive && FloatingChatBubble.sessionId == _sessionId) {
        FloatingChatBubble.updateStatus(val);
      }
    });

    _msgSub?.cancel();
    _msgSub = WebSocketService.incomingMessages.listen((list) {
      if (list.isNotEmpty) {
        final lastMsg = list.last;
        final msgSessionId = int.tryParse(lastMsg['chat_session_id']?.toString() ?? '') ?? 0;
        final int senderId = int.tryParse(lastMsg['sender_id']?.toString() ?? '') ?? 0;
        final int receiverId = int.tryParse(lastMsg['receiver_id']?.toString() ?? '') ?? 0;
        
        final isSameUserPair = (_peerId != null && _currentUserId != null) &&
            ((senderId == _currentUserId && receiverId == _peerId) || 
             (senderId == _peerId && receiverId == _currentUserId));

        if (msgSessionId == _sessionId || isSameUserPair) {
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

    // Listen to WebSocket Message Status Updates (delivered/seen)
    _statusUpdateSub?.cancel();
    _statusUpdateSub = WebSocketService.messageStatusUpdates.listen((list) {
      if (list.isNotEmpty) {
        final lastUpdate = list.last;
        final updateSessionId = int.tryParse(lastUpdate['session_id']?.toString() ?? '') ?? 0;
        if (updateSessionId == _sessionId) {
          final newStatus = lastUpdate['status']?.toString();
          final messageIdsList = lastUpdate['message_ids'] as List<dynamic>?;
          if (newStatus != null && messageIdsList != null && messageIdsList.isNotEmpty) {
            final messageIds = messageIdsList.map((e) => int.tryParse(e.toString()) ?? 0).toList();
            bool changed = false;
            for (int i = 0; i < messages.length; i++) {
              if (messageIds.contains(messages[i].id)) {
                if (messages[i].status != 'seen') {
                   messages[i] = messages[i].copyWith(status: newStatus);
                   changed = true;
                }
              }
            }
            if (changed) {
              messages.refresh();
            }
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
        if (Get.isRegistered<AuthController>()) {
          Get.find<AuthController>().checkLoginStatus();
        }
        // Pop the chat screen so it doesn't stay open
        Future.delayed(const Duration(milliseconds: 400), () {
          if (Get.currentRoute.isNotEmpty) {
            if (Get.isRegistered<ChatController>()) {
              Get.back();
            }
          }
        });
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
        // CustomSnackBar.disabledSnackbar("Chat Cancelled", "The chat request was cancelled or timed out.");
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

  DateTime? _parseSmartDate(dynamic input) {
    if (input == null) return null;
    if (input is DateTime) return input;
    final dateStr = input.toString().trim();
    if (dateStr.isEmpty) return null;

    DateTime? parsed;
    try {
      parsed = DateTime.tryParse(dateStr.replaceAll(' ', 'T'));
    } catch (_) {}

    if (parsed == null) {
      try {
        parsed = DateTime.tryParse(dateStr);
      } catch (_) {}
    }

    if (parsed == null) return null;

    final now = DateTime.now();

    if (parsed.isAfter(now)) {
      String isoUtc = dateStr.replaceAll(' ', 'T');
      if (!isoUtc.endsWith('Z') && !isoUtc.contains('+')) {
        isoUtc += 'Z';
      }
      final utcDate = DateTime.tryParse(isoUtc)?.toLocal();
      if (utcDate != null && !utcDate.isAfter(now)) {
        return utcDate;
      }
      final offsetDate = parsed.subtract(now.timeZoneOffset);
      if (!offsetDate.isAfter(now)) {
        return offsetDate;
      }
    }

    return parsed;
  }

  String _formatDuration(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _setupTimer(String? startedAtString) {
    _timer?.cancel();
    final currentSt = status.value.toLowerCase();
    if (currentSt == 'ended' || currentSt == 'completed' || currentSt == 'cancelled' || currentSt == 'rejected') return;

    if (startedAtString != null && _sessionId != null) {
      _startedAt = startedAtString;
      WebSocketService.sessionStartTimes[_sessionId!] = startedAtString;
    }

    final startedAtStr = startedAtString ?? _startedAt ?? (_sessionId != null ? WebSocketService.sessionStartTimes[_sessionId] : null);
    final startedAt = _parseSmartDate(startedAtStr);

    if (startedAt != null) {
      final diff = DateTime.now().difference(startedAt).inSeconds;
      elapsedSeconds.value = diff >= 0 ? diff : 0;

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final st = status.value.toLowerCase();
        if (st == 'ended' || st == 'completed' || st == 'cancelled' || st == 'rejected') {
          timer.cancel();
          return;
        }
        final nowDiff = DateTime.now().difference(startedAt).inSeconds;
        if (nowDiff >= 0) {
          elapsedSeconds.value = nowDiff;
        } else {
          elapsedSeconds.value++;
        }
      });
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final st = status.value.toLowerCase();
        if (st == 'ended' || st == 'completed' || st == 'cancelled' || st == 'rejected') {
          timer.cancel();
          return;
        }
        if (st == 'ongoing' || st == 'accepted') {
          elapsedSeconds.value++;
          if (_sessionId != null) {
            final genStart = DateTime.now().subtract(Duration(seconds: elapsedSeconds.value)).toIso8601String();
            _startedAt = genStart;
            WebSocketService.sessionStartTimes[_sessionId!] = genStart;
          }
        }
      });
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
      _peerId = result.peerId;
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

  String _getLatestStatus(int messageId, String defaultStatus) {
    String currentStatus = defaultStatus;
    for (var event in WebSocketService.messageStatusUpdates) {
      if (event['session_id'] == _sessionId && event['message_id'] == messageId) {
        currentStatus = event['status'];
      }
    }
    return currentStatus;
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
          final newStatus = _getLatestStatus(serverId, 'sent');
          messages[index] = messages[index].copyWith(id: serverId, status: newStatus);
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
          final newStatus = _getLatestStatus(result.id, 'sent');
          messages[index] = messages[index].copyWith(
            id: result.id,
            status: newStatus,
            image: result.url,
            attachmentUrl: result.url,
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
          final newStatus = _getLatestStatus(result.id, 'sent');
          messages[index] = messages[index].copyWith(
            id: result.id,
            status: newStatus,
            attachmentUrl: result.url,
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
      LocalNotificationService.cancelOngoingChatNotification(_sessionId!);
      FloatingChatBubble.dismiss();
      if (session != null) {
        WebSocketService.activeSessionId = null;
      }
    } catch (e) {
      debugPrint("Error ending chat session: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptChat(int incomingSessionId) async {
    try {
      final response = await Get.find<ApiClient>().post(
        AppUrls.acceptChatSession(incomingSessionId),
      );
      if (response.isSuccess) {
        // Find user data to open screen or let WebSocket handle it
      }
    } catch (e) {
      debugPrint("Error accepting chat: $e");
    }
  }

  Future<void> rejectChat(int incomingSessionId) async {
    try {
      LocalNotificationService.cancelOngoingChatNotification(incomingSessionId);
      FloatingChatBubble.dismiss(stopForegroundService: true);
      await Get.find<ApiClient>().post(
        AppUrls.rejectChatSession(incomingSessionId),
      );
    } catch (e) {
      debugPrint("Error rejecting chat: $e");
    }
  }

  void minimizeToBubble(BuildContext context, String name, String image, {bool shouldPop = true}) {
    debugPrint("==== [FLOATING_CHAT_DEBUG] Astrologer ChatController.minimizeToBubble called! sessionId=$_sessionId, status=${status.value}, shouldPop=$shouldPop ====");
    if (_sessionId == null || (status.value != 'ongoing' && status.value != 'initiated')) {
      debugPrint("==== [FLOATING_CHAT_DEBUG] Astrologer minimizeToBubble SKIPPED because sessionId is null or status invalid ====");
      return;
    }
    WebSocketService.activeSessionId = null;
    final startStr = _startedAt ?? WebSocketService.sessionStartTimes[_sessionId!] ?? DateTime.now().subtract(Duration(seconds: elapsedSeconds.value)).toIso8601String();
    WebSocketService.sessionStartTimes[_sessionId!] = startStr;

    FloatingChatBubble.show(
      context: context,
      sessionId: _sessionId!,
      name: name,
      imageUrl: image,
      startedAt: startStr,
      status: status.value,
      onTap: () {
        final currentStatus = FloatingChatBubble.chatStatus.value;
        debugPrint("==== [FLOATING_CHAT_DEBUG] Astrologer FloatingChatBubble tapped! Navigating back to ChatScreen for sessionId=$_sessionId ====");
        FloatingChatBubble.dismiss(stopForegroundService: false);
        Get.to(
          () => ChatScreen(
            userName: name,
            userImage: image,
            sessionId: _sessionId!,
            initialStatus: currentStatus,
            startedAtString: startStr,
          ),
          binding: ChatBinding(),
        );
      },
    );
    if (shouldPop) {
      Get.back();
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
    debugPrint("==== [FLOATING_CHAT_DEBUG] Astrologer ChatController.onClose invoked! sessionId=$_sessionId, status=${status.value} ====");
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _msgSub?.cancel();
    _endSub?.cancel();
    _statusSub?.cancel();
    _dismissSub?.cancel();
    
    // Only dismiss notification & bubble if session is actually ended/completed
    if (status.value == 'ended' || status.value == 'completed' || status.value == 'cancelled' || status.value == 'rejected') {
      debugPrint("==== [FLOATING_CHAT_DEBUG] Astrologer Session is TERMINATED (${status.value}). Dismissing bubble & cancelling ongoing notification for sessionId=$_sessionId ====");
      if (_sessionId != null) {
        LocalNotificationService.cancelOngoingChatNotification(_sessionId!);
      } else {
        LocalNotificationService.cancelOngoingChatNotification(null);
      }
      FloatingChatBubble.dismiss(stopForegroundService: true);
      if (WebSocketService.activeSessionId == _sessionId) {
        WebSocketService.activeSessionId = null;
      }
    } else {
      debugPrint("==== [FLOATING_CHAT_DEBUG] Astrologer ChatController closed while session active (${status.value}). PRESERVING BUBBLE AND NOTIFICATION! ====");
    }
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
