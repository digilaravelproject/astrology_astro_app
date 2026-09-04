import 'dart:convert';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/utils/logger.dart';
import 'package:astro_astrologer/core/services/websocket/websocket_state.dart';
import 'package:astro_astrologer/features/live/presentation/controllers/live_controller.dart';
import 'package:astro_astrologer/features/live/data/models/live_session_model.dart';

class LiveWsHandler {
  static void handleViewerCountUpdated(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      final int sessionId =
          eventData['live_session_id'] is int
              ? eventData['live_session_id']
              : (int.tryParse(eventData['live_session_id']?.toString() ?? '') ??
                  0);
      final int count =
          eventData['viewer_count'] is int
              ? eventData['viewer_count']
              : (int.tryParse(eventData['viewer_count']?.toString() ?? '') ??
                  0);

      WebSocketState.liveViewerCounts[sessionId] = count;
      WebSocketState.liveViewerCounts.refresh();

      if (Get.isRegistered<LiveController>()) {
        final controller = Get.find<LiveController>();
        if (controller.currentActiveSession.value?.id == sessionId) {
          controller.currentActiveSession.value = LiveSessionModel(
            id: controller.currentActiveSession.value!.id,
            title: controller.currentActiveSession.value!.title,
            description: controller.currentActiveSession.value!.description,
            scheduledAt: controller.currentActiveSession.value!.scheduledAt,
            sessionType: controller.currentActiveSession.value!.sessionType,
            durationMinutes:
                controller.currentActiveSession.value!.durationMinutes,
            maxParticipants:
                controller.currentActiveSession.value!.maxParticipants,
            status: controller.currentActiveSession.value!.status,
            createdAt: controller.currentActiveSession.value!.createdAt,
            startedAt: controller.currentActiveSession.value!.startedAt,
            endedAt: controller.currentActiveSession.value!.endedAt,
            streamKey: controller.currentActiveSession.value!.streamKey,
            viewerCount: count,
            currentParticipants:
                controller.currentActiveSession.value!.currentParticipants,
            isBroadcasting:
                controller.currentActiveSession.value!.isBroadcasting,
          );
          controller.currentActiveSession.refresh();
        }
      }
    } catch (e) {
      Logger.e('LiveWsHandler: error handling ViewerCountUpdated -> $e');
    }
  }

  static void handleNewLiveComment(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      WebSocketState.liveCommentsEvent.add(eventData);
    } catch (e) {
      Logger.e('LiveWsHandler: error handling NewLiveComment -> $e');
    }
  }

  static void handleSuperChatReceived(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      WebSocketState.superChatEvent.add(eventData);
    } catch (e) {
      Logger.e('LiveWsHandler: error handling SuperChatReceived -> $e');
    }
  }

  static void handleUserJoinedLiveSession(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      WebSocketState.userJoinedEvent.add(eventData);
    } catch (e) {
      Logger.e('LiveWsHandler: error handling UserJoinedLiveSession -> $e');
    }
  }

  static void handleUserLeftLiveSession(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      WebSocketState.userLeftEvent.add(eventData);
    } catch (e) {
      Logger.e('LiveWsHandler: error handling UserLeftLiveSession -> $e');
    }
  }

  static void handleActiveLiveSessionsUpdated(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      WebSocketState.activeLiveSessionsUpdatedEvent.add(eventData);
    } catch (e) {
      Logger.e('LiveWsHandler: error handling ActiveLiveSessionsUpdated -> $e');
    }
  }
}
