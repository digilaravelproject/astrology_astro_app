import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/constants/app_strings.dart';
import 'package:astro_astrologer/core/widgets/app_text.dart';
import 'package:astro_astrologer/core/widgets/custom_app_bar.dart';
import 'package:astro_astrologer/features/support/presentation/controllers/support_controller.dart';

class PaymentPolicyScreen extends StatelessWidget {
  const PaymentPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SupportController>();

    // Fetch privacy policy when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPaymentPolicy();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Payment Policy".tr, centerTitle: true),
      body: Obx(() {
        if (controller.isPaymentLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.pink),
          );
        }

        final policyData = controller.paymentPolicyData.value;
        if (policyData == null || policyData.content.isEmpty) {
          return const Center(
            child: AppText("Payment Policy is not available at the moment.".tr,
              fontSize: 16,
              color: Colors.grey,
            ),
          );
        }

        // Simple formatting for HTML paragraphs
        final formattedContent =
            policyData.content
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
