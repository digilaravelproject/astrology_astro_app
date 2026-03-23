import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_text.dart';

class CustomSnackBar {
  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  static void _show({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Color? textColor,
  }) {
    final Color effectiveTextColor =
        textColor ??
        (backgroundColor.computeLuminance() > 0.5
            ? Colors.black
            : Colors.white);

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: effectiveTextColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(title.toUpperCase(), fontSize: 12, fontWeight: FontWeight.bold, color: effectiveTextColor),
                AppText(message, fontSize: 13, color: effectiveTextColor),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
    );

    messengerKey.currentState?.hideCurrentSnackBar();
    messengerKey.currentState?.showSnackBar(snackBar);
  }

  static void showSuccess(String message, {String title = 'Success'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.successColor,
      icon: Icons.check_circle_rounded,
    );
  }

  static void showError(String message, {String title = 'Error'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.errorColor,
      icon: Icons.error_rounded,
    );
  }

  static void showInfo(String message, {String title = 'Info'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.infoColor,
      icon: Icons.info_rounded,
    );
  }

  static void showWarning(String message, {String title = 'Warning'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.warningColor,
      icon: Icons.warning_rounded,
    );
  }
}
