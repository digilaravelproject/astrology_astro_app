import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../support/presentation/controllers/support_controller.dart';

class HelpSupportScreen extends GetView<SupportController> {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    controller.fetchCustomerSupport();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Customer Support',
      ),
      body: Obx(() {
        if (controller.isCustomerSupportLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.customerSupportData.value;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data != null && data.content.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryColor.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        "Contact Information",
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2E1A47),
                      ),
                      const SizedBox(height: 12),
                      AppText(
                        data.content,
                        fontSize: 14,
                        color: const Color(0xFF2E1A47).withOpacity(0.8),
                        height: 1.6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(height: 1),
                const SizedBox(height: 24),
              ],

              _buildSupportOption(
                icon: Iconsax.sms_copy,
                title: "Email Support",
                subtitle: "Send us an email for support",
                onTap: () => _launchURL("mailto:support@yourcompany.com"),
              ),
              const SizedBox(height: 16),
              _buildSupportOption(
                icon: Iconsax.call_copy,
                title: "Call Us",
                subtitle: "Call us for immediate assistance",
                onTap: () => _launchURL("tel:+919876543210"),
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      CustomSnackBar.showError('Could not launch $url');
    }
  }

  Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2E1A47),
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    subtitle,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}
