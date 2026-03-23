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

void main() async {
  await initApp();
  runApp(const MyApp());
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
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeController.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      // theme: themeController.isDarkMode ? darkTheme : lightTheme,
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
