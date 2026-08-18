import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_astrologer/features/call/presentation/controllers/call_controller.dart';
import 'package:astro_astrologer/features/call/presentation/widgets/incoming_call_dialog.dart';
import 'package:astro_astrologer/features/call/presentation/pages/call_screen.dart';
import 'package:astro_astrologer/features/live/presentation/widgets/floating_live_bubble.dart';
import 'package:astro_astrologer/features/live/presentation/controllers/live_controller.dart';
import 'package:astro_astrologer/features/live/presentation/pages/live_schedule_screen.dart';
import 'package:astro_astrologer/features/live/presentation/pages/live_room_screen.dart';

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
            if (Get.isRegistered<CallController>()) {
              final callController = Get.find<CallController>();
              final currentStatus = callController.status.value;

              if (currentStatus == 'ongoing') {
                // Active call — go straight to CallScreen
                Get.to(() => const CallScreen());
              } else if (currentStatus == 'ringing') {
                // Incoming call ringing — show IncomingCallDialog
                if (Get.isDialogOpen != true) {
                  final sdp = callController.incomingOfferSdp ?? '';
                  Get.dialog(
                    IncomingCallDialog(offerSdp: sdp),
                    barrierDismissible: false,
                  );
                }
              } else {
                // App was killed/restarted — check pending or current session
                callController.checkPendingCall();
              }
            }
          } else if (response.payload!.startsWith('live_')) {
            if (Get.isRegistered<LiveController>()) {
              final liveController = Get.find<LiveController>();
              if (liveController.isRoomOpen) {
                return;
              }
              final ongoingSession = liveController.currentActiveSession.value;
              if (ongoingSession != null) {
                liveController.isRoomOpen = true;
                Get.to(() => LiveRoomScreen(session: ongoingSession))?.then((_) {
                  liveController.isRoomOpen = false;
                });
              } else {
                Get.to(() => const LiveScheduleScreen());
              }
            } else {
              Get.to(() => const LiveScheduleScreen());
            }
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

  static Future<void> showIncomingCallNotification({
    required int sessionId,
    required String title,
    required String body,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'incoming_call_channel_v1',
      'Incoming Calls',
      channelDescription: 'Alert for incoming calls',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: false,
      autoCancel: true,
      onlyAlertOnce: false,
      showWhen: true,
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
      sessionId + 200000,
      title,
      body,
      notificationDetails,
      payload: 'call_$sessionId',
    );
  }

  static Future<void> cancelIncomingCallNotification(int sessionId) async {
    await _notificationsPlugin.cancel(sessionId + 200000);
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

  static Future<void> showOngoingLiveNotification({
    required int sessionId,
    required String title,
    required String body,
    int? startedAtMillis,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'active_live_channel_v1',
      'Active Live Sessions',
      channelDescription: 'Ongoing notification for active live stream sessions',
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
      sessionId + 300000,
      title,
      body,
      notificationDetails,
      payload: 'live_$sessionId',
    );
  }

  static Future<void> cancelOngoingLiveNotification(int sessionId) async {
    await _notificationsPlugin.cancel(sessionId + 300000);
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'astology_notifications',
      'System & General Notifications',
      channelDescription: 'General updates and system notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
