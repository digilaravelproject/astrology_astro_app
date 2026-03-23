import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../../core/utils/logger.dart';

class CustomSnackBar {
  /// Generic method so all snackbar styles are consistent
  static void _show({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Color? textColor,
  }) {
    debugPrint('CustomSnackBar triggered: $title - $message');
    // Logger.d('SnackBar: showing $title - $message');
    // Auto-adjust text color for readability
    final Color effectiveTextColor =
        textColor ??
        (backgroundColor.computeLuminance() > 0.5
            ? Colors.black
            : Colors.white);

    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: effectiveTextColor,
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      icon: Icon(icon, color: effectiveTextColor),
      shouldIconPulse: false,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      isDismissible: true,
    );
  }

  static void showSuccess(String message, {String title = 'success'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.successColor,
      icon: Icons.check_circle,
    );
  }

  static void showError(String message, {String title = 'error'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.errorColor,
      icon: Icons.error,
    );
  }

  static void showInfo(String message, {String title = 'Info'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.infoColor,
      icon: Icons.info,
    );
  }

  static void showWarning(String message, {String title = 'Warning'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.warningColor,
      icon: Icons.warning,
    );
  }
}
