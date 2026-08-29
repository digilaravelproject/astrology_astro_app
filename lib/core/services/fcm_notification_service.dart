import 'package:astro_astrologer/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'local_notification_service.dart';

class FCMNotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

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
      debugPrint('Foreground Message Received: ${message.notification?.title}');
      if (message.notification != null) {
        final type = message.data['type']?.toString();
        final title = message.notification?.title ?? '';

        final String rawSessionId = message.data['session_id']?.toString() ??
            message.data['chat_session_id']?.toString() ??
            message.data['chat_assistance_session_id']?.toString() ??
            message.data['live_session_id']?.toString() ??
            message.data['id']?.toString() ?? '';
        final int parsedSessionId = int.tryParse(rawSessionId) ?? 0;

        if (title.contains('Chat Ended') ||
            type == 'chat_ended' ||
            type == 'CHAT_ENDED' ||
            type == 'session_ended' ||
            type == 'chat_summary') {
          LocalNotificationService.cancelOngoingChatNotification(parsedSessionId > 0 ? parsedSessionId : null);
          FloatingChatBubble.dismiss(stopForegroundService: true);
          return;
        } else if (title.contains('Call Ended') ||
            type == 'call_ended' ||
            type == 'CALL_ENDED' ||
            type == 'session_completed') {
          LocalNotificationService.cancelOngoingCallNotification(parsedSessionId > 0 ? parsedSessionId : null);
          return;
        }

        LocalNotificationService.showNotification(
          id: message.hashCode,
          title: message.notification?.title ?? 'Notification',
          body: message.notification?.body ?? '',
          payload: message.data.toString(),
          notificationType: type,
        );
      }
    });

    // 5. Notification Opened Handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification Opened App: ${message.data}');
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
        debugPrint('[FCM_SERVICE] registerDeviceToken background execution started.');
        if (!Get.isRegistered<ApiClient>()) {
          debugPrint('[FCM_SERVICE] ApiClient is NOT registered in GetX container!');
          return;
        }

        // Safe getToken timeout helper to prevent freeze
        String? tokenToRegister = fcmToken;
        if (tokenToRegister == null) {
          try {
            tokenToRegister = await _firebaseMessaging.getToken().timeout(
              const Duration(seconds: 4),
              onTimeout: () {
                debugPrint('[FCM_SERVICE] _firebaseMessaging.getToken timed out.');
                return null;
              },
            );
          } catch (tokEx) {
            debugPrint('[FCM_SERVICE] Error fetching token with timeout: $tokEx');
          }
        }

        if (tokenToRegister == null || tokenToRegister.isEmpty) {
          debugPrint('[FCM_SERVICE] FCM token is null or empty, skipping API call.');
          return;
        }

        final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        final PackageInfo packageInfo = await PackageInfo.fromPlatform();

        String deviceId = '';
        String deviceModel = '';
        String deviceType = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'unknown');

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

        debugPrint('[FCM_SERVICE] Sending POST to ${AppUrls.registerDeviceToken} with full payload: $payload');
        final apiClient = Get.find<ApiClient>();
        final response = await apiClient.post(AppUrls.registerDeviceToken, data: payload, handleError: false, showToaster: false);
        debugPrint('[FCM_SERVICE] Device token registered response | Status: ${response.statusCode} | Success: ${response.isSuccess}');
      } catch (e, stackTrace) {
        debugPrint('[FCM_SERVICE] Failed to register device token error: $e\n$stackTrace');
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

      final payload = {
        'device_id': deviceId,
        'fcm_token': fcmToken ?? '',
      };

      debugPrint('[FCM_SERVICE] Sending POST to ${AppUrls.removeDeviceToken} with payload: $payload');
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.post(AppUrls.removeDeviceToken, data: payload);
      debugPrint('[FCM_SERVICE] Device token removed response: ${response.body}');
    } catch (e) {
      debugPrint('[FCM_SERVICE] Failed to remove device token: $e');
    }
  }
}
