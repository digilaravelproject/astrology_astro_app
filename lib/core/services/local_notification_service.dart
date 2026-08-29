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

              if (currentStatus == 'completed' || currentStatus == 'ended' || currentStatus == 'cancelled' || currentStatus == 'idle') {
                debugPrint('[LocalNotificationService] Stale call notification tapped, cancelling...');
                final sessionIdStr = response.payload!.replaceFirst('call_', '');
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
              debugPrint('[LocalNotificationService] Stale call notification tapped (no controller), cancelling...');
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
          } else {
            final int? sId = int.tryParse(response.payload!);
            if (sId != null) {
              String uName = FloatingChatBubble.name?.isNotEmpty == true
                  ? FloatingChatBubble.name!
                  : 'User';
              String uStatus = FloatingChatBubble.chatStatus.value.isNotEmpty
                  ? FloatingChatBubble.chatStatus.value
                  : 'ongoing';

              Get.to(() => ChatScreen(
                    userName: uName,
                    userImage: '',
                    sessionId: sId,
                    initialStatus: uStatus,
                  ), binding: ChatBinding());
            }
          }
        }
      },
    );

    // Pre-create notification channels explicitly
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'calls_channel_v2',
          'Incoming Calls',
          description: 'Incoming Call Ringing (User & Astrologer)',
          importance: Importance.max,
          playSound: false,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'chats_channel_v2',
          'Chat Messages & Requests',
          description: 'New Chat Requests and Chat Room messages',
          importance: Importance.high,
          playSound: false,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'session_channel_v2',
          'Consultations & Billing',
          description: 'Session Lifecycle, Acceptance, Ending & Billing Notifications',
          importance: Importance.high,
          playSound: false,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'wallet_channel_v2',
          'Wallet & Gifts',
          description: 'Wallet Top-Up, Gifts & Transactions',
          importance: Importance.defaultImportance,
          playSound: false,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'system_channel_v2',
          'Account & System Alerts',
          description: 'Account status and system notifications',
          importance: Importance.defaultImportance,
          playSound: false,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'active_chat_channel_v1',
          'Active Chats',
          description: 'Ongoing notification for active chat sessions',
          importance: Importance.max,
          playSound: false,
          enableVibration: false,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'active_call_channel_v1',
          'Active Calls',
          description: 'Ongoing notification for active call sessions',
          importance: Importance.max,
          playSound: false,
          enableVibration: false,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'incoming_call_channel_v1',
          'Incoming Calls Alert',
          description: 'Alert for incoming call notifications',
          importance: Importance.max,
          playSound: false,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'active_consultation_foreground_channel_v4',
          'Active Consultation Service',
          description: 'Ongoing active call and chat consultation status',
          importance: Importance.max,
          playSound: false,
          enableVibration: false,
        ),
      );
      await androidPlugin.requestNotificationsPermission();
    }
  }

  static const int ACTIVE_CHAT_NOTIFICATION_ID = 777777;
  static const int ACTIVE_CALL_NOTIFICATION_ID = 888888;

  
  
  
  
  
  
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
