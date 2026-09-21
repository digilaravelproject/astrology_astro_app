import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'home_screen.dart';
import 'package:astro_astrologer/features/profile/presentation/screens/profile_screen.dart';
import 'package:astro_astrologer/features/home/presentation/controllers/dashboard_controller.dart';
import 'package:astro_astrologer/core/widgets/custom_bottom_nav_bar.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:astro_astrologer/features/live/presentation/pages/live_schedule_screen.dart';
import 'package:astro_astrologer/features/live/presentation/controllers/live_controller.dart';
import 'package:astro_astrologer/core/widgets/app_text.dart';
import 'package:astro_astrologer/features/notification/notice_screen.dart';
import 'package:astro_astrologer/features/orders/presentation/pages/orders_screen.dart';
import 'package:astro_astrologer/routes/app_routes.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:astro_astrologer/features/call/presentation/controllers/call_controller.dart';
import 'package:astro_astrologer/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_astrologer/features/call/presentation/widgets/floating_call_bubble.dart';
import 'package:astro_astrologer/features/home/presentation/widgets/go_live_bottom_sheet.dart';
import 'package:astro_astrologer/features/chat/presentation/pages/assistance_chat_room_screen.dart';
import 'package:astro_astrologer/core/services/fcm_notification_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController controller = Get.find<DashboardController>();

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.checkCurrentActiveSession();
      if (Get.isRegistered<CallController>()) {
        Get.find<CallController>().checkCurrentActiveCallSession();
      }
      Future.delayed(const Duration(milliseconds: 500), _consumePendingNotification);
    });
  }

  void _consumePendingNotification() async {
    debugPrint('[DashboardScreen] _consumePendingNotification started');
    try {
      // 1. Check local notification launch details (for cold start from killed state)
      try {
        final launchDetails = await FlutterLocalNotificationsPlugin().getNotificationAppLaunchDetails();
        debugPrint('[DashboardScreen] launchDetails: ${launchDetails?.didNotificationLaunchApp}, payload: ${launchDetails?.notificationResponse?.payload}');
        if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
          final payload = launchDetails.notificationResponse?.payload;
          if (payload != null && payload.isNotEmpty) {
            final Map<String, dynamic> data = jsonDecode(payload);
            FCMNotificationService.pendingNotificationData = data;
            debugPrint('[DashboardScreen] Extracted local notification launch payload: $data');
          }
        }
      } catch (e) {
        debugPrint('[DashboardScreen] Error checking local notification launch details: $e');
      }

      final Map<String, dynamic>? data = FCMNotificationService.pendingNotificationData;
      debugPrint('[DashboardScreen] pendingNotificationData: $data');
      if (data == null) return;

      final type = data['type']?.toString();
      final notificationType = data['notification_type']?.toString();
      final bool isChatAssistance = type == 'assistance_chat' || type == 'chat_assistance' || notificationType == 'assistance_chat';

      debugPrint('[DashboardScreen] type: $type, isChatAssistance: $isChatAssistance');

      if (isChatAssistance) {
        FCMNotificationService.pendingNotificationData = null;
        
        final String rawSessionId =
            data['session_id']?.toString() ??
            data['chat_session_id']?.toString() ??
            data['chat_assistance_session_id']?.toString() ??
            data['id']?.toString() ??
            '';
        final int? sId = int.tryParse(rawSessionId);
        debugPrint('[DashboardScreen] rawSessionId: $rawSessionId, parsed: $sId');
        if (sId != null && sId > 0) {
           final userName = data['user_name']?.toString() ?? data['sender_name']?.toString() ?? 'User';
           final userImage = data['user_avatar']?.toString() ?? data['sender_image']?.toString() ?? '';
           debugPrint('[DashboardScreen] Navigating to AssistanceChatRoomScreen with sessionId: $sId');
           Get.to(() => AssistanceChatRoomScreen(
             sessionId: sId,
             userName: userName,
             userImage: userImage,
           ));
        } else {
           debugPrint('[DashboardScreen] Invalid sessionId, cannot navigate.');
        }
      }
    } catch (e) {
      debugPrint('[DashboardScreen] Error consuming pending notification: $e');
    }
  }

  Future<void> _requestPermissions() async {
    // Request microphone permission on launch
    await Permission.microphone.request();
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const OrdersScreen(),
    Center(child: Text('Go Live Screen'.tr)),
    const NoticeScreen(),
    const ProfileScreen(),
  ];

  List<NavItem> get _navItems => [
    NavItem(icon: Iconsax.home_2_copy, label: 'Home'.tr),
    NavItem(icon: Iconsax.message_question_copy, label: 'Orders'.tr),
    NavItem(icon: Iconsax.video_play_copy, label: 'Go Live'.tr),
    NavItem(icon: Iconsax.notification_bing_copy, label: 'Notice Board'.tr),
    NavItem(icon: Iconsax.user_copy, label: 'My Profile'.tr),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final callController =
            Get.isRegistered<CallController>()
                ? Get.find<CallController>()
                : null;
        final liveController =
            Get.isRegistered<LiveController>()
                ? Get.find<LiveController>()
                : null;

        if ((callController != null && callController.sessionId != null) ||
            (liveController != null &&
                liveController.currentActiveSession.value != null)) {
          try {
            const channel = MethodChannel(
              'com.suryapath.astrologer/app_retain',
            );
            await channel.invokeMethod('sendToBackground');
          } catch (e) {
            debugPrint("Error sending to background: $e");
          }
          return;
        }

        if (controller.selectedIndex.value != 0) {
          // If not on Home tab, go to Home tab
          controller.changeIndex(0);
        } else {
          // If on Home tab, show exit confirmation
          final shouldExit = await _showExitDialog(context);
          if (shouldExit) {
            SystemNavigator.pop();
          }
        }
      },
      child: Obx(
        () => Scaffold(
          extendBody: true,
          body: Column(
            children: [
              Obx(() {
                if (FloatingCallBubble.isActive &&
                    FloatingCallBubble.sessionId != null &&
                    FloatingCallBubble.name != null) {
                  return FloatingCallBubbleWidget(
                    sessionId: FloatingCallBubble.sessionId!,
                    name: FloatingCallBubble.name!,
                    imageUrl: '',
                  );
                } else if (FloatingChatBubble.isActive &&
                    FloatingChatBubble.sessionId != null &&
                    FloatingChatBubble.name != null) {
                  return FloatingChatBubbleWidget(
                    sessionId: FloatingChatBubble.sessionId!,
                    name: FloatingChatBubble.name!,
                    imageUrl: '',
                  );
                }
                return const SizedBox.shrink();
              }),
              Expanded(child: _screens[controller.selectedIndex.value]),
            ],
          ),
          bottomNavigationBar: CustomBottomNavBar(
            selectedIndex: controller.selectedIndex.value,
            onItemSelected: (index) {
              if (index == 2) {
                showGoLiveBottomSheet(context);
              } else {
                controller.changeIndex(index);
              }
            },
            items: _navItems,
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: AppText('Exit App'.tr,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                content: AppText('Are you sure you want to exit?'.tr,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: AppText('Cancel'.tr,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: AppText('Exit'.tr,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
        ) ??
        false;
  }
}
