import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../controllers/manglik_controller.dart';

class ManglikReportTab extends StatelessWidget {
  const ManglikReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ManglikController manglikController = Get.find<ManglikController>();

    return Obx(() {
      if (manglikController.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          ),
        );
      }

      final manglikData = manglikController.manglikModel.value;
      if (manglikData == null) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: AppText("No Manglik data available."),
          ),
        );
      }

      bool isManglik = manglikData.isPresent;
      String resultText = isManglik ? "YES".tr : "NO".tr;
      Color statusColor =
          isManglik ? const Color(0xFFEA4335) : const Color(0xFF2EBD59);

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAnalysisCard(
              resultText: resultText,
              statusText: manglikData.manglikStatus,
              percentage: manglikData.percentageManglikPresent,
              statusColor: statusColor,
            ),
            const SizedBox(height: 16),
            if (manglikData.manglikReport.isNotEmpty)
              _buildConclusionCard(manglikData.manglikReport),
            if (manglikData.basedOnHouse.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildRulesCard(
                "House Placements".tr,
                manglikData.basedOnHouse,
                Icons.home_outlined,
              ),
            ],
            if (manglikData.basedOnAspect.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildRulesCard(
                "Planetary Aspects".tr,
                manglikData.basedOnAspect,
                Icons.remove_red_eye_outlined,
              ),
            ],
            if (manglikData.cancelRules.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildRulesCard(
                "Cancellation Factors".tr,
                manglikData.cancelRules,
                Icons.check_circle_outline,
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildAnalysisCard({
    required String resultText,
    required String statusText,
    required double percentage,
    required Color statusColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Center(
              child: AppText(
                "Manglik Analysis".tr,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AppText(
                      resultText,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppText(
                  "${"Manglik Status:".tr} ${statusText.replaceAll('_', ' ').tr}",
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                const SizedBox(height: 6),
                AppText(
                  "${"Dosha Intensity:".tr} ${percentage.toStringAsFixed(1)}%",
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConclusionCard(String reportText) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Center(
              child: AppText(
                "Conclusion".tr,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  reportText.tr,
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.black87,
                ),
                const SizedBox(height: 12),
                AppText(
                  "[This is a computer generated result based on planetary positions. Please consult an Astrologer to confirm & understand this in detail.]"
                      .tr,
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesCard(String title, List<String> rules, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                AppText(
                  title,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  rules.map((rule) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppText(
                            "• ",
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          Expanded(
                            child: AppText(
                              rule.tr,
                              fontSize: 13,
                              height: 1.3,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
