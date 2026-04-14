import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../profile/screens/my_earnings_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../profile/screens/profile_screen.dart';
import '../widgets/home_greeting.dart';
import '../controllers/dashboard_controller.dart';
import '../../call/call_history_screen.dart';
import '../../chat/chat_history_screen.dart';
import '../../kundli/kundli_list_screen.dart';
import '../../astromall/astromall_orders_screen.dart';
import '../../waitlist/waitlist_screen.dart';
import '../../chat/assistant_chat_screen.dart';
import '../../orders/orders_screen.dart';
import '../../profile/screens/live_schedule_screen.dart';
import '../../profile/screens/settings_screen.dart';
import '../../profile/screens/my_reviews_screen.dart';
import '../../orders/history_screen.dart';
import '../../followers/my_followers_screen.dart';
import '../../remedies/suggested_remedies_screen.dart';
import '../../offers/offers_screen.dart';
import '../../panchang/panchang_screen.dart';
import '../../notification/notification_screen.dart';
import '../../blog/blog_screen.dart';
import '../../training/training_videos_section.dart';
import '../../offers/special_offer_banner.dart';
import '../widgets/start_paid_session_section.dart'; // Added Paid Session Section
import '../../schedule/set_sleep_hours_screen.dart';
import '../../schedule/presentation/controllers/schedule_controller.dart';
import '../../notification/controllers/notification_controller.dart';
import '../../profile/screens/invoice_screen.dart';
import '../../profile/screens/performance_screen.dart';
import '../../profile/screens/settings_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            elevation: 0,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: _buildStickyTopBar(authController),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildGreeting(authController),
                const SizedBox(height: 12),
                _buildServiceCard(),
                const SizedBox(height: 12),
                const SpecialOfferBanner(),
                const SizedBox(height: 12),
                const StartPaidSessionSection(),
                const SizedBox(height: 12),
                _buildEarningsCard(),
                const SizedBox(height: 12),
                _buildTodayProgressCard(),
                const SizedBox(height: 8),
                _buildMenuGrid(),
                const SizedBox(height: 20),
                _buildSleepTimeCard(),
                const SizedBox(height: 20),
                // _buildDNDBanner(),
                // const SizedBox(height: 16),
                const TrainingVideosSection(),
                const SizedBox(height: 80), // Space for bottom bar
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          mini: true,
          onPressed: () {},
          backgroundColor: AppColors.primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStickyTopBar(AuthController authController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              debugPrint('Profile icon tapped - shifting to index 4');
              Get.find<DashboardController>().changeIndex(4);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: Center(
                    child: Text(
                      authController.currentUser.value?.name.isNotEmpty == true
                          ? authController.currentUser.value!.name[0].toUpperCase()
                          : 'A',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              _buildCoinWalletChip(),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Get.to(() => const NotificationScreen()),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications_outlined, size: 22, color: Color(0xFF2E1A47)),
                      Obx(() {
                        final unreadCount = Get.find<NotificationController>().unreadCount.value;
                        if (unreadCount > 0) {
                          return Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                unreadCount > 9 ? '9+' : '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Get.to(() => const SettingsScreen()),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Icon(Iconsax.setting_2_copy, size: 22, color: Color(0xFF2E1A47)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoinWalletChip() {
    return GestureDetector(
      onTap: () => Get.to(() => const MyEarningsScreen()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFB300), Color(0xFFFFA000)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 10),
            ),
            const SizedBox(width: 6),
            AppText(
              "100",
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2E1A47),
              letterSpacing: 0.5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }

  Widget _buildServiceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightPink, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Obx(() {
        final astro = authController.currentUser.value?.astrologer;
        if (astro == null) return const SizedBox.shrink();

        return Column(
          children: [
            _buildServiceRow(
              'Chat', 
              '₹${astro.chatRate}/min', 
              'Last active: 09 Feb, 06:35 PM', 
              astro.isChatEnabled, 
              (v) => authController.toggleOnline(v, 'chat'),
            ),
            _divider(),
            _buildServiceRow(
              'Call', 
              '₹${astro.callRate}/min', 
              'Last active: 09 Feb, 06:35 PM', 
              astro.isCallEnabled, 
              (v) => authController.toggleOnline(v, 'call'),
            ),
            _divider(),
            _buildServiceRow(
              'Video Call', 
              '₹${astro.videoCallRate}/min', 
              astro.isVideoCallEnabled ? 'Online' : 'Offline', 
              astro.isVideoCallEnabled, 
              (v) => authController.toggleOnline(v, 'video_call'),
            ),
          ],
        );
      }),
    );
  }

  Widget _divider() => Divider(height: 32, color: Colors.grey.withOpacity(0.1));

  Widget _buildServiceRow(String title, String price, String status, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(title, fontSize: 16, fontWeight: FontWeight.w600),
              const SizedBox(height: 2),
              AppText(price, fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ],
          ),
        ),
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.primaryColor,
          ),
        ),
        const SizedBox(width: 8),
        AppText(status, fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
      ],
    );
  }

  // Widget _buildDNDBanner() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: isDNDEnabled
  //             ? [const Color(0xFF2E1A47), const Color(0xFF4A2060)]
  //             : [AppColors.primaryColor.withOpacity(0.12), AppColors.primaryColor.withOpacity(0.05)],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       ),
  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: [
  //         BoxShadow(
  //           color: isDNDEnabled
  //               ? const Color(0xFF2E1A47).withOpacity(0.25)
  //               : AppColors.primaryColor.withOpacity(0.08),
  //           blurRadius: 16,
  //           offset: const Offset(0, 6),
  //         ),
  //       ],
  //     ),
  //     padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
  //     child: Row(
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(12),
  //           decoration: BoxDecoration(
  //             color: isDNDEnabled
  //                 ? Colors.white.withOpacity(0.12)
  //                 : AppColors.primaryColor.withOpacity(0.1),
  //             shape: BoxShape.circle,
  //           ),
  //           child: Icon(
  //             isDNDEnabled ? Icons.do_not_disturb_on_rounded : Icons.do_not_disturb_off_rounded,
  //             color: isDNDEnabled ? Colors.white : AppColors.primaryColor,
  //             size: 26,
  //           ),
  //         ),
  //         const SizedBox(width: 14),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               AppText(
  //                 'Quick DND',
  //                 fontSize: 14,
  //                 fontWeight: FontWeight.w800,
  //                 color: isDNDEnabled ? Colors.white : const Color(0xFF2E1A47),
  //               ),
  //               const SizedBox(height: 2),
  //               AppText(
  //                 isDNDEnabled
  //                     ? 'Emergency sessions paused for 1 hour'
  //                     : 'Pause emergency sessions for 1 hour',
  //                 fontSize: 12,
  //                 fontWeight: FontWeight.w500,
  //                 color: isDNDEnabled ? Colors.white60 : Colors.grey.shade600,
  //               ),
  //             ],
  //           ),
  //         ),
  //         Transform.scale(
  //           scale: 0.9,
  //           child: Switch(
  //             value: isDNDEnabled,
  //             onChanged: (v) => setState(() => isDNDEnabled = v),
  //             activeColor: Colors.white,
  //             activeTrackColor: AppColors.primaryColor,
  //             inactiveThumbColor: AppColors.primaryColor,
  //             inactiveTrackColor: AppColors.primaryColor.withOpacity(0.2),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSleepTimeCard() {
    final scheduleController = Get.find<ScheduleController>();
    
    return GestureDetector(
      onTap: () {
        Get.to(() => const SetSleepHoursScreen());
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB), // Very light grey/white background for icon
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.nights_stay_outlined,
                color: AppColors.primaryColor.withOpacity(0.7),
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'My sleep Time',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2C2C2C),
                  ),
                  const SizedBox(height: 4),
                  Obx(() {
                    final sleepHours = scheduleController.sleepHours.value;
                    if (sleepHours != null) {
                      return AppText(
                        'Sleep Time: ${_formatDisplayTime(sleepHours.sleepStartTime)} - ${_formatDisplayTime(sleepHours.sleepEndTime)}',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      );
                    } else {
                      return AppText(
                        'Sleep Time: Not set',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      );
                    }
                  }),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey.shade400,
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  String _formatDisplayTime(String time24) {
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayMinute = minute.toString().padLeft(2, '0');
      
      return '${displayHour.toString().padLeft(2, '0')}:$displayMinute $period';
    } catch (e) {
      return time24; // Return original if parsing fails
    }
  }

  }

  Widget _buildToggleTile({required IconData icon, required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged, bool showInfo = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.black87, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppText(title, fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
                    if (showInfo) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.info, size: 18, color: Color(0xFF2196F3)),
                    ]
                  ],
                ),
                const SizedBox(height: 2),
                AppText(subtitle, fontSize: 12, color: Colors.grey.shade600),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: Colors.black87, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(title, fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
                  const SizedBox(height: 2),
                  AppText(subtitle, fontSize: 12, color: Colors.grey.shade600),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText('JANUARY Earning - ₹45403.76', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText('Invoice Acknowledged', fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                    const SizedBox(height: 8),
                    AppText('You can check your invoice in settings.', fontSize: 10, color: Colors.grey.shade500),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.to(() => const InvoiceScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: AppText('Details', color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(AuthController authController) {
    return Obx(() => HomeGreeting(
      name: authController.currentUser.value?.name,
    ));
  }


  Widget _buildTodayProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  "Today's Progress",
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.black.withOpacity(0.8),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(text: 'Only '),
                      TextSpan(
                        text: '8 hours',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
                      ),
                      const TextSpan(text: ' left to complete your 8 hours online target.'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => const PerformanceScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: AppText(
                    'Performance',
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 85,
                height: 85,
                child: CircularProgressIndicator(
                  value: 0.1,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEEEEEE)),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    '0m',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryColor,
                  ),
                  AppText(
                    "Let's Start",
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    final List<_MenuData> menuItems = [
      // Live & Communication (most important – top)
      _MenuData(
        title: 'Go Live',
        icon: Iconsax.video_play_copy,
        bgColor: AppColors.primaryColor.withOpacity(0.08),
        iconBgColor: AppColors.primaryColor.withOpacity(0.18),
        textColor: AppColors.primaryColor,
        onTap: () => _showGoLiveBottomSheet(Get.context!),
      ),
      _MenuData(
        title: 'Chat',
        icon: Iconsax.messages_2_copy,
        bgColor: const Color(0xFFEAF8F1),
        iconBgColor: const Color(0xFFD0F0E0),
        textColor: const Color(0xFF0D9D57),
        onTap: () => Get.to(() => ChatHistoryScreen()),
      ),
      _MenuData(
        title: 'Call',
        icon: Iconsax.call_copy,
        bgColor: const Color(0xFFFFF4E5),
        iconBgColor: const Color(0xFFFFE4B5),
        textColor: const Color(0xFFF5A623),
        onTap: () => Get.to(() => const CallHistoryScreen()),
      ),
      // Consultation tools
      _MenuData(
        title: 'Waitlist',
        icon: Iconsax.timer_1_copy,
        bgColor: const Color(0xFFF0F4FF),
        iconBgColor: const Color(0xFFDBE4FF),
        textColor: const Color(0xFF3B5BDB),
        onTap: () => Get.to(() => const WaitlistScreen()),
      ),
      _MenuData(
        title: 'Assistant Chat',
        icon: Iconsax.cpu_setting_copy,
        bgColor: const Color(0xFFF3EEFF),
        iconBgColor: const Color(0xFFE5D7FF),
        textColor: const Color(0xFF7C3AED),
        onTap: () => Get.to(() => const AssistantChatScreen()),
      ),
      _MenuData(
        title: 'Suggested Remedies',
        icon: Iconsax.clipboard_text_copy,
        bgColor: AppColors.primaryColor.withOpacity(0.08),
        iconBgColor: AppColors.primaryColor.withOpacity(0.15),
        textColor: AppColors.primaryColor,
        onTap: () => Get.to(() => const SuggestedRemediesScreen()),
      ),
      // Reviews & Community
      _MenuData(
        title: 'My Reviews',
        icon: Iconsax.star_copy,
        bgColor: const Color(0xFFFFF8E1),
        iconBgColor: const Color(0xFFFFECB3),
        textColor: const Color(0xFFF9A825),
        onTap: () => Get.to(() => const MyReviewsScreen()),
      ),
      _MenuData(
        title: 'My Community',
        icon: Iconsax.people_copy,
        bgColor: const Color(0xFFE8F5FE),
        iconBgColor: const Color(0xFFBBDEFB),
        textColor: const Color(0xFF1E88E5),
        onTap: () => Get.to(() => const MyFollowersScreen()),
      ),
      _MenuData(
        title: 'History',
        icon: Iconsax.clock_copy,
        bgColor: const Color(0xFFF0F7FF),
        iconBgColor: const Color(0xFFD0E8FF),
        textColor: const Color(0xFF0288D1),
        onTap: () => Get.to(() => const HistoryScreen()),
      ),
      // Astrology content
      _MenuData(
        title: 'Panchang',
        icon: Iconsax.sun_1_copy,
        bgColor: const Color(0xFFFFF3E0),
        iconBgColor: const Color(0xFFFFE0B2),
        textColor: const Color(0xFFE65100),
        onTap: () => Get.to(() => const PanchangScreen()),
      ),
      _MenuData(
        title: 'Astrology Blog',
        icon: Iconsax.book_1_copy,
        bgColor: const Color(0xFFE8F5E9),
        iconBgColor: const Color(0xFFC8E6C9),
        textColor: const Color(0xFF2E7D32),
        onTap: () => Get.to(() => const BlogScreen()),
      ),
      // Commerce
      _MenuData(
        title: 'Astromall',
        icon: Iconsax.shop_copy,
        bgColor: const Color(0xFFF9F0FF),
        iconBgColor: const Color(0xFFEDD9FF),
        textColor: const Color(0xFF8B2FC9),
        onTap: () => Get.to(() => const AstromallOrdersScreen()),
      ),
      _MenuData(
        title: 'Offers',
        icon: Iconsax.tag_copy,
        bgColor: const Color(0xFFE3F2FD),
        iconBgColor: const Color(0xFFBBDEFB),
        textColor: const Color(0xFF1565C0),
        onTap: () => Get.to(() => const OffersScreen()),
      ),
      // Admin & settings
      _MenuData(
        title: 'Settings',
        icon: Iconsax.setting_2_copy,
        bgColor: const Color(0xFFF5F5F5),
        iconBgColor: const Color(0xFFEEEEEE),
        textColor: const Color(0xFF616161),
        onTap: () => Get.to(() => const SettingsScreen()),
      ),
    ];

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        return _buildMenuItem(menuItems[index]);
      },
    );
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

  Widget _buildMenuItem(_MenuData item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: item.textColor.withOpacity(0.08), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: item.textColor.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: item.textColor.withOpacity(0.12), width: 1),
              ),
              child: Icon(
                item.icon,
                color: item.textColor,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: AppText(
                item.title,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2E1A47),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }



class _MenuData {
  final String title;
  final IconData icon;
  final Color bgColor;
  final Color iconBgColor;
  final Color textColor;
  final VoidCallback? onTap;

  _MenuData({
    required this.title,
    required this.icon,
    required this.bgColor,
    required this.iconBgColor,
    required this.textColor,
    this.onTap,
  });
}
