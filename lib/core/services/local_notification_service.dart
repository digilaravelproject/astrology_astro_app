import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_astrologer/features/call/presentation/pages/call_screen.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Tap handler (navigates back or restores app state)
        if (response.payload != null) {
          if (response.payload!.startsWith('call_')) {
            Get.to(() => const CallScreen());
          } else if (FloatingChatBubble.onTapCallback != null) {
            FloatingChatBubble.onTapCallback?.call();
          }
        }
      },
    );

    // Request permissions for Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showOngoingChatNotification({
    required int sessionId,
    required String title,
    required String body,
    int? startedAtMillis,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'active_chat_channel_v1',
      'Active Chats',
      channelDescription: 'Ongoing notification for active chat sessions',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      showWhen: true,
      usesChronometer: startedAtMillis != null,
      when: startedAtMillis,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      sessionId,
      title,
      body,
      notificationDetails,
      payload: sessionId.toString(),
    );
  }

  static Future<void> cancelOngoingChatNotification(int sessionId) async {
    await _notificationsPlugin.cancel(sessionId);
  }

  static Future<void> showOngoingCallNotification({
    required int sessionId,
    required String title,
    required String body,
    int? startedAtMillis,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'active_call_channel_v1',
      'Active Calls',
      channelDescription: 'Ongoing notification for active call sessions',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      showWhen: true,
      usesChronometer: startedAtMillis != null,
      when: startedAtMillis,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      sessionId + 100000,
      title,
      body,
      notificationDetails,
      payload: 'call_$sessionId',
    );
  }

  static Future<void> cancelOngoingCallNotification(int sessionId) async {
    await _notificationsPlugin.cancel(sessionId + 100000);
  }
}
