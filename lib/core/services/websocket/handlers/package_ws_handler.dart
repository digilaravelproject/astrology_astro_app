import 'dart:convert';
import 'package:astro_astrologer/core/utils/logger.dart';
import 'package:astro_astrologer/core/services/websocket/websocket_state.dart';
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
    } catch (e) {
      Logger.e('PackageWsHandler: error handling PackageSessionStateUpdated -> $e');
    }
  }

  static void handlePackageSessionTerminated(dynamic rawData) {
    WebSocketState.packageRemainingSeconds.value = 0;
    WebSocketState.isPackageSessionTerminated.value = true;
  }
}
