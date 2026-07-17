import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../controllers/shadbala_controller.dart';
import '../models/shadbala_model.dart';

class ShadBalaTab extends StatelessWidget {
  const ShadBalaTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ShadbalaController controller = Get.find<ShadbalaController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
        );
      }

      final shadbalaList = controller.shadbalaModel.value?.data?.shadbala;
      if (shadbalaList == null || shadbalaList.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: AppText("Failed to load Shad Bala details.")),
        );
      }

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
                  child: AppText("Shad Bala", fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: shadbalaList.map((item) {
                    return _buildBarRow(item);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBarRow(ShadbalaItem item) {
    // Calculate width percentage based on required minimum
    double percentage = item.strengthRatio ?? 0.0;
    if (percentage > 1.0) percentage = 1.0;

    String label = item.planet ?? "N/A";
    String scoreText = "${item.totalStrength?.round() ?? 0} / ${item.requiredMinimum?.round() ?? 0}";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: AppText(label, fontSize: 13, color: Colors.black87),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2), // background for the required minimum
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor, // bar fill
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: AppText(scoreText, fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
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
