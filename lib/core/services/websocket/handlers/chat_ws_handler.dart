import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/utils/logger.dart';
import 'package:astro_astrologer/core/services/websocket/websocket_state.dart';
import 'package:astro_astrologer/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_astrologer/features/chat/presentation/controllers/chat_controller.dart';
import 'package:astro_astrologer/features/chat/domain/usecases/sync_message_status_usecase.dart';
import 'package:astro_astrologer/features/chat/presentation/controllers/assistant_chat_list_controller.dart';
import 'package:astro_astrologer/features/chat/presentation/controllers/assistance_chat_room_controller.dart';
import 'package:astro_astrologer/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';
import 'package:astro_astrologer/core/enums/session_status_enums.dart';
import 'package:astro_astrologer/core/services/callkit_service.dart';

class ChatWsHandler {
  static void handleChatInitiated(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final session = eventData['session'];
      final senderData = eventData['senderData'];

      if (session != null && senderData != null) {
        WebSocketState.chatInitiatedEvent.add(Map<String, dynamic>.from(session));
        WebSocketState.lastChatSenderData = Map<String, dynamic>.from(senderData);

        final int sessionId =
            session['id'] is int
                ? session['id']
                : (int.tryParse(session['id']?.toString() ?? '') ?? 0);
        final String name = senderData['name']?.toString() ?? 'User';

        if (CallkitService.lastAcceptedSessionId == sessionId.toString()) {
          return;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final String userAvatarRaw = senderData['profile_photo_url']?.toString() ?? senderData['profile_photo']?.toString() ?? '';
          final String userAvatar = userAvatarRaw.isNotEmpty && userAvatarRaw != 'null' ? userAvatarRaw : 'assets/images/app_logo.png';

          CallkitService.showCallkitNotification(
            sessionId: sessionId.toString(),
            callerName: name,
            avatar: userAvatar,
            type: 'chat',
          );
        });
      }
    } catch (e) {
      Logger.e('ChatWsHandler: error handling ChatInitiated -> $e');
    }
  }

  static void handleChatAccepted(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final session = eventData['session'];
      if (session == null) return;

      final int sessionId =
          session['id'] is int
              ? session['id']
              : (int.tryParse(session['id']?.toString() ?? '') ?? 0);
      final String? startedAt = session['started_at']?.toString();
      if (startedAt != null) {
        WebSocketState.sessionStartTimes[sessionId] = startedAt;
      }
      WebSocketState.sessionStatusUpdates[sessionId] = 'ongoing';
      WebSocketState.sessionStatusUpdates.refresh();

      if (FloatingChatBubble.isActive &&
          FloatingChatBubble.sessionId == sessionId) {
        FloatingChatBubble.updateStatus('ongoing');
      }

      if (Get.isRegistered<ChatController>()) {
        final controller = Get.find<ChatController>();
        if (controller.sessionId == sessionId) {
          controller.status.value = ChatStatus.ongoing;
        }
      }
    } catch (e) {
      Logger.e('ChatWsHandler: error handling ChatAccepted -> $e');
    }
  }

  static void handleChatEnded(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final session = eventData['session'];
      if (session == null) return;

      final int sessionId =
          session['id'] is int
              ? session['id']
              : (int.tryParse(session['id']?.toString() ?? '') ?? 0);

      FloatingChatBubble.dismiss(stopForegroundService: true);

      if (WebSocketState.activeSessionId == sessionId) {
        WebSocketState.activeSessionId = null;
      }
      WebSocketState.chatEndedSessionId.value = sessionId;
    } catch (e) {
      Logger.e('ChatWsHandler: error handling ChatEnded -> $e');
    }
  }

  static void handleChatDismissed(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final session = eventData['session'];
      if (session == null) return;

      final int sessionId =
          session['id'] is int
              ? session['id']
              : (int.tryParse(session['id']?.toString() ?? '') ?? 0);

      FloatingChatBubble.dismiss(stopForegroundService: true);

      WebSocketState.sessionStatusUpdates[sessionId] = 'ended';
      WebSocketState.sessionStatusUpdates.refresh();

      WebSocketState.chatDismissedSessionId.value = sessionId;

      if (WebSocketState.activeSessionId == sessionId) {
        WebSocketState.activeSessionId = null;
      }
    } catch (e) {
      Logger.e('ChatWsHandler: error handling ChatDismissed -> $e');
    }
  }

  static void handleMessageSent(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final messageData = eventData['messageData'] ?? eventData['message'];
      if (messageData != null) {
        final map = Map<String, dynamic>.from(messageData);
        WebSocketState.incomingMessages.add(map);

        final int senderId =
            int.tryParse(map['sender_id']?.toString() ?? '') ?? 0;
        final int sessionId =
            int.tryParse(
              map['chat_assistance_session_id']?.toString() ??
                  map['chat_session_id']?.toString() ??
                  '',
            ) ??
            0;

        if (Get.isRegistered<AssistantChatListController>()) {
          Get.find<AssistantChatListController>().fetchSessions();
        }

        if (senderId != WebSocketState.currentUserId && WebSocketState.activeSessionId != sessionId) {
          if (FloatingChatBubble.isActive &&
              FloatingChatBubble.sessionId == sessionId) {
            FloatingChatBubble.incrementUnreadCount();
          }
          _showInAppNotification(map);

          final int messageId = int.tryParse(map['id']?.toString() ?? '') ?? 0;
          if (messageId > 0 && Get.isRegistered<SyncMessageStatusUseCase>()) {
            Get.find<SyncMessageStatusUseCase>()
                .execute(
                  sessionId: sessionId,
                  messageIds: [messageId],
                  status: 'delivered',
                )
                .catchError((e) {
                  debugPrint('Error syncing message status: $e');
                });
          }
        }
      }
    } catch (e) {
      Logger.e('ChatWsHandler: error handling MessageSent -> $e');
    }
  }

  static void _showInAppNotification(Map<String, dynamic> msg) {
    final int sessionId =
        int.tryParse(msg['chat_session_id']?.toString() ?? '') ?? 0;
    final String text = msg['message'] ?? 'Sent an attachment';

    try {
      CustomSnackBar.disabledSnackbar(
        'New Message',
        text,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        colorText: const Color(0xFF2E1A47),
        icon: const Icon(Icons.message, color: Color(0xFFFF6F00)),
        boxShadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        duration: const Duration(seconds: 4),
        onTap: (_) {
          Get.to(
            () => ChatScreen(
              userName: "User",
              userImage: "",
              sessionId: sessionId,
              initialStatus: 'ongoing',
            ),
          );
        },
      );
    } catch (e) {
      Logger.e('ChatWsHandler: error showing snackbar -> $e');
    }
  }

  static void handleMessageStatusUpdated(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      WebSocketState.messageStatusUpdates.add(eventData);
    } catch (e) {
      Logger.e('ChatWsHandler: error handling MessageStatusUpdated -> $e');
    }
  }

  static void handlePresenceUpdated(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      WebSocketState.presenceUpdates.add(eventData);
    } catch (e) {
      Logger.e('ChatWsHandler: error handling PresenceUpdated -> $e');
    }
  }

  static void handleChatAssistanceInitiated(dynamic rawData) {
    try {
      if (Get.isRegistered<AssistantChatListController>()) {
        Get.find<AssistantChatListController>().fetchSessions();
      }
    } catch (e) {
      Logger.e('ChatWsHandler: error handling ChatAssistanceInitiated -> $e');
    }
  }

  static void handleChatAssistanceLimitReached(dynamic rawData) {
    try {
      if (Get.isRegistered<AssistanceChatRoomController>()) {
        Get.find<AssistanceChatRoomController>().limitReached.value = true;
      }
    } catch (e) {
      Logger.e('ChatWsHandler: error handling ChatAssistanceLimitReached -> $e');
    }
  }

  static void handleChatQueueUpdated(dynamic rawData) {
    try {
      Map<String, dynamic> parsedData = {};
      if (rawData is String) {
        parsedData = jsonDecode(rawData);
      } else if (rawData is Map) {
        parsedData = Map<String, dynamic>.from(rawData);
      }
      WebSocketState.chatQueueUpdatedEvent.add(parsedData);
    } catch (e) {
      Logger.e('ChatWsHandler: error handling ChatQueueUpdated -> $e');
    }
  }
}
