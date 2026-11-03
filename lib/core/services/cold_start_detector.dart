import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:astro_astrologer/core/services/callkit_service.dart';
import 'package:astro_astrologer/core/services/storage/shared_prefs.dart';

enum ColdStartType {
  none,
  call,
  chat,
  assistanceChat,
}

class ColdStartIntent {
  final ColdStartType type;
  final int sessionId;
  final String? name;
  final String? avatar;
  final String? offerSdp;
  final Map<String, dynamic>? rawData;

  ColdStartIntent({
    required this.type,
    required this.sessionId,
    this.name,
    this.avatar,
    this.offerSdp,
    this.rawData,
  });

  @override
  String toString() {
    return 'ColdStartIntent(type: $type, sessionId: $sessionId, name: $name)';
  }
}

class ColdStartDetector {
  static ColdStartIntent? currentIntent;

  /// Inspects native launch intent across CallKit, Local Notifications, and FCM.
  /// Must be called during pre-runApp initApp() lifecycle.
  static Future<ColdStartIntent?> detect() async {
    try {
      debugPrint('[ColdStartDetector] Scanning native launch intents...');

      // ── 1. Check FlutterCallkitIncoming.activeCalls() ───────────────────
      try {
        final dynamic activeCalls = await FlutterCallkitIncoming.activeCalls();
        if (activeCalls is List && activeCalls.isNotEmpty) {
          debugPrint('[ColdStartDetector] CallKit active calls detected: $activeCalls');
          for (final rawCall in activeCalls) {
            Map<dynamic, dynamic>? callMap;
            bool isAccepted = false;

            if (rawCall is CallKitParams) {
              callMap = rawCall.toJson();
              isAccepted = rawCall.isAccepted;
            } else if (rawCall is Map) {
              callMap = rawCall;
              isAccepted = callMap['isAccepted'] == true ||
                  callMap['isAccepted']?.toString().toLowerCase() == 'true';
            } else {
              try {
                callMap = (rawCall as dynamic).toJson();
                isAccepted = (rawCall as dynamic).isAccepted == true;
              } catch (_) {}
            }

            if (callMap == null) continue;

            final String? rawId = callMap['id']?.toString();
            final int? sId = int.tryParse(rawId ?? '');
            final String? name = callMap['nameCaller']?.toString();
            final String? avatar = callMap['avatar']?.toString();
            final String? handle = callMap['handle']?.toString();
            final dynamic extra = callMap['extra'];

            String payload = '';
            String offerSdp = '';
            if (extra is Map) {
              payload = extra['payload']?.toString() ?? '';
              offerSdp = extra['offer']?.toString() ?? '';
            }

            final bool isChat = payload.startsWith('chat_') ||
                handle == 'Chat Request' ||
                (name != null && name.contains('Chat Req'));

            final cleanName = name != null
                ? name
                    .replaceAll('Chat Req: ', '')
                    .replaceAll('Call Req: ', '')
                    .trim()
                : 'User';

            if (sId != null && sId > 0) {
              final bool isEnded = SharedPrefs.getBool('session_ended_$sId') ?? false;
              if (isEnded) {
                debugPrint('[ColdStartDetector] Ignoring stale ended CallKit session $sId');
                await FlutterCallkitIncoming.endCall(sId.toString());
                await FlutterCallkitIncoming.endAllCalls();
                continue;
              }

              if (!isAccepted) {
                debugPrint('[ColdStartDetector] Skipping non-accepted CallKit call (sId=$sId)');
                continue;
              }

              final intent = ColdStartIntent(
                type: isChat ? ColdStartType.chat : ColdStartType.call,
                sessionId: sId,
                name: cleanName,
                avatar: avatar,
                offerSdp: offerSdp,
                rawData: extra is Map ? Map<String, dynamic>.from(extra) : null,
              );
              currentIntent = intent;
              if (isChat) {
                CallkitService.isHandlingAcceptedChat = true;
                CallkitService.lastAcceptedSessionId = sId.toString();
              } else {
                CallkitService.isHandlingAcceptedCall = true;
                CallkitService.lastAcceptedSessionId = sId.toString();
              }
              debugPrint('[ColdStartDetector] Found CallKit intent: $intent (isAccepted=$isAccepted)');
              return intent;
            }
          }
        }
      } catch (e) {
        debugPrint('[ColdStartDetector] CallKit check error: $e');
      }

      // ── 2. Check FlutterLocalNotificationsPlugin launch details ─────────
      try {
        final launchDetails = await FlutterLocalNotificationsPlugin().getNotificationAppLaunchDetails();
        if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
          final String? payload = launchDetails.notificationResponse?.payload;
          debugPrint('[ColdStartDetector] LocalNotification launch payload: $payload');
          if (payload != null && payload.isNotEmpty) {
            final intent = _parsePayload(payload);
            if (intent != null) {
              currentIntent = intent;
              return intent;
            }
          }
        }
      } catch (e) {
        debugPrint('[ColdStartDetector] LocalNotification check error: $e');
      }

      // ── 3. Check FirebaseMessaging getInitialMessage ────────────────────
      try {
        final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
        if (initialMessage != null && initialMessage.data.isNotEmpty) {
          debugPrint('[ColdStartDetector] FCM initialMessage data: ${initialMessage.data}');
          final intent = _parseFcmData(initialMessage.data);
          if (intent != null) {
            currentIntent = intent;
            return intent;
          }
        }
      } catch (e) {
        debugPrint('[ColdStartDetector] FCM initialMessage check error: $e');
      }

      debugPrint('[ColdStartDetector] No communication cold-start intent found.');
      return null;
    } catch (e) {
      debugPrint('[ColdStartDetector] General detection error: $e');
      return null;
    }
  }

  static ColdStartIntent? _parsePayload(String payload) {
    try {
      // JSON payload (Assistance Chat or Structured FCM)
      if (payload.startsWith('{') && payload.endsWith('}')) {
        final Map<String, dynamic> data = jsonDecode(payload);
        return _parseFcmData(data);
      }

      // call_123
      if (payload.startsWith('call_')) {
        final sIdStr = payload.replaceFirst('call_', '');
        final sId = int.tryParse(sIdStr);
        if (sId != null && sId > 0) {
          return ColdStartIntent(type: ColdStartType.call, sessionId: sId);
        }
      }

      // chat_123
      if (payload.startsWith('chat_')) {
        final sIdStr = payload.replaceFirst('chat_', '');
        final sId = int.tryParse(sIdStr);
        if (sId != null && sId > 0) {
          return ColdStartIntent(type: ColdStartType.chat, sessionId: sId);
        }
      }

      // Plain integer sessionId
      final sId = int.tryParse(payload);
      if (sId != null && sId > 0) {
        return ColdStartIntent(type: ColdStartType.chat, sessionId: sId);
      }
    } catch (e) {
      debugPrint('[ColdStartDetector] Error parsing payload: $e');
    }
    return null;
  }

  static ColdStartIntent? _parseFcmData(Map<String, dynamic> data) {
    try {
      final type = data['type']?.toString().toLowerCase();
      final notificationType = data['notification_type']?.toString().toLowerCase();
      final rawSessionId = data['session_id']?.toString() ??
          data['chat_session_id']?.toString() ??
          data['call_session_id']?.toString() ??
          data['chat_assistance_session_id']?.toString() ??
          data['id']?.toString() ?? '';
      final int? sId = int.tryParse(rawSessionId);

      if (sId == null || sId <= 0) return null;

      final userName = data['user_name']?.toString() ?? data['caller_name']?.toString() ?? 'User';
      final userAvatar = data['user_avatar']?.toString() ?? data['caller_image']?.toString();
      final offerSdp = data['offer']?.toString() ?? data['offer_sdp']?.toString();

      if (type == 'assistance_chat' || type == 'chat_assistance' || notificationType == 'assistance_chat') {
        return ColdStartIntent(
          type: ColdStartType.assistanceChat,
          sessionId: sId,
          name: userName,
          avatar: userAvatar,
          rawData: data,
        );
      }

      final bool isCall = type == 'call' ||
          type == 'call_request' ||
          type == 'audio_call' ||
          type == 'video_call' ||
          data['channel_type']?.toString().toLowerCase() == 'call';

      if (isCall) {
        return ColdStartIntent(
          type: ColdStartType.call,
          sessionId: sId,
          name: userName,
          avatar: userAvatar,
          offerSdp: offerSdp,
          rawData: data,
        );
      }

      final bool isChat = type == 'chat' ||
          type == 'chat_request' ||
          type == 'chat_accepted' ||
          data['channel_type']?.toString().toLowerCase() == 'chat';

      if (isChat) {
        return ColdStartIntent(
          type: ColdStartType.chat,
          sessionId: sId,
          name: userName,
          avatar: userAvatar,
          rawData: data,
        );
      }
    } catch (e) {
      debugPrint('[ColdStartDetector] Error parsing FCM data: $e');
    }
    return null;
  }
}

