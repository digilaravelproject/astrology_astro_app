import 'package:flutter/material.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/theme/app_colors.dart';

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

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
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
