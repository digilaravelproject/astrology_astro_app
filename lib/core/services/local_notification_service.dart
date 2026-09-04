import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/services/callkit_service.dart';
import 'package:astro_astrologer/core/services/foreground_task_service.dart';
import 'package:astro_astrologer/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_astrologer/features/call/presentation/controllers/call_controller.dart';
import 'package:astro_astrologer/features/call/presentation/pages/call_screen.dart';
import 'package:astro_astrologer/features/live/presentation/widgets/floating_live_bubble.dart';
import 'package:astro_astrologer/features/live/presentation/controllers/live_controller.dart';
import 'package:astro_astrologer/features/live/presentation/pages/live_schedule_screen.dart';
import 'package:astro_astrologer/core/constants/app_constants.dart';
import 'package:astro_astrologer/features/live/presentation/pages/live_room_screen.dart';
import 'package:astro_astrologer/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_astrologer/features/chat/presentation/bindings/chat_binding.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/services/websocket/websocket_service.dart';
import 'package:astro_astrologer/routes/app_routes.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint('notificationTapBackground: actionId=${notificationResponse.actionId}, payload=${notificationResponse.payload}');
  // Background action handler logic will go here
  if (notificationResponse.actionId == 'decline') {
    debugPrint('User declined from background!');
    // Ideally call API to decline, or just dismiss
  } else if (notificationResponse.actionId == 'answer') {
    debugPrint('User answered from background!');
  }
}

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize({bool requestPermission = true}) async {
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
        if (response.payload != null) {
          final isAnswer = response.actionId == 'answer';
          final isDecline = response.actionId == 'decline';
          handleNotificationRouting(response.payload!, isAnswer, isDecline);
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Initialize CallKit service
    CallkitService.init();

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

      if (requestPermission) {
        await androidPlugin.requestNotificationsPermission();
      }
    }

    final iosPlugin =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
    if (iosPlugin != null && requestPermission) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
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
    List<AndroidNotificationAction>? actions,
    bool fullScreenIntent = false,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId,
      channelDescription: 'Foreground push notification',
      importance: importance,
      priority: priority,
      playSound: playSound,
      icon: '@mipmap/ic_launcher',
      actions: actions,
      fullScreenIntent: fullScreenIntent,
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

  static final Set<String> _cancelledSessions = {};

  static void markSessionCancelled(String sessionId) {
    _cancelledSessions.add(sessionId);
  }

  static bool isSessionCancelled(String sessionId) {
    return _cancelledSessions.contains(sessionId);
  }

  static void handleNotificationRouting(String payload, bool isAnswer, bool isDecline, {String? callerName}) async {
    debugPrint('Routing payload: $payload, isAnswer: $isAnswer, isDecline: $isDecline');
    final bool isChat = payload.startsWith('chat_');
    final int? sessionId = isChat ? int.tryParse(payload.replaceFirst('chat_', '')) : null;

    if (isDecline) {
      debugPrint('Routing: User declined the request.');
      if (isChat && sessionId != null) {
        try {
          await Get.find<ApiClient>().post(AppUrls.rejectChatSession(sessionId));
        } catch (e) {
          debugPrint('Reject error from CallKit: $e');
        }
        FloatingChatBubble.dismiss();
      }
      return;
    }

    if (isAnswer && isChat && sessionId != null) {
      _acceptChatAndNavigate(sessionId, overrideName: callerName);
      return;
    }

    if (payload.startsWith('call_')) {
      if (Get.isRegistered<CallController>()) {
        final callController = Get.find<CallController>();
        final currentStatus = callController.status.value;

        if (currentStatus == 'completed' ||
            currentStatus == 'ended' ||
            currentStatus == 'cancelled' ||
            currentStatus == 'idle') {
          debugPrint('[LocalNotificationService] Stale call tapped, cancelling...');
        } else if (currentStatus == 'ongoing') {
          Get.toNamed(AppRoutes.callScreen);
        } else if (currentStatus == 'ringing') {
          // If they tap a notification while ringing, trigger CallKit
          final String name = (callController.consumerName != null && callController.consumerName!.isNotEmpty) ? callController.consumerName! : 'User';
          final String userAvatar = (callController.consumerImage != null && callController.consumerImage!.isNotEmpty && callController.consumerImage != 'null') ? callController.consumerImage! : 'assets/images/app_logo.png';
          
          CallkitService.showCallkitNotification(
            sessionId: callController.sessionId.toString(),
            callerName: name,
            avatar: userAvatar,
            type: 'call',
          );
        } else {
          callController.checkPendingCall();
        }
      } else {
        debugPrint('[LocalNotificationService] Cold start init CallController...');
        final sessionIdStr = payload.replaceFirst('call_', '');
        final int? sessionId = int.tryParse(sessionIdStr);
        
        if (isAnswer && sessionId != null) {
          Get.toNamed(AppRoutes.callScreen);
        } else {
          try {
            final callController = Get.find<CallController>();
            callController.checkPendingCall();
          } catch (e) {
            debugPrint('[LocalNotificationService] CallController not registered: $e');
          }
        }
      }
    } else if (payload.startsWith('live_')) {
      if (Get.isRegistered<LiveController>()) {
        final liveController = Get.find<LiveController>();
        if (liveController.isRoomOpen) return;
        final ongoingSession = liveController.currentActiveSession.value;
        if (ongoingSession != null) {
          liveController.isRoomOpen = true;
          Get.toNamed(AppRoutes.liveRoomScreen, arguments: ongoingSession)?.then((_) {
            liveController.isRoomOpen = false;
          });
        } else {
          Get.to(() => const LiveScheduleScreen());
        }
      } else {
        Get.to(() => const LiveScheduleScreen());
      }
    } else if (payload.startsWith('wallet_')) {
      debugPrint('[LocalNotificationService] Wallet notification tapped. Payload: $payload');
      // TODO: Navigate to Wallet screen when route is available
      // Get.toNamed('/wallet');
    } else {
      final rawPayloadStr = payload.replaceFirst('chat_', '').replaceFirst('CHAT_REQUEST_', '');
      final int? sId = int.tryParse(rawPayloadStr);
      if (sId != null) {
        if (isDecline) {
          try {
            Get.find<ApiClient>().post(AppUrls.rejectChatSession(sId));
          } catch (e) {
            debugPrint('Reject error: $e');
          }
          FloatingChatBubble.dismiss();
          return;
        }
        
        // Auto-accept and navigate if they tap the notification (unless they explicitly declined)
        _acceptChatAndNavigate(sId);
        return;
      }
    }
  }

  static Future<void> _acceptChatAndNavigate(int sId, {String? overrideName}) async {
    try {
      final response = await Get.find<ApiClient>().post(AppUrls.acceptChatSession(sId));
      if (response.isSuccess) {
        FlutterCallkitIncoming.endCall(sId.toString());
        FloatingChatBubble.dismiss();
        
        final startedAt = response.body?['data']?['session']?['started_at']?.toString() ?? DateTime.now().toUtc().toIso8601String();
        
        String uName = 'User';
        if (overrideName != null && overrideName.isNotEmpty) {
          uName = overrideName;
        } else if (WebSocketService.lastChatSenderData != null && WebSocketService.lastChatSenderData!['name'] != null) {
          uName = WebSocketService.lastChatSenderData!['name'].toString();
        } else if (FloatingChatBubble.name?.isNotEmpty == true) {
          uName = FloatingChatBubble.name!;
        }

        if (Get.context != null) {
          // Initialize the floating bubble manually so the UI knows the correct name
          FloatingChatBubble.show(
            sessionId: sId,
            name: uName,
            imageUrl: '',
            status: 'ongoing',
            startedAt: startedAt,
            onTap: () {
              // Usually the bubble handles its own tap now, or we can just navigate if needed.
              // But Get.to inside onTap might be redundant if the bubble already does it.
              // Let's just pass an empty callback or a navigation callback.
              Get.to(
                () => ChatScreen(
                  userName: uName,
                  userImage: '',
                  sessionId: sId,
                  initialStatus: 'ongoing',
                  startedAtString: startedAt,
                ),
                binding: ChatBinding(),
              );
            },
          );
          
          Get.to(
            () => ChatScreen(
              userName: uName, 
              userImage: '', 
              sessionId: sId, 
              initialStatus: 'ongoing',
              startedAtString: startedAt,
            ),
            binding: ChatBinding(),
          );
        } else {
          debugPrint('Cannot route to ChatScreen or show bubble: Get.context is null (background isolate?)');
        }
      }
    } catch (e) {
      debugPrint('Accept error: $e');
    }
  }
}
