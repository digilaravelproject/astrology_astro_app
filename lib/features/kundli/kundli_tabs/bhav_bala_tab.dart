import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';

class BhavBalaTab extends StatelessWidget {
  const BhavBalaTab({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, int> bhavBalaData = {
      "1": 367,
      "2": 441,
      "3": 516,
      "4": 365,
      "5": 373,
      "6": 501,
      "7": 416,
      "8": 394,
      "9": 503,
      "10": 487,
      "11": 449,
      "12": 532,
    };

    int maxScore = 600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
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
                child: AppText("Bhav Bala", fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: bhavBalaData.entries.map((entry) {
                  return _buildBarRow(entry.key, entry.value, maxScore);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarRow(String label, int score, int maxScore) {
    double percentage = score / maxScore;
    if (percentage > 1.0) percentage = 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 30, // Slightly smaller width compared to string labels
            child: AppText(label, fontSize: 13, color: Colors.black87),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 24, // Slightly thinner than ShadBala
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor, // bar fill
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: AppText(score.toString(), fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
