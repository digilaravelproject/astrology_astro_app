import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/core/widgets/app_text.dart';
import 'package:astro_astrologer/routes/route_helper.dart';
import 'package:astro_astrologer/core/services/storage/shared_prefs.dart';
import 'package:astro_astrologer/core/constants/app_constants.dart';
import 'package:astro_astrologer/core/services/network/websocket_service.dart';
import 'package:astro_astrologer/core/services/fcm_notification_service.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen>
    with WidgetsBindingObserver {
  bool isCameraGranted = false;
  bool isMicrophoneGranted = false;
  bool isNotificationGranted = false;
  bool isSystemAlertWindowGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    isCameraGranted = await Permission.camera.isGranted;
    isMicrophoneGranted = await Permission.microphone.isGranted;
    isNotificationGranted = await Permission.notification.isGranted;
    isSystemAlertWindowGranted = await Permission.systemAlertWindow.isGranted;
    if (mounted) {
      setState(() {});
    }
  }

  bool get _allPermissionsGranted {
    return isCameraGranted && 
           isMicrophoneGranted && 
           isNotificationGranted && 
           isSystemAlertWindowGranted;
  }

  void _navigateToNext() {
    final isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;
    final userData = SharedPrefs.getString(AppConstants.userData);
    
    // Set flag so we don't show this screen again on every startup
    SharedPrefs.setBool(AppConstants.hasSeenPermission, true);

    debugPrint(
      '[PERMISSION_SCREEN] _navigateToNext. isLoggedIn: $isLoggedIn, userData exists: ${userData != null}',
    );

    try {
      if (isLoggedIn && userData != null && userData.isNotEmpty) {
        if (Get.isRegistered<WebSocketService>()) {
          Get.find<WebSocketService>().connect();
        }
        FCMNotificationService.registerDeviceToken(null);
        Get.offAllNamed(RouteHelper.getDashboardRoute());
      } else {
        Get.offAllNamed(RouteHelper.getLoginRoute());
      }
    } catch (e, s) {
      debugPrint('[PERMISSION_SCREEN] Error in _navigateToNext: $e\n$s');
      // Fallback redirection to avoid screen stuck
      Get.offAllNamed(RouteHelper.getLoginRoute());
    }
  }

  Future<void> _requestPermissions() async {
    List<Permission> permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.notification,
      Permission.systemAlertWindow,
    ];

    await permissions.request();
    await _checkPermissions();

    if (!_allPermissionsGranted) {
      bool cameraPermanentlyDenied =
          await Permission.camera.isPermanentlyDenied;
      bool micPermanentlyDenied =
          await Permission.microphone.isPermanentlyDenied;
      bool notifPermanentlyDenied =
          await Permission.notification.isPermanentlyDenied;
      bool alertPermanentlyDenied =
          await Permission.systemAlertWindow.isPermanentlyDenied;

      if (cameraPermanentlyDenied ||
          micPermanentlyDenied ||
          notifPermanentlyDenied ||
          alertPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Some permissions are permanently denied. Please enable them in settings.',
              ),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () {
                  openAppSettings();
                },
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Icon(
                  Icons.security_rounded,
                  size: 80,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 30),
              AppText(
                'Required Permissions',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 10),
              AppText(
                'To provide you with the best experience, we need access to the following permissions.',
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              const SizedBox(height: 40),
              _buildPermissionItem(
                icon: Icons.camera_alt_outlined,
                title: 'Camera',
                description: 'Required for video consultations.',
                isGranted: isCameraGranted,
              ),
              const SizedBox(height: 20),
              _buildPermissionItem(
                icon: Icons.mic_none_outlined,
                title: 'Microphone',
                description: 'Required for voice and video consultations.',
                isGranted: isMicrophoneGranted,
              ),
              const SizedBox(height: 20),
              _buildPermissionItem(
                icon: Icons.notifications_none_outlined,
                title: 'Notifications',
                description: 'To notify you about chat and call requests.',
                isGranted: isNotificationGranted,
              ),
              const SizedBox(height: 20),
              _buildPermissionItem(
                icon: Icons.filter_none,
                title: 'Display over other apps',
                description: 'Required to show incoming calls when app is closed.',
                isGranted: isSystemAlertWindowGranted,
              ),
              const Spacer(),
              if (!_allPermissionsGranted)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _requestPermissions,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppColors.primaryColor, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: AppText(
                      'Allow Permissions',
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              if (!_allPermissionsGranted) const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _navigateToNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: AppText(
                    'Go to Dashboard',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isGranted,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                isGranted
                    ? Colors.green.withOpacity(0.1)
                    : AppColors.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isGranted ? Colors.green : AppColors.primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(title, fontWeight: FontWeight.bold, fontSize: 16),
              const SizedBox(height: 4),
              AppText(description, color: Colors.grey.shade600, fontSize: 13),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (isGranted)
          const Icon(Icons.check_circle, color: Colors.green)
        else
          Icon(Icons.cancel, color: Colors.grey.shade400),
      ],
    );
  }
}
