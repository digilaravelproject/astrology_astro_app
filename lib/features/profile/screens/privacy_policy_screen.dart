import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../support/presentation/controllers/support_controller.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SupportController>();
    
    // Fetch privacy policy when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPrivacyPolicy();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Privacy Policy",
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isPrivacyLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.pink));
        }

        final policyData = controller.privacyPolicyData.value;
        if (policyData == null || policyData.content.isEmpty) {
          return const Center(
            child: AppText(
              "Privacy Policy is not available at the moment.",
              fontSize: 16,
              color: Colors.grey,
            ),
          );
        }

        // Simple formatting for HTML paragraphs
        final formattedContent = policyData.content
            .replaceAll(RegExp(r'</p>'), '\n\n')
            .replaceAll(RegExp(r'<[^>]*>'), '')
            .replaceAll(RegExp(r'&nbsp;'), ' ')
            .trim();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: AppText(
            formattedContent,
            fontSize: 14,
            color: Colors.black87,
            height: 1.6,
            textAlign: TextAlign.justify,
          ),
        );
      }),
    );
  }
}
