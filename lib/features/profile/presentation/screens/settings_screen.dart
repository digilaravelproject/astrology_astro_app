import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/core/widgets/app_text.dart';
import 'package:astro_astrologer/core/widgets/custom_app_bar.dart';
import 'package:astro_astrologer/routes/app_routes.dart';
import 'update_phone_screen.dart';
import 'important_numbers_screen.dart';
import 'package:astro_astrologer/features/training/training_videos_list_screen.dart';
import 'help_support_screen.dart';
import 'faq_screen.dart';
import 'availability_screen.dart';
import 'price_setting_screen.dart';
import 'download_form_screen.dart';
import 'pay_slip_screen.dart';
import 'my_membership_screen.dart';
import 'gallery_screen.dart';
import 'invoice_screen.dart';
import 'package:astro_astrologer/features/profile/presentation/widgets/update_address_bottom_sheet.dart';
import 'package:astro_astrologer/core/widgets/simple_content_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: CustomAppBar(title: 'Settings'.tr),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // ── ACCOUNT ───────────────────────────────────────────────────
          _sectionHeader('ACCOUNT', Iconsax.user_copy),
          _settingsCard([
            _item(
              icon: Iconsax.mobile_copy,
              color: const Color(0xFF1E88E5),
              title: 'Update Phone Number'.tr,
              subtitle: 'Manage your registered and alert numbers'.tr,
              onTap: () => Get.to(() => const UpdatePhoneScreen()),
            ),
            _item(
              icon: Iconsax.bank_copy,
              color: const Color(0xFF0D9D57),
              title: 'Bank Details'.tr,
              subtitle: 'Manage your payout bank accounts'.tr,
              onTap: () => Get.toNamed(AppRoutes.bankAccounts),
              //onTap: () => Get.to(() => const BankDetailsScreen()),
            ),
            // _item(
            //   icon: Iconsax.user_tick_copy,
            //   color: const Color(0xFF7C3AED),
            //   title: 'My Membership'.tr,
            //   subtitle: 'View your membership plan and status'.tr,
            //   onTap: () => Get.to(() => const MyMembershipScreen()),
            // ),
          ]),

          const SizedBox(height: 24),

          // ── CONSULTATION ───────────────────────────────────────────────
          _sectionHeader('CONSULTATION', Iconsax.clock_copy),
          _settingsCard([
            _item(
              icon: Iconsax.clock_copy,
              color: const Color(0xFF7C3AED),
              title: 'Availability'.tr,
              subtitle: 'Set your working hours and off days'.tr,
              onTap: () => Get.to(() => const AvailabilityScreen()),
            ),
            _item(
              icon: Iconsax.calendar_copy,
              color: const Color(0xFF0D9D57),
              title: 'Live Schedule'.tr,
              subtitle: 'Manage your upcoming live sessions'.tr,
              onTap: () => Get.toNamed(AppRoutes.liveSchedule),
              isLast: true,
            ),
          ]),

          const SizedBox(height: 24),

          // ── EARNINGS & FINANCE ────────────────────────────────────────
          _sectionHeader('EARNINGS & FINANCE', Iconsax.wallet_2_copy),
          _settingsCard([
            _item(
              icon: Iconsax.money_send_copy,
              color: const Color(0xFFF5A623),
              title: 'Pay Slip'.tr,
              subtitle: 'Download your monthly pay slips'.tr,
              onTap: () => Get.to(() => const PaySlipScreen()),
            ),
            /*_item(
              icon: Iconsax.document_download_copy,
              color: const Color(0xFF0288D1),
              title: 'Download Form 16A'.tr,
              subtitle: 'Download your tax related forms'.tr,
              onTap: () => Get.to(() => const DownloadFormScreen()),
            ),*/
            _item(
              icon: Iconsax.document_text_copy,
              color: const Color(0xFF546E7A),
              title: 'Invoices'.tr,
              subtitle: 'View and download your invoices'.tr,
              onTap: () => Get.to(() => const InvoiceScreen()),
            ),
            _item(
              icon: Iconsax.map_copy,
              color: const Color(0xFFE65100),
              title: 'Update Billing Address'.tr,
              subtitle: 'Update your address for billing & invoices'.tr,
              onTap: () => showUpdateAddressBottomSheet(context),
            ),
            _item(
              icon: Iconsax.money_change_copy,
              color: AppColors.primaryColor,
              title: 'Price Increase Request'.tr,
              subtitle: 'Request to update your service rates'.tr,
              onTap: () => Get.to(() => const PriceSettingScreen()),
            ),
          ]),

          const SizedBox(height: 24),

          // ── PROFILE & CONTENT ─────────────────────────────────────────
          _sectionHeader('PROFILE & CONTENT', Iconsax.profile_2user_copy),
          _settingsCard([
            _item(
              icon: Iconsax.gallery_copy,
              color: const Color(0xFF8B2FC9),
              title: 'Gallery'.tr,
              subtitle: 'Manage your profile and live event images'.tr,
              onTap: () => Get.to(() => const GalleryScreen()),
            ),
            _item(
              icon: Iconsax.video_play_copy,
              color: AppColors.primaryColor,
              title: 'Training Videos'.tr,
              subtitle: 'Learn how to use the app effectively'.tr,
              // onTap: () => Get.to(() => const TrainingVideosListScreen()),
              onTap: () => Get.toNamed(AppRoutes.trainingVideosScreen),
              isLast: true,
            ),
          ]),

          const SizedBox(height: 24),

          // ── SUPPORT & LEGAL ───────────────────────────────────────────
          _sectionHeader('SUPPORT & LEGAL', Iconsax.shield_tick_copy),
          _settingsCard([
            _item(
              icon: Iconsax.call_calling_copy,
              color: const Color(0xFF1565C0),
              title: 'Important Numbers'.tr,
              subtitle: 'Emergency and support contacts'.tr,
              onTap: () => Get.to(() => const ImportantNumbersScreen()),
            ),
            _item(
              icon: Iconsax.headphone_copy,
              color: const Color(0xFF0D9D57),
              title: 'Customer Support'.tr,
              subtitle: 'Talk to our support team'.tr,
              onTap: () => Get.toNamed(AppRoutes.customerSupport),
            ),
            _item(
              icon: Iconsax.message_question_copy,
              color: const Color(0xFF3B5BDB),
              title: 'FAQ'.tr,
              subtitle: 'Frequently asked questions'.tr,
              onTap: () => Get.toNamed(AppRoutes.faq),
              //Get.to(() => const FaqScreen()),
            ),
            _item(
              icon: Iconsax.shield_tick_copy,
              color: const Color(0xFF546E7A),
              title: 'Privacy Policy'.tr,
              subtitle: 'Your data and privacy rights'.tr,
              onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
              // Get.to(() => const SimpleContentScreen(
              //   title: 'Privacy Policy'.tr,
              //   content: 'Your privacy is important to us. This policy explains how we collect, use, and store your data...',
              // )),
            ),
            _item(
              icon: Iconsax.document_text_copy,
              color: const Color(0xFF616161),
              title: 'Terms and Conditions'.tr,
              subtitle: 'View our terms of service'.tr,
              onTap: () => Get.toNamed(AppRoutes.termsAndConditions),
              // Get.to(() => const SimpleContentScreen(
              //   title: 'Terms and Conditions'.tr,
              //   content: 'By using our platform, you agree to abide by these terms...',
              // )),
            ),
            _item(
              icon: Iconsax.card_copy,
              color: const Color(0xFFE65100),
              title: 'Payment Policy'.tr,
              subtitle: 'Secure transaction and refund info'.tr,
              onTap: () => Get.toNamed(AppRoutes.paymentPolicy),

              // Get.to(() => const SimpleContentScreen(
              //   title: 'Payment Policy'.tr,
              //   content: 'Our payment policy ensures secure and transparent transactions...',
              // )),
              isLast: true,
            ),
          ]),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Section header ─────────────────────────────────────────────────────

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Icon(icon, size: 16, color: AppColors.primaryColor),
          const SizedBox(width: 8),
          AppText(
            title.tr,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2E1A47),
            letterSpacing: 0.2,
          ),
        ],
      ),
    );
  }

  // ── Card wrapper ───────────────────────────────────────────────────────

  Widget _settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  // ── Single menu item ───────────────────────────────────────────────────

  Widget _item({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Colored icon box
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        title.tr,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1C1C1E),
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        subtitle.tr,
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: Colors.grey.shade300,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade100,
            indent: 56,
            endIndent: 16,
          ),
      ],
    );
  }
}
