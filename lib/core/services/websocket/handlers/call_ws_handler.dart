import 'dart:convert';
import 'package:astro_astrologer/core/utils/logger.dart';
import 'package:astro_astrologer/core/services/websocket/websocket_state.dart';
import 'package:astro_astrologer/features/call/presentation/widgets/floating_call_bubble.dart';

class CallWsHandler {
  static void handleCallInitiated(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final session = eventData['session'];
      final callerData = eventData['callerData'];

      if (session != null && callerData != null) {
        final sessionMap = Map<String, dynamic>.from(session);
        final callerMap = Map<String, dynamic>.from(callerData);
        WebSocketState.callInitiatedEvent.add({
          'session': sessionMap,
          'callerData': callerMap,
        });
      }
    } catch (e) {
      Logger.e('CallWsHandler: error handling CallInitiated -> $e');
    }
  }

  static void handleCallAccepted(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      final session = eventData['session'];
      if (session != null) {
        final int sessionId =
            session['id'] is int
                ? session['id']
                : (int.tryParse(session['id']?.toString() ?? '') ?? 0);
        WebSocketState.callSessionStatusUpdates[sessionId] = 'ongoing';
        WebSocketState.callSessionStatusUpdates.refresh();
      }
      WebSocketState.callAcceptedData.value = eventData;
      WebSocketState.callAcceptedData.refresh();
    } catch (e) {
      Logger.e('CallWsHandler: error handling CallAccepted -> $e');
    }
  }

  static void handleCallDismissed(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      final session = eventData['session'];
      if (session != null) {
        final int sessionId =
            session['id'] is int
                ? session['id']
                : (int.tryParse(session['id']?.toString() ?? '') ?? 0);
        final String? reason = eventData['reason']?.toString();
        WebSocketState.callSessionStatusUpdates[sessionId] = reason ?? 'dismissed';
        WebSocketState.callSessionStatusUpdates.refresh();
        WebSocketState.callDismissedSessionId.value = sessionId;
      }
      WebSocketState.callDismissedData.value = eventData;
      WebSocketState.callDismissedData.refresh();
    } catch (e) {
      Logger.e('CallWsHandler: error handling CallDismissed -> $e');
    }
  }

  static void handleCallEnded(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      final session = eventData['session'];
      final int sessionId =
          session != null && session['id'] != null
              ? (session['id'] is int
                  ? session['id']
                  : (int.tryParse(session['id']?.toString() ?? '') ?? 0))
              : 0;

      // Cancel call notifications & bubbles immediately
      FloatingCallBubble.dismiss(stopForegroundService: true);

      if (sessionId != 0) {
        WebSocketState.callSessionStatusUpdates[sessionId] = 'completed';
        WebSocketState.callSessionStatusUpdates.refresh();
        WebSocketState.callEndedSessionId.value = sessionId;
      }
      WebSocketState.callEndedData.value = eventData;
      WebSocketState.callEndedData.refresh();
    } catch (e) {
      Logger.e('CallWsHandler: error handling CallEnded -> $e');
    }
  }

  static void handleIceCandidateSent(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      WebSocketState.iceCandidateData.value = eventData;
      WebSocketState.iceCandidateData.refresh();
    } catch (e) {
      Logger.e('CallWsHandler: error handling IceCandidateSent -> $e');
    }
  }

  static void handleWebRtcSdpUpdated(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      WebSocketState.sdpUpdateData.value = eventData;
      WebSocketState.sdpUpdateData.refresh();
    } catch (e) {
      Logger.e('CallWsHandler: error handling WebRtcSdpUpdated -> $e');
    }
  }
}
