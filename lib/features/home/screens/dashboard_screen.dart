import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import 'home_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../controllers/dashboard_controller.dart';
import '../../../core/widgets/custom_bottom_nav_bar.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../profile/screens/live_schedule_screen.dart';
import '../../../core/widgets/app_text.dart';
import '../../notification/notice_screen.dart';
import '../../orders/orders_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController controller = Get.find<DashboardController>();

  final List<Widget> _screens = [
    const HomeScreen(),
    const OrdersScreen(),
    const Center(child: Text('Go Live Screen')),
    const NoticeScreen(),
    const ProfileScreen(),
  ];

  final List<NavItem> _navItems = [
    NavItem(icon: Iconsax.home_2_copy, label: 'Home'),
    NavItem(icon: Iconsax.message_question_copy, label: 'Orders'),
    NavItem(icon: Iconsax.video_play_copy, label: 'Go Live'),
    NavItem(icon: Iconsax.notification_bing_copy, label: 'Notice'),
    NavItem(icon: Iconsax.user_copy, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
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
      child: Obx(() => Scaffold(
        extendBody: true,
        body: _screens[controller.selectedIndex.value],
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
      )),
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const AppText(
          'Exit App',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        content: const AppText(
          'Are you sure you want to exit?',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: AppText(
              'Cancel',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const AppText(
              'Exit',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showGoLiveBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
            const AppText(
              'Go Live',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E1A47),
            ),
            const SizedBox(height: 12),
            AppText(
              'Would you like to go live instantly or schedule it for later?',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            // Go Live Instantly Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  // For actual implementation, replace this with direct navigation
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50), // Green for Go Live
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const AppText(
                  'Go Live Instantly',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Schedule for Later Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                onPressed: () {
                  Get.back();
                  Get.to(() => const LiveScheduleScreen());
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF2196F3), width: 1.5), // Blue for Schedule
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const AppText(
                  'Schedule for Later',
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
    );
  }
}
