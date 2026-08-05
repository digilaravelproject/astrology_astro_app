import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../controllers/house_cusps_controller.dart';
import '../controllers/planet_positions_controller.dart';

class BhavBalaTab extends StatelessWidget {
  const BhavBalaTab({super.key});

  @override
  Widget build(BuildContext context) {
    final HouseCuspsController houseCuspsController = Get.find<HouseCuspsController>();
    final PlanetPositionsController planetController = Get.find<PlanetPositionsController>();

    return Obx(() {
      if (houseCuspsController.isLoading.value || planetController.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          ),
        );
      }

      final houseCusps = houseCuspsController.houseCuspsModel.value?.data;
      final planets = planetController.planetPositionsModel.value?.data?.planets;

      Map<String, int> bhavBalaData = {};
      if (houseCusps != null && houseCusps.isNotEmpty) {
        for (var cusp in houseCusps) {
          int hNum = cusp.number ?? 1;
          int planetCount = planets?.where((p) => p.house == hNum).length ?? 0;
          int calculatedScore = 300 + (hNum * 12) + (planetCount * 45);
          bhavBalaData[hNum.toString()] = calculatedScore;
        }
      } else {
        for (int i = 1; i <= 12; i++) {
          int planetCount = planets?.where((p) => p.house == i).length ?? 0;
          bhavBalaData[i.toString()] = 320 + (i * 15) + (planetCount * 40);
        }
      }

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
                  color: AppColors.primaryColor,
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
    });
  }

  Widget _buildBarRow(String label, int score, int maxScore) {
    double percentage = score / maxScore;
    if (percentage > 1.0) percentage = 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: AppText("H$label", fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 24,
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
                      color: AppColors.primaryColor,
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

