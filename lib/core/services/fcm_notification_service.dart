import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';

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
    });

    // 5. Notification Opened Handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification Opened App: ${message.data}');
    });
  }

  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Register or Refresh FCM Device Token on Backend
  static Future<void> registerDeviceToken(String fcmToken) async {
    try {
      if (!Get.isRegistered<ApiClient>()) return;

      String deviceType = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'unknown');

      final payload = {
        'fcm_token': fcmToken,
        'device_type': deviceType,
      };

      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.post(AppUrls.registerDeviceToken, data: payload);
      debugPrint('Device token registered response: ${response.body}');
    } catch (e) {
      debugPrint('Failed to register device token: $e');
    }
  }

  /// Remove Device Token on Logout
  static Future<void> removeDeviceToken() async {
    try {
      if (!Get.isRegistered<ApiClient>()) return;

      final String? fcmToken = await getToken();

      final payload = {
        'fcm_token': fcmToken ?? '',
      };

      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.post(AppUrls.removeDeviceToken, data: payload);
      debugPrint('Device token removed response: ${response.body}');
    } catch (e) {
      debugPrint('Failed to remove device token: $e');
    }
  }
}
