import 'dart:convert';
import 'package:astro_astrologer/core/utils/logger.dart';
import 'package:astro_astrologer/core/services/websocket/websocket_state.dart';
import 'package:astro_astrologer/features/call/presentation/controllers/call_controller.dart';
import 'package:astro_astrologer/features/chat/presentation/controllers/chat_controller.dart';
import 'package:get/get.dart';

class PackageWsHandler {
  static void handlePackageSubSessionStarted(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      final secs =
          eventData['remainingDuration'] ??
          eventData['remaining_duration'] ??
          eventData['subSession']?['purchase']?['remaining_duration'];
      WebSocketState.packageRemainingSeconds.value =
          int.tryParse(secs?.toString() ?? '') ?? 0;
      WebSocketState.isPackageSessionTerminated.value = false;
    } catch (e) {
      Logger.e('PackageWsHandler: error handling PackageSubSessionStarted -> $e');
    }
  }

  static void handlePackageSubSessionEnded(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      final secs =
          eventData['remainingDuration'] ??
          eventData['remaining_duration'] ??
          eventData['subSession']?['purchase']?['remaining_duration'];
      WebSocketState.packageRemainingSeconds.value =
          int.tryParse(secs?.toString() ?? '') ?? 0;
    } catch (e) {
      Logger.e('PackageWsHandler: error handling PackageSubSessionEnded -> $e');
    }
  }

  static void handlePackageSessionStateUpdated(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      final secs = eventData['remaining_seconds'];
      if (secs != null) {
        WebSocketState.packageRemainingSeconds.value =
            int.tryParse(secs?.toString() ?? '') ?? 0;
      }

      final callStatus = eventData['call_status']?.toString();
      final chatStatus = eventData['chat_status']?.toString();
      final routing = eventData['routing_context'] is Map ? eventData['routing_context'] as Map : null;
      final callSessionId = routing != null ? routing['call_session_id'] : null;
      final chatSessionId = routing != null ? routing['chat_session_id'] : null;

      if (callStatus == 'disconnected' || callStatus == 'closed') {
        if (Get.isRegistered<CallController>()) {
          final callCtrl = Get.find<CallController>();
          if (callCtrl.sessionId != null && (callSessionId == null || callCtrl.sessionId == callSessionId)) {
            Logger.d('PackageWsHandler: SubSession call status is $callStatus. Auto-cleaning CallController.');
            callCtrl.cleanUp();
            if (Get.currentRoute.toLowerCase().contains('call')) {
              if (Get.isDialogOpen ?? false) Get.back();
              Get.back();
            }
          }
        }
      }

      if (chatStatus == 'closed' || chatStatus == 'disconnected') {
        if (Get.isRegistered<ChatController>()) {
          final chatCtrl = Get.find<ChatController>();
          if (chatCtrl.sessionId != null && (chatSessionId == null || chatCtrl.sessionId == chatSessionId)) {
            Logger.d('PackageWsHandler: SubSession chat status is $chatStatus. Auto-cleaning ChatController.');
            chatCtrl.cleanUp();
            if (Get.currentRoute.toLowerCase().contains('chat')) {
              if (Get.isDialogOpen ?? false) Get.back();
              Get.back();
            }
          }
        }
      }
    } catch (e) {
      Logger.e('PackageWsHandler: error handling PackageSessionStateUpdated -> $e');
    }
  }

  static void handlePackageSessionTerminated(dynamic rawData) {
    WebSocketState.packageRemainingSeconds.value = 0;
    WebSocketState.isPackageSessionTerminated.value = true;
  }
}
