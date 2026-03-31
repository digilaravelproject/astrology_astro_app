import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../support/presentation/controllers/support_controller.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SupportController>();
    
    // Fetch terms and conditions when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTermsAndConditions();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Terms and Conditions",
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isTermsLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.pink));
        }

        final termsData = controller.termsAndConditionsData.value;
        if (termsData == null || termsData.content.isEmpty) {
          return const Center(
            child: AppText(
              "Terms and Conditions are not available at the moment.",
              fontSize: 16,
              color: Colors.grey,
            ),
          );
        }

        // Simple formatting for HTML paragraphs
        final formattedContent = termsData.content
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
