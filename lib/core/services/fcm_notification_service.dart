import 'package:astro_astrologer/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:astro_astrologer/core/services/callkit_service.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:astro_astrologer/core/constants/app_constants.dart';
import 'local_notification_service.dart';

class FCMNotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // 1. Request Notification Permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');
    } else {
      debugPrint('User declined notification permission');
    }

    // 2. Get & Register Device Token
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint('FCM Token: $token');
        await registerDeviceToken(token);
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }

    // 3. Token Refresh Listener
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM Token Refreshed: $newToken');
      await registerDeviceToken(newToken);
    });

    // 4. Foreground Message Handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('=======================================');
      debugPrint('[FCM_JSON_DATA] Foreground Message Received!');
      debugPrint('[FCM_JSON_DATA] Notification Title: ${message.notification?.title}');
      debugPrint('[FCM_JSON_DATA] Notification Body: ${message.notification?.body}');
      try {
        debugPrint('[FCM_JSON_DATA] Message JSON: ${jsonEncode(message.data)}');
      } catch (e) {
        debugPrint('[FCM_JSON_DATA] Message Data: ${message.data}');
      }
      debugPrint('=======================================');
      if (message.notification != null || message.data.isNotEmpty) {
        final type = message.data['type']?.toString();
        final title =
            message.notification?.title ??
            message.data['title']?.toString() ??
            '';
        final body =
            message.notification?.body ??
            message.data['body']?.toString() ??
            '';

        final String rawSessionId =
            message.data['session_id']?.toString() ??
            message.data['chat_session_id']?.toString() ??
            message.data['chat_assistance_session_id']?.toString() ??
            message.data['live_session_id']?.toString() ??
            message.data['id']?.toString() ??
            '';
        final int parsedSessionId = int.tryParse(rawSessionId) ?? 0;

        // Build structured payload for routing (mirrors user app)
        String structuredPayload;
        if (type == 'live_stream' || type == 'live' || type == 'live_session') {
          structuredPayload = 'live_$rawSessionId';
        } else if (type == 'call' ||
            type == 'CALL_REQUEST' ||
            type == 'CALL_ACCEPTED') {
          structuredPayload =
              rawSessionId.isNotEmpty
                  ? 'call_$rawSessionId'
                  : message.data.toString();
        } else if (type == 'gift' || type == 'payout_settlement' || type == 'wallet') {
          final refId = message.data['reference_id']?.toString() ?? message.data['entity_id']?.toString() ?? '';
          structuredPayload = refId.isNotEmpty ? 'wallet_$refId' : message.data.toString();
        } else {
          structuredPayload =
              rawSessionId.isNotEmpty ? rawSessionId : message.data.toString();
        }

        // Choose notification channel based on type
        String channelId;
        final upperType = type?.toUpperCase() ?? '';

        if (upperType == 'CALL') {
          channelId = 'call';
        } else if (upperType == 'CHAT') {
          channelId = 'chat';
        } else if (upperType == 'CHAT_REQUEST') {
          channelId = 'chat_request';
        } else if (upperType == 'CALL_REQUEST') {
          channelId = 'call_request';
        } else if (upperType == 'LIVE_STREAM' ||
            upperType == 'LIVE' ||
            upperType == 'LIVE_SESSION') {
          channelId = 'live_stream';
        } else if (upperType == 'GIFT' || upperType == 'PAYOUT_SETTLEMENT' || upperType == 'WALLET') {
          channelId = 'wallet';
        } else if (upperType == 'ORDER') {
          channelId = 'wallet';
        } else if (upperType == 'CHAT_ACCEPTED') {
          channelId = 'chat_request';
        } else if (upperType == 'CALL_ACCEPTED') {
          channelId = 'call_request';
        } else if (upperType.contains('CHAT')) {
          channelId = 'chat';
        } else if (upperType.contains('CALL')) {
          channelId = 'call';
        } else {
          channelId = 'general';
        }

        // Read sound, priority, importance dynamically from backend data map
        final String playSoundRaw =
            message.data['play_sound']?.toString() ??
            message.data['playSound']?.toString() ??
            '0';
        final bool playSound =
            playSoundRaw == '1' ||
            playSoundRaw == 'true' ||
            playSoundRaw == 'yes' ||
            playSoundRaw == 'true';

        final String priorityRaw =
            message.data['priority']?.toString().toLowerCase() ?? 'high';
        Priority priority = Priority.high;
        if (priorityRaw == 'max')
          priority = Priority.max;
        else if (priorityRaw == 'low')
          priority = Priority.low;
        else if (priorityRaw == 'min')
          priority = Priority.min;
        else if (priorityRaw == 'default' || priorityRaw == 'normal')
          priority = Priority.defaultPriority;

        final String importanceRaw =
            message.data['importance']?.toString().toLowerCase() ?? 'high';
        Importance importance = Importance.high;
        if (importanceRaw == 'max')
          importance = Importance.max;
        else if (importanceRaw == 'low')
          importance = Importance.low;
        else if (importanceRaw == 'min')
          importance = Importance.min;
        else if (importanceRaw == 'default' || importanceRaw == 'normal')
          importance = Importance.defaultImportance;
        else if (importanceRaw == 'none')
          importance = Importance.none;

        final String? reason = message.data['reason']?.toString()?.toLowerCase();
        
        // 1. Check for Cancellations / Ended events FIRST
        if (title.contains('Chat Ended') ||
            title.contains('Cancelled') ||
            reason == 'cancelled' ||
            reason == 'rejected' ||
            type == 'chat_ended' ||
            type == 'CHAT_ENDED' ||
            type == 'session_ended' ||
            type == 'chat_summary' ||
            type == 'CHAT_MISSED' ||
            type == 'CHAT_DISMISSED') {
          LocalNotificationService.markSessionCancelled(parsedSessionId.toString());
          CallkitService.endCall(parsedSessionId.toString());
          FloatingChatBubble.dismiss(stopForegroundService: true);
          return;
        } else if (title.contains('Call Ended') ||
            type == 'call_ended' ||
            type == 'CALL_ENDED' ||
            type == 'session_completed' ||
            type == 'CALL_FAILED' ||
            type == 'CALL_DISMISSED') {
          LocalNotificationService.markSessionCancelled(parsedSessionId.toString());
          CallkitService.endCall(parsedSessionId.toString());
          if (parsedSessionId > 0) return;
        } else if (type == 'PACKAGE_EXHAUSTED' || type == 'package') {
          if (parsedSessionId > 0)
            FloatingChatBubble.dismiss(stopForegroundService: true);
          return;
        }

        // 2. Process Incoming Requests
        if (type == 'CHAT_REQUEST' || type == 'CALL_REQUEST' || type == 'call' || type == 'audio_call' || type == 'video_call' || type == 'chat') {
          final String channelType = message.data['channel_type']?.toString() ?? ((type == 'call' || type == 'audio_call' || type == 'video_call') ? 'call' : 'chat');
          final String userName = message.data['user_name']?.toString() ?? message.data['caller_name']?.toString() ?? 'User';
          final String userAvatarRaw = message.data['user_avatar']?.toString() ?? message.data['caller_image']?.toString() ?? '';
          final String userAvatar = userAvatarRaw.isNotEmpty ? userAvatarRaw : 'assets/images/app_logo.png';
          CallkitService.showCallkitNotification(
            sessionId: parsedSessionId.toString(),
            callerName: userName,
            avatar: userAvatar,
            type: channelType, // 'call' or 'chat'
          );
        } else {
          // Show the foreground notification (with dynamic params) for other types (wallet, etc)
          LocalNotificationService.showNotification(
            notificationId: parsedSessionId > 0 ? parsedSessionId : null,
            title: title,
            body: body,
            payload: structuredPayload,
            channelId: channelId,
            playSound: playSound,
            priority: priority,
            importance: importance,
          );
        }

      }
    });

    // 5. Notification Opened Handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('=======================================');
      debugPrint('[FCM_JSON_DATA] Notification Opened App!');
      debugPrint('[FCM_JSON_DATA] Notification Title: ${message.notification?.title}');
      debugPrint('[FCM_JSON_DATA] Notification Body: ${message.notification?.body}');
      try {
        debugPrint('[FCM_JSON_DATA] Message JSON: ${jsonEncode(message.data)}');
      } catch (e) {
        debugPrint('[FCM_JSON_DATA] Message Data: ${message.data}');
      }
      debugPrint('=======================================');
    });
  }

  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Register or Refresh FCM Device Token on Backend with full real metadata
  static Future<void> registerDeviceToken(String? fcmToken) async {
    // Run completely in background thread context to prevent UI block (ANR)
    Future.microtask(() async {
      try {
        debugPrint(
          '[FCM_SERVICE] registerDeviceToken background execution started.',
        );
        if (!Get.isRegistered<ApiClient>()) {
          debugPrint(
            '[FCM_SERVICE] ApiClient is NOT registered in GetX container!',
          );
          return;
        }

        // Safe getToken timeout helper to prevent freeze
        String? tokenToRegister = fcmToken;
        if (tokenToRegister == null) {
          try {
            tokenToRegister = await _firebaseMessaging.getToken().timeout(
              const Duration(seconds: 4),
              onTimeout: () {
                debugPrint(
                  '[FCM_SERVICE] _firebaseMessaging.getToken timed out.',
                );
                return null;
              },
            );
          } catch (tokEx) {
            debugPrint(
              '[FCM_SERVICE] Error fetching token with timeout: $tokEx',
            );
          }
        }

        if (tokenToRegister == null || tokenToRegister.isEmpty) {
          debugPrint(
            '[FCM_SERVICE] FCM token is null or empty, skipping API call.',
          );
          return;
        }

        final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        final PackageInfo packageInfo = await PackageInfo.fromPlatform();

        String deviceId = '';
        String deviceModel = '';
        String deviceType =
            Platform.isAndroid
                ? 'android'
                : (Platform.isIOS ? 'ios' : 'unknown');

        if (Platform.isAndroid) {
          AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
          deviceId = androidInfo.id;
          deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}';
        } else if (Platform.isIOS) {
          IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
          deviceId = iosInfo.identifierForVendor ?? '';
          deviceModel = '${iosInfo.name} ${iosInfo.model}';
        }

        final payload = {
          'fcm_token': tokenToRegister,
          'device_type': deviceType,
          'device_id': deviceId,
          'device_model': deviceModel,
          'app_version': packageInfo.version,
        };

        debugPrint(
          '[FCM_SERVICE] Sending POST to ${AppUrls.registerDeviceToken} with full payload: $payload',
        );
        final apiClient = Get.find<ApiClient>();
        final response = await apiClient.post(
          AppUrls.registerDeviceToken,
          data: payload,
          handleError: false,
          showToaster: false,
        );
        debugPrint(
          '[FCM_SERVICE] Device token registered response | Status: ${response.statusCode} | Success: ${response.isSuccess}',
        );
      } catch (e, stackTrace) {
        debugPrint(
          '[FCM_SERVICE] Failed to register device token error: $e\n$stackTrace',
        );
      }
    });
  }

  /// Remove Device Token on Logout
  static Future<void> removeDeviceToken() async {
    try {
      if (!Get.isRegistered<ApiClient>()) return;

      final String? fcmToken = await getToken();
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String deviceId = '';

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? '';
      }

      final payload = {'device_id': deviceId, 'fcm_token': fcmToken ?? ''};

      debugPrint(
        '[FCM_SERVICE] Sending POST to ${AppUrls.removeDeviceToken} with payload: $payload',
      );
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.post(
        AppUrls.removeDeviceToken,
        data: payload,
      );
      debugPrint(
        '[FCM_SERVICE] Device token removed response: ${response.body}',
      );
    } catch (e) {
      debugPrint('[FCM_SERVICE] Failed to remove device token: $e');
    }
  }
}
