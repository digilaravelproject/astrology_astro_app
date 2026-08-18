import 'dart:io';
import 'package:device_info_plus/device_info_plus';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus';
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
        deviceModel = iosInfo.utmMachine ?? iosInfo.model;
      }

      final payload = {
        'fcm_token': fcmToken,
        'device_type': deviceType,
        'device_id': deviceId,
        'device_model': deviceModel,
        'app_version': packageInfo.version,
      };

      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.post(AppUrls.registerDeviceToken, data: payload);
      debugPrint('Device token registered response: ${response.data}');
    } catch (e) {
      debugPrint('Failed to register device token: $e');
    }
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

      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.post(AppUrls.removeDeviceToken, data: payload);
      debugPrint('Device token removed response: ${response.data}');
    } catch (e) {
      debugPrint('Failed to remove device token: $e');
    }
  }
}
