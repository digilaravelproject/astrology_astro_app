import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
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
      debugPrint('User declined or has not accepted notification permission');
    }

    // 2. Get FCM Token
    try {
      String? token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }

    // Token refresh listener
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token Refreshed: $newToken');
    });

    // 3. Foreground Notifications Handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground Message Received: ${message.notification?.title}');
    });

    // 4. App Opened From Background Handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification Opened App: ${message.data}');
    });
  }

  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}
