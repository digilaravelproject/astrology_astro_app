import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../support/presentation/controllers/support_controller.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final SupportController controller = Get.find<SupportController>();
  int _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Feedback',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const AppText(
              "How was your experience?",
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2E1A47),
            ),
            const SizedBox(height: 8),
            AppText(
              "Your feedback helps us improve our platform for everyone.",
              fontSize: 14,
              color: Colors.grey.shade500,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final isSelected = index < _rating;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      isSelected ? Iconsax.star_1_copy : Iconsax.star_1,
                      color: isSelected ? Colors.amber : Colors.grey.shade200,
                      size: 48,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 48),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: TextField(
                controller: _feedbackController,
                maxLines: 6,
                style: const TextStyle(fontSize: 14, color: Color(0xFF2E1A47)),
                decoration: InputDecoration(
                  hintText: "Tell us what you liked or how we can improve...",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ),
            const SizedBox(height: 48),
            Obx(() => CustomButton(
              text: "Submit Feedback",
              isLoading: controller.isFeedbackSubmitting.value,
              onPressed: () async {
                if (_rating == 0) {
                  CustomSnackBar.showError("Please select a star rating", title: "Rating Required");
                  return;
                }
                
                final success = await controller.submitFeedback(_rating, _feedbackController.text);
                
                if (success) {
                  Get.back();
                  CustomSnackBar.showSuccess("Your feedback has been submitted successfully!");
                } else {
                  CustomSnackBar.showError("Failed to submit feedback. Please try again.");
                }
              },
            )),
          ],
        ),
      ),
    );
  }
}
