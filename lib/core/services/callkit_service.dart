import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:astro_astrologer/core/services/local_notification_service.dart';

import '../../features/chat/presentation/widgets/floating_chat_bubble.dart';

class CallkitService {
  static void init() {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      switch (event) {
        case CallEventActionCallAccept():
          debugPrint('CallKit: Call Accepted');
          final payload = event.callKitParams.extra?['payload'] as String?;
          final callerName = event.callKitParams.nameCaller;
          final sessionId = event.callKitParams.id;
          
          if (callerName != null) {
            FloatingChatBubble.name = callerName.replaceAll('Chat Req: ', '').replaceAll('Call Req: ', '').trim();
          }

          if (payload != null) {
            LocalNotificationService.handleNotificationRouting(
              payload, 
              true, 
              false, 
              callerName: callerName?.replaceAll('Chat Req: ', '').replaceAll('Call Req: ', '').trim(),
            );

            // Since it's a chat, end the CallKit session so it doesn't linger as an 'ongoing telecom call'
            if (payload.startsWith('chat_') && sessionId != null) {
              Future.delayed(const Duration(milliseconds: 500), () {
                FlutterCallkitIncoming.endCall(sessionId);
              });
            }
          }
          break;
        case CallEventActionCallDecline():
          debugPrint('CallKit: Call Declined');
          final payload = event.callKitParams.extra?['payload'] as String?;
          final sessionId = event.callKitParams.id;
          
          if (sessionId != null && LocalNotificationService.isSessionCancelled(sessionId)) {
             debugPrint('CallKit: Ignoring decline because session $sessionId was already cancelled by user');
             break;
          }
          
          if (payload != null) {
            LocalNotificationService.handleNotificationRouting(
              payload, 
              false, 
              true,
            );
          }
          break;
        case CallEventActionCallEnded():
          debugPrint('CallKit: Call Ended');
          break;
        case CallEventActionCallTimeout():
          debugPrint('CallKit: Call Timeout');
          break;
        default:
          break;
      }
    });
  }

  static Future<void> showCallkitNotification({
    required String sessionId,
    required String callerName,
    required String avatar,
    required String type, // 'call' or 'chat'
  }) async {
    final String notifTitle = type == 'call' ? 'Incoming Call' : 'Chat Request';
    final String nameCallerParam = type == 'call' ? callerName : 'Chat Req: $callerName';
    final String payloadStr = '${type}_$sessionId';
    final String safeAvatar = (avatar.isNotEmpty && avatar != 'null') ? avatar : 'assets/images/app_logo.png';

    CallKitParams callKitParams = CallKitParams(
      id: sessionId,
      nameCaller: nameCallerParam,
      appName: 'DigiEmperor Astrology',
      avatar: safeAvatar,
      handle: notifTitle,
      type: 0,
      duration: 30000,
      extra: <String, dynamic>{'payload': payloadStr, 'sessionId': sessionId},
      headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#FFFFFF',
        backgroundUrl: 'assets/images/background.png',
        actionColor: '#4CAF50',
        textColor: '#000000',
        textAccept: 'Accept',
        textDecline: 'Decline',
      ),
    );
    await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
  }

  static Future<void> showIncomingCall(CallKitParams params) async {
    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  static Future<void> endCall(String sessionId) async {
    await FlutterCallkitIncoming.endCall(sessionId);
  }

  static Future<void> endAllCalls() async {
    await FlutterCallkitIncoming.endAllCalls();
  }
}
