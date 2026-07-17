import 'package:astro_astrologer/core/constants/app_constants.dart';
import 'package:astro_astrologer/core/theme/dark_theme.dart';
import 'package:astro_astrologer/core/theme/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/theme_controller.dart';
import 'features/language/controllers/localization_controller.dart';
import 'init_app.dart';
import 'routes/route_helper.dart';
import 'core/bindings/initial_bindings.dart';
import 'core/utils/custom_snackbar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:astro_astrologer/core/services/local_notification_service.dart';

import 'features/chat/presentation/widgets/overlay_main.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await LocalNotificationService.initialize();
    final data = message.data;
    if (data.containsKey('session')) {
      final sessionData = data['session'] is String 
          ? jsonDecode(data['session']) 
          : data['session'];
      final callerData = data['callerData'] is String 
          ? jsonDecode(data['callerData']) 
          : data['callerData'];
          
      final sessionId = int.tryParse(sessionData?['id']?.toString() ?? '') ?? 0;
      final consumerName = callerData?['name']?.toString() ?? 'User';
      
      if (sessionId > 0) {
        await LocalNotificationService.showIncomingCallNotification(
          sessionId: sessionId,
          title: 'Incoming Call',
          body: 'Call from $consumerName',
        );
      }
    }
  } catch (e) {
    debugPrint('Background message handling error: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

    return Obx(() => GetMaterialApp(
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
        localizationController.languages[localizationController.selectedIndex].languageCode,
        localizationController.languages[localizationController.selectedIndex].countryCode,
      ),
      fallbackLocale: const Locale('en', 'US'),
      translations: Get.find<Translations>(),
    ));
  }
}
