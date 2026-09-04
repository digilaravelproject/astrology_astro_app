import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    });
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
                _showGoLiveBottomSheet(context);
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

  void _showGoLiveBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => SafeArea(
            top: false,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 25),
                  AppText('Go Live'.tr,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E1A47),
                  ),
                  const SizedBox(height: 12),
                  AppText('Would you like to go live instantly or schedule it for later?'.tr,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  Obx(() {
                    final liveController = Get.find<LiveController>();
                    final isCreating = liveController.isCreating.value;

                    return SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed:
                            isCreating
                                ? null
                                : () {
                                  liveController.createSession(
                                    title: "Instant Live Session".tr,
                                    description: "Broadcasting Live",
                                    sessionType: "public",
                                    duration: 60,
                                    maxParticipants: 100,
                                    isInstant: true,
                                  );
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF4CAF50,
                          ), // Green for Go Live
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child:
                            isCreating
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : AppText('Go Live Instantly'.tr,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  // Schedule for Later Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        Get.toNamed(AppRoutes.liveSchedule);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF2196F3),
                          width: 1.5,
                        ), // Blue for Schedule
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: AppText('Schedule for Later'.tr,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
    );
  }
}
