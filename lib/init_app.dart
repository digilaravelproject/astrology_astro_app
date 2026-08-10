import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/services/DynamicAppIcon/dynamic_app_icon_manager.dart';
import 'core/services/config/env_config.dart';
import 'features/language/controllers/localization_controller.dart';
import 'core/theme/theme_controller.dart';
import 'core/services/storage/shared_prefs.dart';
import 'translations/translations.dart';
import 'core/services/local_notification_service.dart';
import 'core/services/foreground_task_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

import 'core/services/fcm_notification_service.dart';

Future<void> initApp() async {
  // Set environment configuration
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Initialize Firestore settings
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  await EnvConfig.load();
  // EnvConfig.setEnvironment(Environment.development); // Change as needed


  // Initialize dynamic app icon manager
  // await DynamicAppIconManager.init();


  // Initialize shared preferences
  await SharedPrefs.init();

  // Initialize notifications
  await LocalNotificationService.initialize();

  // Initialize foreground task service
  await ForegroundTaskService.init();

  // Register controllers
  // Get.lazyPut(() => ThemeController());
  Get.put(ThemeController()); // instead of Get.lazyPut

  Get.lazyPut(() => LocalizationController());

  // Initialize theme
  // await Get.find<ThemeController>().initTheme();

  // Initialize language
  await Get.find<LocalizationController>().initLanguage();

  // Initialize translations
  AppTranslations translations = await AppTranslations.load();
  Get.put<Translations>(translations);

  // Initialize FCM Notification service (Foreground + Background + Terminated)
  await FCMNotificationService.initialize();
}
