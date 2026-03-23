import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/utils/custom_snackbar.dart';

class FormWebViewScreen extends StatelessWidget {
  final String formName;

  const FormWebViewScreen({
    super.key,
    required this.formName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Form Preview',
        actions: [
          IconButton(
            onPressed: () {
              CustomSnackBar.showSuccess('Downloading $formName...', title: 'Started');
            },
            icon: const Icon(Iconsax.document_download_copy, color: Color(0xFF2E1A47), size: 22),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.document_text_copy,
                color: AppColors.primaryColor,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            AppText(
              formName,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2E1A47),
            ),
            const SizedBox(height: 12),
            AppText(
              'Document Viewer Placeholder',
              fontSize: 14,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: AppText(
                'In a real production environment, this screen would render the actual Form 16A PDF or web content using a WebView.',
                textAlign: TextAlign.center,
                fontSize: 13,
                color: Colors.grey.shade400,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
