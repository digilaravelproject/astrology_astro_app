import 'package:astro_astrologer/core/constants/app_constants.dart';
import 'package:astro_astrologer/core/theme/dark_theme.dart';
import 'package:astro_astrologer/core/theme/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'core/theme/theme_controller.dart';
import 'features/language/presentation/controllers/localization_controller.dart';
import 'init_app.dart';
import 'routes/route_helper.dart';
import 'core/bindings/initial_bindings.dart';
import 'core/utils/custom_snackbar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:astro_astrologer/firebase_options.dart';
import 'package:astro_astrologer/core/services/local_notification_service.dart';
import 'package:astro_astrologer/core/services/config/env_config.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:astro_astrologer/core/services/callkit_service.dart';
import 'package:astro_astrologer/core/services/websocket/websocket_service.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'dart:convert';

import 'features/chat/presentation/widgets/overlay_main.dart';
import 'package:astro_astrologer/core/services/foreground_task_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await EnvConfig.load();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await LocalNotificationService.initialize(requestPermission: false);
    
    // Initialize WebSocket in background so it can listen to dismissal events immediately
    try {
      Get.put(WebSocketService());
      await Get.find<WebSocketService>().init();
    } catch (e) {
      debugPrint('Background WebSocket initialization failed: $e');
    }

    final data = message.data;
    final title = message.notification?.title ?? data['title']?.toString() ?? '';
    final body = message.notification?.body ?? data['body']?.toString() ?? '';
    final type = data['type']?.toString();

    final String rawSessionId =
        data['session_id']?.toString() ??
        data['chat_session_id']?.toString() ??
        data['chat_assistance_session_id']?.toString() ??
        data['live_session_id']?.toString() ??
        data['id']?.toString() ??
        'unknown_session';
    final int parsedSessionId = int.tryParse(rawSessionId) ?? 0;

    final String? reason = data['reason']?.toString()?.toLowerCase();
    
    if (title.contains('Chat Ended') ||
        title.contains('Cancelled') ||
        reason == 'cancelled' ||
        reason == 'rejected' ||
        type == 'chat_ended' ||
        type == 'CHAT_ENDED' ||
        type == 'session_ended' ||
        type == 'chat_summary' ||
        type == 'CHAT_MISSED' ||
        type?.toLowerCase() == 'chat_dismissed') {
      LocalNotificationService.markSessionCancelled(parsedSessionId.toString());
      CallkitService.endCall(parsedSessionId.toString());
      LocalNotificationService.cancelOngoingLiveNotification(parsedSessionId);
      ForegroundTaskService.stopService();
      return;
    } else if (title.contains('Call Ended') ||
        type?.toLowerCase() == 'call_ended' ||
        type?.toLowerCase() == 'session_completed' ||
        type?.toLowerCase() == 'call_failed' ||
        type?.toLowerCase() == 'call_dismissed') {
      LocalNotificationService.markSessionCancelled(parsedSessionId.toString());
      CallkitService.endCall(parsedSessionId.toString());
      LocalNotificationService.cancelOngoingLiveNotification(parsedSessionId);
      ForegroundTaskService.stopService();
      return;
    } else if (type?.toUpperCase() == 'CHAT_REQUEST' || type?.toUpperCase() == 'CALL_REQUEST' || type?.toLowerCase() == 'call' || type?.toLowerCase() == 'audio_call' || type?.toLowerCase() == 'video_call' || type?.toLowerCase() == 'chat') {
      final String channelType = data['channel_type']?.toString() ?? ((type?.toLowerCase() == 'call' || type?.toLowerCase() == 'audio_call' || type?.toLowerCase() == 'video_call') ? 'call' : 'chat');
      final String userName = data['user_name']?.toString() ?? data['caller_name']?.toString() ?? 'User';
      
      final String notifTitle = channelType == 'call' ? 'Incoming Call' : 'Chat Request';
      final String nameCallerParam = channelType == 'call' ? userName : 'Chat Req: $userName';
      final String notifBody = '$userName • Astrologer • Now';
      final String payloadStr = '${channelType}_$parsedSessionId';
      
      final String userAvatarRaw = data['user_avatar']?.toString() ?? data['caller_image']?.toString() ?? '';
      final String userAvatar = userAvatarRaw.isNotEmpty ? userAvatarRaw : 'assets/images/app_logo.png';

      CallKitParams callKitParams = CallKitParams(
        id: parsedSessionId.toString(),
        nameCaller: nameCallerParam,
        appName: AppConstants.appName,
        avatar: userAvatar,
        handle: notifTitle,
        type: 0,
        duration: 30000,
        extra: <String, dynamic>{'payload': payloadStr, 'sessionId': parsedSessionId},
        headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
        android: const AndroidParams(
          isCustomNotification: false,
          isShowLogo: false,
          isShowFullLockedScreen: true,
          ringtonePath: 'system_ringtone_default',
          backgroundColor: '#FFFFFF',
          backgroundUrl: 'assets/images/background.png',
          actionColor: '#4CAF50',
          textColor: '#000000',
          textAccept: 'Accept',
          textDecline: 'Decline',
        ),
      );
      
      await CallkitService.showIncomingCall(callKitParams);
    } else {
      String payloadStr = '';
      if (type?.toLowerCase() == 'gift' || type?.toLowerCase() == 'payout_settlement' || type?.toLowerCase() == 'wallet') {
        final ref = data['reference_id']?.toString() ?? data['entity_id']?.toString() ?? '';
        payloadStr = ref.isNotEmpty ? 'wallet_$ref' : data.toString();
      } else {
        payloadStr = rawSessionId.isNotEmpty ? rawSessionId : data.toString();
      }

      String channelId = 'general';
      if (payloadStr.startsWith('wallet_')) channelId = 'wallet';

      LocalNotificationService.showNotification(
        notificationId: parsedSessionId > 0 ? parsedSessionId : null,
        title: title,
        body: body,
        payload: payloadStr,
        channelId: channelId,
        playSound: true,
        priority: Priority.high,
        importance: Importance.max,
      );
    }

    if (data.containsKey('session')) {
      final sessionData =
          data['session'] is String
              ? jsonDecode(data['session'])
              : data['session'];
      final callerData =
          data['callerData'] is String
              ? jsonDecode(data['callerData'])
              : data['callerData'];

      final sessionId = int.tryParse(sessionData?['id']?.toString() ?? '') ?? 0;
      final consumerName = callerData?['name']?.toString() ?? 'User';

      if (sessionId > 0) {}
    }
  } catch (e) {
    debugPrint('Background message handling error: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await initApp();
  runApp(const MyApp());
}

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OverlayChatBubbleApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();
    final LocalizationController localizationController = Get.find();

    return Obx(
      () => GetMaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        navigatorKey: Get.key,
        initialBinding: InitialBindings(),
        // theme: lightTheme,
        // darkTheme: lightTheme,
        // themeMode: ThemeMode.light,
        initialRoute: '${RouteHelper.getSplashRoute()}',
        getPages: RouteHelper.routes,
        defaultTransition: Transition.fadeIn,
        locale: Locale(
          localizationController
              .languages[localizationController.selectedIndex]
              .languageCode,
          localizationController
              .languages[localizationController.selectedIndex]
              .countryCode,
        ),
        fallbackLocale: const Locale('en', 'US'),
        translations: Get.find<Translations>(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales:
            localizationController.languages
                .map((lang) => Locale(lang.languageCode!, lang.countryCode!))
                .toList(),
        builder: (context, child) {
          return SafeArea(
            top: false,
            bottom: true,
            child: child ?? const SizedBox(),
          );
        },
      ),
    );
  }
}
