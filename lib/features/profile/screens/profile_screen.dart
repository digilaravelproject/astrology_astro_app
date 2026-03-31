import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_urls.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../routes/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';
import 'edit_profile_screen.dart';
import 'profile_video_screen.dart';
import 'skill_details_screen.dart';
import 'other_details_screen.dart';
import 'price_setting_screen.dart';
import 'availability_screen.dart';
import 'live_schedule_screen.dart';
import 'my_reviews_screen.dart';
import 'performance_screen.dart';
import 'my_earnings_screen.dart';
import 'change_language_screen.dart';
import 'referral_screen.dart';
import 'help_support_screen.dart';
import 'faq_screen.dart';
import 'feedback_screen.dart';
import 'settings_screen.dart';
import 'update_phone_screen.dart';
import '../../../core/widgets/simple_content_screen.dart';
import '../../home/screens/audio_intro_screen.dart';
import '../../followers/my_followers_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 140), // Space for bottom nav
        child: Column(
          children: [
            _buildProfileHeader(authController),
            const SizedBox(height: 20),
            _buildMenuItems(context, authController),
            const SizedBox(height: 30),
            _buildActionButtons(authController),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AuthController authController) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x66FF6F00), // primaryColor at 40% opacity
            Color(0x26FF6F00), // primaryColor at 15% opacity
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          
          // Profile Image
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Obx(() {
                  final user = authController.currentUser.value;
                  final profilePhoto = user?.astrologer?.profilePhoto;

                  ImageProvider imageProvider;

                  if (profilePhoto != null && profilePhoto.isNotEmpty) {
                    imageProvider = NetworkImage('${AppUrls.baseImageUrl}$profilePhoto');
                  } else {
                    imageProvider = const NetworkImage('https://i.pravatar.cc/300?u=a042581f4e29026704d');
                  }

                  return Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  );
                }
                ),
              ),
              GestureDetector(
                onTap: () => Get.to(() => const EditProfileScreen()),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Name and Phone
          Obx(() => AppText(
            authController.currentUser.value?.name ?? 'Astrologer Name',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2E1A47),
          )),
          const SizedBox(height: 4),
          AppText(
            authController.currentUser.value?.phone ?? "+91 9876543210",
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, AuthController authController) {
    return Column(
      children: [
        _buildSectionHeader('PROFESSIONAL PROFILE'),
        _buildMenuItem(
          icon: Iconsax.video_play_copy,
          title: 'Profile Video',
          onTap: () => Get.to(() => const ProfileVideoScreen()),
        ),
        _buildMenuItem(
          icon: Iconsax.microphone_2_copy,
          title: 'Audio Introduction',
          onTap: () => Get.to(() => const AudioIntroScreen()),
        ),
        _buildMenuItem(
          icon: Iconsax.teacher_copy,
          title: 'Skill Details',
         // onTap: () => Get.to(() => const SkillDetailsScreen()),
          onTap: () => Get.toNamed(AppRoutes.skillDetailScreen),
        ),
        _buildMenuItem(
          icon: Iconsax.note_2_copy,
          title: 'Other Details',
          onTap: () => Get.to(() => const OtherDetailsScreen()),
        ),
        _buildMenuItem(
          icon: Iconsax.people_copy,
          title: 'My Community',
          onTap: () => Get.to(() => const MyFollowersScreen()),
        ),
        const SizedBox(height: 10),
        _buildSectionHeader('PERFORMANCE & EARNINGS'),
        _buildMenuItem(
          icon: Iconsax.money_2_copy,
          title: 'My Earnings',
          onTap: () => Get.to(() => const MyEarningsScreen()),
        ),
        _buildMenuItem(
          icon: Iconsax.star_copy,
          title: 'My Reviews',
          onTap: () => Get.to(() => const MyReviewsScreen()),
        ),
        _buildMenuItem(
          icon: Iconsax.chart_copy,
          title: 'Performance',
          onTap: () => Get.to(() => const PerformanceScreen()),
        ),
        
        const SizedBox(height: 10),
        _buildSectionHeader('ACCOUNT MANAGEMENT'),
        _buildMenuItem(
          icon: Iconsax.user_copy,
          title: 'My Account',
          onTap: () => Get.to(() => const EditProfileScreen()),
        ),
        _buildMenuItem(
          icon: Iconsax.setting_2_copy,
          title: 'Settings',
          onTap: () => Get.to(() => const SettingsScreen()),
        ),
        _buildMenuItem(
          icon: Icons.translate_rounded,
          title: 'Change Language',
          onTap: () => Get.to(() => const ChangeLanguageScreen()),
        ),
        
        const SizedBox(height: 10),
        _buildSectionHeader('APP INFO'),
        _buildMenuItem(
          icon: Iconsax.message_copy,
          title: 'Feedback',
          onTap: () => Get.to(() => const FeedbackScreen()),
        ),
        _buildMenuItem(
          icon: Iconsax.info_circle_copy,
          title: 'About us',
          onTap: () => Get.to(() => const SimpleContentScreen(
                title: 'About us',
                content:
                    'We are a leading astrology platform connecting world-class experts with users globally...',
              )),
        ),
        _buildMenuItem(
          icon: Iconsax.like_1_copy,
          title: 'Rate Us',
          onTap: () => _openStoreRating(),
        ),
        _buildMenuItem(
          icon: Iconsax.share_copy,
          title: 'Share App',
          onTap: () => _shareApp(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AppText(
          title,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[500],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primaryColor, size: 20),
      ),
      title: AppText(
        title,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF2E1A47),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black26),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      minVerticalPadding: 15,
    );
  }

  Widget _buildActionButtons(AuthController authController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Logout Button
          OutlinedButton(
            onPressed: () {
              Get.dialog(
                Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.logout_rounded, color: Colors.red, size: 32),
                        ),
                        const SizedBox(height: 20),
                        const AppText(
                          'Logout',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E1A47),
                        ),
                        const SizedBox(height: 12),
                        AppText(
                          'Are you sure you want to logout from your account?',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Get.back(),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: BorderSide(color: Colors.grey[300]!),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: AppText('Cancel', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[600]!),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                  authController.logout();
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  backgroundColor: Colors.red,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const AppText('Logout', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.red.withOpacity(0.05),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                AppText(
                  'Log Out',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 15),

          // Delete Account Button
          /*TextButton(
            onPressed: () {
              Get.defaultDialog(
                title: 'Delete Account',
                middleText: 'Are you sure you want to delete your account? This action cannot be undone.',
                textConfirm: 'Delete',
                textCancel: 'Cancel',
                confirmTextColor: Colors.white,
                buttonColor: Colors.red,
                cancelTextColor: Colors.black,
                onConfirm: () {
                   Get.back();
                   authController.logout();
                }
              );
            },
            child: const AppText(
              'Delete Account',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),*/

          TextButton(
            onPressed: () => authController.deleteAccount(),
            child: const AppText(
              'Delete Account',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Could not launch $url', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _openStoreRating() async {
    final String appId = Platform.isAndroid ? 'com.example.astro_astrologer' : '123456789';
    final String url = Platform.isAndroid 
        ? 'market://details?id=$appId' 
        : 'https://apps.apple.com/app/id$appId?action=write-review';
    
    _launchURL(url);
  }

  Future<void> _shareApp() async {
    final String appId = Platform.isAndroid ? 'com.example.astro_astrologer' : 'id123456789';
    final String url = Platform.isAndroid 
        ? 'https://play.google.com/store/apps/details?id=$appId' 
        : 'https://apps.apple.com/app/$appId';
    
    await Share.share('Check out the Astro Astrologer app! $url');
  }
}
