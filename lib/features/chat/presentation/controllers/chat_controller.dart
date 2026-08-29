import 'package:astro_astrologer/core/services/local_notification_service.dart';
import 'dart:async';
import 'dart:io';
import 'package:astro_astrologer/core/enums/session_status_enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:astro_astrologer/core/services/network/websocket_service.dart';
import 'package:astro_astrologer/features/chat/domain/entities/chat_message.dart';
import 'package:astro_astrologer/features/chat/data/models/chat_message_model.dart';
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
import 'package:astro_astrologer/core/services/sound_vibration_service.dart';

import 'package:astro_astrologer/features/chat/presentation/widgets/chat_summary_dialog.dart';
import 'package:astro_astrologer/features/chat/presentation/bindings/chat_binding.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/features/auth/controllers/auth_controller.dart';
import 'package:astro_astrologer/core/services/foreground_task_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';
import 'package:astro_astrologer/features/chat/presentation/widgets/incoming_chat_dialog.dart';
import 'package:astro_astrologer/core/utils/logger.dart';

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

  // ── Sound helpers ────────────────────────────────────────────
  /// Play incoming ring so astrologer hears a new chat request.
  void _startRingtone() {
    SoundVibrationService().startRingtone('audio/astrolger_app_sound.mp3', loop: true, vibrate: true);
    debugPrint('[ChatController] Astrologer ringtone started → astrolger_app_sound.mp3');
  }

  /// Stop ringtone — called on accept OR reject.
  void _stopRingtone() {
    SoundVibrationService().stopRingtone();
    debugPrint('[ChatController] Astrologer ringtone stopped');
  }

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<ChatStatus> status = ChatStatus.pending.obs; // ongoing, ended
  final RxInt elapsedSeconds = 0.obs;

  final Rx<ChatMessage?> replyingToMessage = Rx<ChatMessage?>(null);

  void setReply(ChatMessage message) {
    replyingToMessage.value = message;
  }

  void cancelReply() {
    replyingToMessage.value = null;
  }

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
  int? get peerId => _peerId;
  
  // Prepaid Package session info
  bool isPackageChat = false;
  bool isCallAlsoActive = false;
  int? subSessionId;

  // ─── Hybrid Package: Granular Channel Termination (Astrologer Chat Screen)

  /// End Chat Only — terminates chat channel but keeps call active
  Future<void> terminateChannelOnly() async {
    final subId = subSessionId;
    if (subId == null) {
      Logger.e('ChatController: terminateChannelOnly — no active subSessionId found');
      return;
    }
    try {
      isLoading.value = true;
      await Get.find<ApiClient>().post(
        AppUrls.packageTerminateChannel,
        data: {
          'sub_session_id': subId,
          'channel_type': 'chat',
          'action': 'channel_only',
        },
      );
      Logger.d('ChatController: terminateChannelOnly success.');
      
      // Update local state to show chat is ended/completed
      status.value = ChatStatus.completed;
      _timer?.cancel();
      if (_sessionId != null) {
        LocalNotificationService.cancelOngoingChatNotification(_sessionId!);
      }
      FloatingChatBubble.dismiss();
      WebSocketService.activeSessionId = null;
      
      // Navigate back
      Get.back();
    } catch (e) {
      Logger.e('ChatController: Error in terminateChannelOnly -> $e');
      CustomSnackBar.showError('Failed to end chat. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  /// End Entire Session — terminates both chat and call channels
  Future<void> terminateEntireSession() async {
    final subId = subSessionId;
    if (subId == null) {
      // Fallback
      await endChatSession();
      return;
    }
    try {
      isLoading.value = true;
      await Get.find<ApiClient>().post(
        AppUrls.packageTerminateChannel,
        data: {
          'sub_session_id': subId,
          'channel_type': 'chat',
          'action': 'complete_session',
        },
      );
      Logger.d('ChatController: terminateEntireSession success.');
      
      status.value = ChatStatus.completed;
      _timer?.cancel();
      if (_sessionId != null) {
        LocalNotificationService.cancelOngoingChatNotification(_sessionId!);
      }
      FloatingChatBubble.dismiss();
      WebSocketService.activeSessionId = null;
      
      Get.back();
    } catch (e) {
      Logger.e('ChatController: Error in terminateEntireSession -> $e');
      await endChatSession();
    } finally {
      isLoading.value = false;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────

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
      if ((status.value == ChatStatus.ongoing || status.value == ChatStatus.initiated) && _sessionId != null && _userName != null) {
        minimizeToBubble(Get.context!, _userName!, "", shouldPop: false);
      }
    } else if (state == AppLifecycleState.resumed) {
      // Check for any pending initiated chat sessions and show the incoming dialog
      _checkPendingChatSession();
    }
  }

  /// When astrologer resumes app from background, check if there's a
  /// pending chat session waiting to be accepted/rejected.
  Future<void> _checkPendingChatSession() async {
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.get(
        AppUrls.getCurrentSession,
        handleError: false,
        showErrorScreen: false,
      );
      if (!response.isSuccess || response.body == null) return;

      final body = response.body;
      final sessionData = body is Map
          ? (body['session'] ?? body['data']?['session'] ?? body['data'])
          : null;
      if (sessionData == null) return;

      final String sessionStatus = sessionData['status']?.toString() ?? '';
      if (sessionStatus != 'initiated') return;

      // Already handling this session
      final int incomingId = int.tryParse(sessionData['id']?.toString() ?? '') ?? 0;
      if (incomingId == 0) return;
      if (status.value == ChatStatus.initiated && _sessionId == incomingId) return;

      // Extract sender data
      final senderData = sessionData['consumer'] ?? sessionData['user'] ?? {};

      // Show IncomingChatDialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isBottomSheetOpen == true) return; // Already showing
        // Close any open dialogs before showing incoming chat
        if (Get.isDialogOpen == true) Get.back();
        Get.bottomSheet(
          IncomingChatDialog(
            sessionData: Map<String, dynamic>.from(sessionData),
            senderData: Map<String, dynamic>.from(senderData),
          ),
          isDismissible: false,
          enableDrag: false,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
        );
      });
    } catch (e) {
      // Silently fail — not critical
    }
  }

  void initSession({
    required int sessionId,
    required int currentUserId,
    required String initialStatus,
    required String userName,
    String? startedAtString,
    bool isPackage = false,
    int? activeSubSessionId,
  }) {
    isPackageChat = isPackage;
    subSessionId = activeSubSessionId;

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
    status.value = ChatStatus.values.firstWhere(
      (e) => e.name == initialStatus,
      orElse: () => ChatStatus.ongoing,
    );
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
    if (status.value == ChatStatus.ongoing || status.value == ChatStatus.initiated || status.value == ChatStatus.initiated) {
      // Astrologer side: play ring when a new chat request arrives
      if (status.value == ChatStatus.initiated || status.value == ChatStatus.initiated) {
        _startRingtone();
      }
      LocalNotificationService.showOngoingChatNotification(
        sessionId: sessionId,
        title: status.value == ChatStatus.ongoing ? 'Chat in progress' : 'Waiting for acceptance...',
        body: 'Active chat with $userName',
        startedAtMillis: status.value == ChatStatus.ongoing ? startedAtMillis : null,
      );
    }

    ever(status, (val) {
      if (FloatingChatBubble.isActive && FloatingChatBubble.sessionId == _sessionId) {
        FloatingChatBubble.updateStatus(val.name);
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

          final int msgId = int.tryParse(lastMsg['id']?.toString() ?? '') ?? 0;
          final String msgText = lastMsg['message']?.toString() ?? '';
          final String msgType = lastMsg['type']?.toString() ?? 'text';

          // Guard: already in list with the real server id → skip
          if (messages.any((m) => m.id == msgId)) return;

          if (isMe) {
            // ── My own message echoed back from WebSocket ──────────────────
            // Find the optimistic placeholder (status='sending...', same text, or same type if image/file)
            // and upgrade it in-place to prevent duplicate.
            final pendingIndex = messages.indexWhere(
              (m) => m.isMe && m.status == 'sending...' && 
                     (m.text == msgText || 
                      m.text.replaceAll('<<reply<<', '') == msgText.replaceAll('<<reply<<', '') ||
                      (m.type == 'image' && msgType == 'image') || 
                      (m.type == 'file' && msgType == 'file')),
            );
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
              // No placeholder (e.g. sent from another device) — add normally
              messages.add(ChatMessageModel.fromJson(lastMsg, currentUserId: _currentUserId!));
              _scrollToBottom();
            }
          } else {
            // ── Message from the other side ────────────────────────────────
            messages.add(ChatMessageModel.fromJson(lastMsg, currentUserId: _currentUserId!));
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
        bool changed = false;
        for (var lastUpdate in list) {
          final updateSessionId = int.tryParse(
            lastUpdate['session_id']?.toString() ?? 
            lastUpdate['chat_session_id']?.toString() ?? 
            lastUpdate['chat_assistance_session_id']?.toString() ?? 
            lastUpdate['sessionId']?.toString() ?? ''
          ) ?? 0;
          if (updateSessionId == _sessionId) {
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
        if (changed) {
          messages.refresh();
        }
      }
    });

    // Listen to WebSocket Chat Ended Event
    _endSub?.cancel();
    _endSub = WebSocketService.chatEndedSessionId.listen((endedSessionId) {
      if (endedSessionId == _sessionId) {
        status.value = ChatStatus.completed;
        _stopRingtone();
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
        status.value = ChatStatus.completed; // or 'dismissed'
        _stopRingtone();
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
        if (newStatus != null && status.value.name != newStatus) {
          status.value = ChatStatus.ongoing;
          if (newStatus == 'ongoing' || newStatus == 'accepted') {
            _stopRingtone();
            final startedAtStr = WebSocketService.sessionStartTimes[_sessionId];
            DateTime? serverStartTime;
            if (startedAtStr != null && startedAtStr.isNotEmpty) {
              String isoUtc = startedAtStr.trim().replaceAll(' ', 'T');
              if (!isoUtc.endsWith('Z') && !isoUtc.contains('+') && !isoUtc.contains('-')) {
                isoUtc += 'Z';
              }
              serverStartTime = DateTime.tryParse(isoUtc)?.toLocal();
            }
            
            final effectiveStart = serverStartTime ?? DateTime.now();
            _startedAt = effectiveStart.toIso8601String();
            if (_sessionId != null) {
              WebSocketService.sessionStartTimes[_sessionId!] = _startedAt!;
            }
            final diff = DateTime.now().difference(effectiveStart).inSeconds;
            elapsedSeconds.value = diff >= 0 ? diff : 0;

            _setupTimer(_startedAt);
            ForegroundTaskService.startService(
              title: 'Chat in progress',
              text: 'Active chat with ${_userName ?? 'User'}',
            );
            
            final startedAtMillis = effectiveStart.millisecondsSinceEpoch;
            LocalNotificationService.showOngoingChatNotification(
              sessionId: _sessionId!,
              title: 'Chat in progress',
              body: 'Active chat with ${_userName ?? 'User'}',
              startedAtMillis: startedAtMillis,
            );
          }
        }
      }
    });
  }

  DateTime? _parseSmartDate(dynamic input) {
    if (input == null) return null;
    if (input is DateTime) return input.toLocal();
    final dateStr = input.toString().trim();
    if (dateStr.isEmpty) return null;

    String isoUtc = dateStr.replaceAll(' ', 'T');
    if (!isoUtc.endsWith('Z') && !isoUtc.contains('+') && !isoUtc.contains('-')) {
      isoUtc += 'Z';
    }
    final utcDate = DateTime.tryParse(isoUtc)?.toLocal();
    if (utcDate != null) {
      final now = DateTime.now();
      if (!utcDate.isAfter(now)) {
        return utcDate;
      }
    }

    DateTime? parsed = DateTime.tryParse(dateStr.replaceAll(' ', 'T')) ?? DateTime.tryParse(dateStr);
    if (parsed == null) return null;
    return parsed.toLocal();
  }

  String _formatDuration(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _setupTimer(String? startedAtString) {
    _timer?.cancel();
    final currentSt = status.value.name.toLowerCase();
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
        final st = status.value.name.toLowerCase();
        if (st == 'ended' || st == 'completed' || st == 'cancelled' || st == 'rejected') {
          timer.cancel();
          return;
        }
        if (st == 'ongoing' || st == 'accepted') {
          final nowDiff = DateTime.now().difference(startedAt).inSeconds;
          if (nowDiff >= 0) {
            elapsedSeconds.value = nowDiff;
          } else {
            elapsedSeconds.value++;
          }
        } else {
          elapsedSeconds.value = 0;
        }
      });
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final st = status.value.name.toLowerCase();
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
      if (result.startedAt != null && (status.value == ChatStatus.ongoing || status.value == ChatStatus.ongoing)) {
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
      final updateSessionId = int.tryParse(
        event['session_id']?.toString() ?? 
        event['chat_session_id']?.toString() ?? 
        event['chat_assistance_session_id']?.toString() ?? 
        event['sessionId']?.toString() ?? ''
      ) ?? 0;
      if (updateSessionId == _sessionId) {
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
    if (text.isEmpty || _sessionId == null) return;

    final replyToMessage = replyingToMessage.value;
    final replyToId = replyToMessage?.id;
    
    cancelReply();
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
      replyToId: replyToId,
      replyTo: replyToMessage,
    );
    messages.add(localMsg);
    _scrollToBottom();

    try {
      final serverId = await _sendTextMessageUseCase.execute(
        sessionId: _sessionId!,
        text: text,
        replyToId: replyToId,
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

  Future<void> rejectChatSession() async {
    _stopRingtone(); // Stop ring immediately on reject
    if (_sessionId == null) {
      Get.back();
      return;
    }
    final targetId = _sessionId!;
    status.value = ChatStatus.completed;
    _timer?.cancel();
    ForegroundTaskService.stopService();
    LocalNotificationService.cancelOngoingChatNotification(targetId);
    FloatingChatBubble.dismiss();
    
    // Immediately close screen for smooth UX
    if (Get.isRegistered<ChatController>()) {
      Get.back();
    }

    try {
      await Get.find<ApiClient>().post(AppUrls.rejectChatSession(targetId));
    } catch (e) {
      debugPrint("Error rejecting/cancelling chat session: $e");
    } finally {
      LocalNotificationService.cancelOngoingChatNotification(targetId);
      FloatingChatBubble.dismiss();
    }
  }

  Future<void> endChatSession() async {
    if (_sessionId == null) return;
    isLoading.value = true;
    try {
      final session = await _endChatSessionUseCase.execute(_sessionId!);
      if (session != null) {
        WebSocketService.activeSessionId = null;
      }
    } catch (e) {
      debugPrint("Error ending chat session: $e");
    } finally {
      isLoading.value = false;
      status.value = ChatStatus.completed;
      _timer?.cancel();
      LocalNotificationService.cancelOngoingChatNotification(_sessionId!);
      FloatingChatBubble.dismiss();
    }
  }

  Future<void> acceptChat(int incomingSessionId) async {
    _stopRingtone(); // Stop ring immediately on accept
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
    debugPrint("==== [FLOATING_CHAT_DEBUG] Astrologer ChatController.minimizeToBubble called! sessionId=$_sessionId, status=${status.value.name}, shouldPop=$shouldPop ====");
    if (_sessionId == null || (status.value != ChatStatus.ongoing && status.value != ChatStatus.initiated)) {
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
      status: status.value.name,
      onTap: () async {
        FloatingChatBubble.dismiss(stopForegroundService: false);

        // Fetch current session status from API
        String liveStatus = 'ongoing'; // default fallback
        Map<String, dynamic> liveSession = {};
        Map<String, dynamic> liveSender = {};

        try {
          final apiClient = Get.find<ApiClient>();
          final response = await apiClient.get(
            AppUrls.getCurrentSession,
            handleError: false,
            showErrorScreen: false,
          );
          if (response.isSuccess && response.body != null) {
            final body = response.body;
            final raw = body is Map
                ? (body['session'] ?? body['data']?['session'] ?? body['data'])
                : null;
            if (raw != null) {
              liveSession = Map<String, dynamic>.from(raw);
              liveStatus = liveSession['status']?.toString() ?? 'ongoing';
              final sd = liveSession['consumer'] ?? liveSession['user'];
              if (sd != null) liveSender = Map<String, dynamic>.from(sd);
            }
          }
        } catch (_) {}

        if (liveStatus == 'initiated') {
          // Chat is still ringing — show IncomingChatDialog
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Get.isBottomSheetOpen == true) return;
            if (liveSession.isEmpty && _sessionId != null) {
              liveSession = {'id': _sessionId, 'status': 'initiated'};
            }
            if (liveSender.isEmpty) {
              liveSender = WebSocketService.lastChatSenderData ?? {'name': name, 'profile_photo': image};
            }
            Get.bottomSheet(
              IncomingChatDialog(
                sessionData: liveSession,
                senderData: liveSender,
              ),
              isDismissible: false,
              enableDrag: false,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
            );
          });
        } else {
          // Chat is ongoing — go to ChatScreen
          final sessionId = liveSession['id'] != null
              ? int.tryParse(liveSession['id'].toString()) ?? _sessionId!
              : _sessionId!;
          Get.to(
            () => ChatScreen(
              userName: name,
              userImage: image,
              sessionId: sessionId,
              initialStatus: liveStatus,
              startedAtString: startStr,
            ),
            binding: ChatBinding(),
          );
        }
      },
    );
    if (shouldPop) {
      Get.back();
    }
  }

  /// Fetch current session data and show IncomingChatDialog for initiated/ringing state
  Future<void> _showIncomingChatDialog(String name, String image) async {
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.get(
        AppUrls.getCurrentSession,
        handleError: false,
        showErrorScreen: false,
      );
      Map<String, dynamic> sessionData = {};
      Map<String, dynamic> senderData = {};

      if (response.isSuccess && response.body != null) {
        final body = response.body;
        final raw = body is Map
            ? (body['session'] ?? body['data']?['session'] ?? body['data'])
            : null;
        if (raw != null) {
          sessionData = Map<String, dynamic>.from(raw);
          final sd = sessionData['consumer'] ?? sessionData['user'];
          if (sd != null) senderData = Map<String, dynamic>.from(sd);
        }
      }

      // Fallback: build minimal data from what we already have
      if (sessionData.isEmpty && _sessionId != null) {
        sessionData = {'id': _sessionId, 'status': 'initiated'};
      }
      if (senderData.isEmpty) {
        senderData = WebSocketService.lastChatSenderData ?? {'name': name, 'profile_photo': image};
      }

      if (sessionData.isNotEmpty) {
        Get.bottomSheet(
          IncomingChatDialog(
            sessionData: sessionData,
            senderData: senderData,
          ),
          isDismissible: false,
          enableDrag: false,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
        );
      }
    } catch (e) {
      debugPrint('[ChatController] _showIncomingChatDialog error: $e');
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
    debugPrint("==== [FLOATING_CHAT_DEBUG] Astrologer ChatController.onClose invoked! sessionId=$_sessionId, status=${status.value.name} ====");
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _msgSub?.cancel();
    _endSub?.cancel();
    _statusSub?.cancel();
    _dismissSub?.cancel();
    
    // Only dismiss notification & bubble if session is actually ended/completed
    if (status.value == ChatStatus.completed || status.value == ChatStatus.completed || status.value == ChatStatus.cancelled || status.value == ChatStatus.rejected) {
      debugPrint("==== [FLOATING_CHAT_DEBUG] Astrologer Session is TERMINATED (${status.value.name}). Dismissing bubble & cancelling ongoing notification for sessionId=$_sessionId ====");
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
      debugPrint("==== [FLOATING_CHAT_DEBUG] Astrologer ChatController closed while session active (${status.value.name}). PRESERVING BUBBLE AND NOTIFICATION! ====");
    }
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
