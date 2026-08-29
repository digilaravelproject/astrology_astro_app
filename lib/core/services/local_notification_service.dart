import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/services/foreground_task_service.dart';
import 'package:astro_astrologer/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_astrologer/features/call/presentation/controllers/call_controller.dart';
import 'package:astro_astrologer/features/call/presentation/widgets/incoming_call_dialog.dart';
import 'package:astro_astrologer/features/call/presentation/pages/call_screen.dart';
import 'package:astro_astrologer/features/live/presentation/widgets/floating_live_bubble.dart';
import 'package:astro_astrologer/features/live/presentation/controllers/live_controller.dart';
import 'package:astro_astrologer/features/live/presentation/pages/live_schedule_screen.dart';
import 'package:astro_astrologer/core/constants/app_constants.dart';
import 'package:astro_astrologer/features/live/presentation/pages/live_room_screen.dart';
import 'package:astro_astrologer/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_astrologer/features/chat/presentation/bindings/chat_binding.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
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

              if (currentStatus == 'completed' ||
                  currentStatus == 'ended' ||
                  currentStatus == 'cancelled' ||
                  currentStatus == 'idle') {
                debugPrint(
                  '[LocalNotificationService] Stale call notification tapped, cancelling...',
                );
                final sessionIdStr = response.payload!.replaceFirst(
                  'call_',
                  '',
                );
                final int? sessionId = int.tryParse(sessionIdStr);
              } else if (currentStatus == 'ongoing') {
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
            } else {
              // CallController not registered, likely stale or cold start
              debugPrint(
                '[LocalNotificationService] Stale call notification tapped (no controller), cancelling...',
              );
              final sessionIdStr = response.payload!.replaceFirst('call_', '');
              final int? sessionId = int.tryParse(sessionIdStr);
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
                Get.to(() => LiveRoomScreen(session: ongoingSession))?.then((
                  _,
                ) {
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
          } else {
            final int? sId = int.tryParse(response.payload!);
            if (sId != null) {
              String uName =
                  FloatingChatBubble.name?.isNotEmpty == true
                      ? FloatingChatBubble.name!
                      : 'User';
              String uStatus =
                  FloatingChatBubble.chatStatus.value.isNotEmpty
                      ? FloatingChatBubble.chatStatus.value
                      : 'ongoing';

              Get.to(
                () => ChatScreen(
                  userName: uName,
                  userImage: '',
                  sessionId: sId,
                  initialStatus: uStatus,
                ),
                binding: ChatBinding(),
              );
            }
          }
        }
      },
    );

    // Pre-create notification channels explicitly

    final androidPlugin =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'call',
          'Incoming Call',
          description: 'Incoming audio/video call alerts',
          importance: Importance.max,
          sound: RawResourceAndroidNotificationSound('call_ringtone'),
          playSound: true,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'chat',
          'Chat Message',
          description: 'New chat message alerts',
          importance: Importance.high,
          playSound: true,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'chat_request',
          'Chat Requests',
          description: 'New chat consultation requests',
          importance: Importance.high,
          playSound: true,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'call_request',
          'Call Requests',
          description: 'New call consultation requests',
          importance: Importance.high,
          playSound: true,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'live_stream',
          'Live Stream Alerts',
          description: 'Astrologer live stream broadcast notifications',
          importance: Importance.high,
          playSound: true,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'wallet',
          'Wallet & Orders',
          description: 'Payment, wallet, order updates',
          importance: Importance.defaultImportance,
          playSound: true,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'general',
          'General Announcements',
          description: 'General/promotional alerts',
          importance: Importance.defaultImportance,
          playSound: true,
        ),
      );

      await androidPlugin.requestNotificationsPermission();
    }
  }

  // ---------------------------------------------------------------------
  // Helper: Show a local notification (used for foreground FCM messages)
  // ---------------------------------------------------------------------
  static Future<void> showNotification({
    required String title,
    required String body,
    required String payload,
    required String channelId,
    int? notificationId,
    bool playSound = false,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId,
      channelDescription: 'Foreground push notification',
      importance: importance,
      priority: priority,
      playSound: playSound,
      icon: '@mipmap/ic_launcher',
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: playSound,
      ),
    );

    await _notificationsPlugin.show(
      notificationId ?? DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static const int ACTIVE_CHAT_NOTIFICATION_ID = 777777;
  static const int ACTIVE_CALL_NOTIFICATION_ID = 888888;

  static Future<void> showOngoingLiveNotification({
    required int sessionId,
    required String title,
    required String body,
    int? startedAtMillis,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'active_live_channel_v1',
          'Active Live Sessions',
          channelDescription:
              'Ongoing notification for active live stream sessions',
          icon: '@mipmap/ic_launcher',
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
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: false,
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
}
