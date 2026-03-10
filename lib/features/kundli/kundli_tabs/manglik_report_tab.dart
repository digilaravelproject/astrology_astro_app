import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';

class ManglikReportTab extends StatelessWidget {
  const ManglikReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAnalysisCard(),
          const SizedBox(height: 16),
          _buildConclusionCard(),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.primaryColor, // color from screenshot
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: const Center(
              child: AppText("Manglik Analysis", fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2EBD59), // Green color for NO
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: AppText("NO", fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                const AppText("Rahul", fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConclusionCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.primaryColor, // color from screenshot
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: const Center(
              child: AppText("Conclusion", fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  "Since mars is in eleventh house and in virgo sign person is Non Manglik.",
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                ),
                SizedBox(height: 16),
                AppText(
                  "[This is a computer generated result. Please consult an Astrologer to confirm & understand this in detail.]",
                  fontSize: 13,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
