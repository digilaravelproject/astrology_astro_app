import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:astro_astrologer/features/chat/domain/entities/chat_message.dart';
import 'package:astro_astrologer/core/enums/session_status_enums.dart';
import 'package:astro_astrologer/core/services/websocket/websocket_service.dart';
import 'package:astro_astrologer/core/services/foreground_task_service.dart';
import 'package:astro_astrologer/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_astrologer/core/services/storage/shared_prefs.dart';
import 'package:astro_astrologer/core/constants/app_constants.dart';
import 'package:astro_astrologer/features/auth/data/models/user_model.dart';
import 'chat_session_controller.dart';
import 'chat_message_controller.dart';

class ChatController extends GetxController {
  final ChatSessionController session;
  final ChatMessageController messaging;

  ChatController({required this.session, required this.messaging});

  // Orchestrator State
  int? sessionId;
  int? currentUserId;
  int? peerId;
  String? userName;

  // Delegates for backward compatibility
  RxList<ChatMessage> get messages => messaging.messages;
  RxBool get isLoading => session.isLoading;
  Rx<ChatStatus> get status => session.status;
  RxInt get elapsedSeconds => session.elapsedSeconds;
  RxInt get currentPingMs => WebSocketService.currentPingMs;
  Rx<ChatMessage?> get replyingToMessage => messaging.replyingToMessage;
  TextEditingController get messageController => messaging.messageController;
  ScrollController get scrollController => messaging.scrollController;

  bool get isPackageChat => session.isPackageChat;
  set isPackageChat(bool val) => session.isPackageChat = val;
  bool get isCallAlsoActive => session.isCallAlsoActive;
  set isCallAlsoActive(bool val) => session.isCallAlsoActive = val;
  int? get subSessionId => session.subSessionId;
  set subSessionId(int? val) => session.subSessionId = val;

  void initSession({
    required int sessionId,
    required int currentUserId,
    required String initialStatus,
    required String userName,
    String? startedAtString,
    bool isPackage = false,
    int? activeSubSessionId,
  }) {
    session.isPackageChat = isPackage;
    session.subSessionId = activeSubSessionId;

    if (this.sessionId != sessionId) {
      messaging.messages.clear();
      this.sessionId = sessionId;
    }
    
    if (currentUserId != 0) {
      this.currentUserId = currentUserId;
    } else {
      this.currentUserId = WebSocketService.currentUserId;
      if (this.currentUserId == null || this.currentUserId == 0) {
        try {
          final userDataStr = SharedPrefs.getString(AppConstants.userData);
          if (userDataStr != null && userDataStr.isNotEmpty) {
            final userModel = UserModel.fromJsonString(userDataStr);
            this.currentUserId = userModel?.id;
            WebSocketService.currentUserId = this.currentUserId;
          }
        } catch (_) {}
      }
    }
    this.userName = userName;
    session.status.value = ChatStatus.values.firstWhere((e) => e.name == initialStatus, orElse: () => ChatStatus.ongoing);
    session.startedAt = startedAtString;

    WebSocketService.activeSessionId = sessionId;

    messaging.loadHistory();
    session.setupTimer(startedAtString);

    if (session.status.value == ChatStatus.ongoing) {
      final effectiveStart = startedAtString != null ? session.parseSmartDate(startedAtString) : null;
      final startTime = effectiveStart ?? DateTime.now();
      WebSocketService.sessionStartTimes[sessionId] = startTime.toIso8601String();
      ForegroundTaskService.startActiveSessionNotification(title: 'Active Chat', type: 'Chat', startedAt: startTime);
    } else if (session.status.value == ChatStatus.initiated) {
      session.startRingtone();
    }

    ever(session.status, (val) {
      if (FloatingChatBubble.isActive && FloatingChatBubble.sessionId == sessionId) {
        FloatingChatBubble.updateStatus(val.name);
      }
    });

    messaging.setupMessageListeners();
    session.setupSessionListeners();
  }

  void setReply(ChatMessage message) => messaging.setReply(message);
  void cancelReply() => messaging.cancelReply();
  
  Future<void> sendTextMessage() => messaging.sendTextMessage();
  Future<void> sendImageAttachment(XFile file) => messaging.sendImageAttachment(file);
  Future<void> sendDocumentAttachment(PlatformFile file) => messaging.sendDocumentAttachment(file);
  Future<void> markRead() => messaging.markRead();
  
  Future<void> terminateChannelOnly() => session.terminateChannelOnly();
  Future<void> terminateEntireSession() => session.terminateEntireSession();
  Future<void> rejectChatSession() => session.rejectChatSession();
  Future<void> endChatSession() => session.endChatSession();
  Future<void> acceptChat(int incomingSessionId) => session.acceptChat(incomingSessionId);
  Future<void> rejectChat(int incomingSessionId) => session.rejectChat(incomingSessionId);
  void minimizeToBubble(BuildContext ctx, String name, String image, {bool shouldPop = true}) => session.minimizeToBubble(ctx, name, image, shouldPop: shouldPop);
}
