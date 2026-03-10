import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import 'form_webview_screen.dart';

class DownloadFormScreen extends StatelessWidget {
  const DownloadFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data based on the screenshot provided
    final List<String> forms = [
      'BWHP M0748M_Q2_2026-27',
      'BWHP M0748M_Q1_2026-27',
      'BWHP M0748M_Q4_2025-26',
      'BWHP M0748M_Q3_2025-26',
      'BWHP M0748M_Q2_2025-26',
      'BWHP M0748M_Q1_2025-26',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const CustomAppBar(
        title: 'Download Form 16A',
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: forms.length,
        itemBuilder: (context, index) {
          return _buildFormItem(forms[index]);
        },
      ),
    );
  }

  Widget _buildFormItem(String formName) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        title: AppText(
          formName,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF4A4A4A),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: () => Get.to(() => FormWebViewScreen(formName: formName)),
      ),
    );
  }
}
