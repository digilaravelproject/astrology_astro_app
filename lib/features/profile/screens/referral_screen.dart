import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_app_bar.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Refer & Earn',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Icon(Iconsax.gift_copy, size: 100, color: AppColors.primaryColor.withOpacity(0.5)),
              ),
            ),
            const SizedBox(height: 32),
            const AppText(
              "Refer a Friend & Earn ₹100",
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2E1A47),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            AppText(
              "Share your referral code with your friends and get ₹100 in your wallet when they sign up and complete their first session.",
              fontSize: 14,
              color: Colors.grey.shade600,
              textAlign: TextAlign.center,
              height: 1.5,
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        "Your Referral Code",
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(height: 6),
                      const AppText(
                        "ASTRO2024",
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryColor,
                        letterSpacing: 2,
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: "ASTRO2024"));
                      Get.snackbar(
                        "Copied", 
                        "Referral code copied to clipboard", 
                        snackPosition: SnackPosition.BOTTOM, 
                        margin: const EdgeInsets.all(20),
                        backgroundColor: const Color(0xFF2E1A47), 
                        colorText: Colors.white,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                        ],
                      ),
                      child: const Icon(Icons.copy_rounded, color: AppColors.primaryColor, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            CustomButton(
              text: "Share Now",
              onPressed: () {
                // Share logic could be implemented here using share_plus
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
