import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../support/presentation/controllers/support_controller.dart';

/*
class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Frequently Asked Questions',
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: 8,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return const _FaqItem(
            question: "How do I process my payouts?",
            answer: "Payouts are processed automatically every week once you reach the minimum threshold of ₹500.",
          );
        },
      ),
    );
  }
}
*/

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: AppText(
            question,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2E1A47),
          ),
          iconColor: AppColors.primaryColor,
          collapsedIconColor: Colors.grey.shade400,
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          children: [
            AppText(
              answer,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ],
        ),
      ),
    );
  }
}





class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SupportController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Frequently Asked Questions",
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.pink));
        }

        final faqData = controller.faqData.value;
        if (faqData == null || faqData.items.isEmpty) {
          return const Center(
            child: AppText(
              "No FAQs available at the moment.",
              fontSize: 16,
              color: Colors.grey,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: faqData.items.length,
          itemBuilder: (context, index) {
            final item = faqData.items[index];
            return _FaqItem(
              question: item.question,
              answer: item.answer,
            );
          },
        );
      }),
    );
  }
}

/*class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: AppText(
          question,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          AppText(
            answer,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ],
      ),
    );
  }
}*/
