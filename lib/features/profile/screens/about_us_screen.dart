import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/app_text.dart';
import '../../support/presentation/controllers/support_controller.dart';

class AboutUsScreen extends GetView<SupportController> {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    controller.fetchAboutUs();
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'About us',
      ),
      body: Obx(() {
        if (controller.isAboutUsLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.aboutUsData.value;
        if (data == null) {
          return const Center(child: AppText("No data available"));
        }

        // Simple formatting for HTML content to avoid external dependencies
        final formattedContent = data.content
            .replaceAll(RegExp(r'</p>'), '\n\n')
            .replaceAll(RegExp(r'<br\s*/?>'), '\n')
            .replaceAll(RegExp(r'<[^>]*>'), '')
            .replaceAll(RegExp(r'&nbsp;'), ' ')
            .trim();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: AppText(
            formattedContent,
            fontSize: 16,
            color: const Color(0xFF2E1A47),
            height: 1.5,
          ),
        );
      }),
    );
  }
}
