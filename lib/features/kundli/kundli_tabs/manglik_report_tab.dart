import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../controllers/planet_positions_controller.dart';

class ManglikReportTab extends StatelessWidget {
  const ManglikReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    final PlanetPositionsController planetController = Get.find<PlanetPositionsController>();

    return Obx(() {
      if (planetController.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          ),
        );
      }

      final planets = planetController.planetPositionsModel.value?.data?.planets;
      final mars = planets?.firstWhereOrNull((p) => p.name?.toLowerCase() == 'mars');

      int marsHouse = mars?.house ?? 1;
      String marsSign = mars?.sign ?? "N/A";
      
      // Manglik houses: 1, 4, 7, 8, 12
      bool isManglik = [1, 4, 7, 8, 12].contains(marsHouse);
      String resultText = isManglik ? "YES" : "NO";
      Color statusColor = isManglik ? const Color(0xFFEA4335) : const Color(0xFF2EBD59);

      String houseOrdinal = _getHouseOrdinal(marsHouse);
      String conclusionText = "Since Mars is placed in the $houseOrdinal house ($marsSign sign), the person is ${isManglik ? 'Manglik' : 'Non-Manglik'}.";

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAnalysisCard(resultText, statusColor),
            const SizedBox(height: 16),
            _buildConclusionCard(conclusionText),
          ],
        ),
      );
    });
  }

  String _getHouseOrdinal(int house) {
    switch (house) {
      case 1: return "first";
      case 2: return "second";
      case 3: return "third";
      case 4: return "fourth";
      case 5: return "fifth";
      case 6: return "sixth";
      case 7: return "seventh";
      case 8: return "eighth";
      case 9: return "ninth";
      case 10: return "tenth";
      case 11: return "eleventh";
      case 12: return "twelfth";
      default: return "$house-th";
    }
  }

  Widget _buildAnalysisCard(String resultText, Color statusColor) {
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
              color: AppColors.primaryColor,
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
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AppText(resultText, fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                AppText("Manglik Status: $resultText", fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConclusionCard(String conclusionText) {
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
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: const Center(
              child: AppText("Conclusion", fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  conclusionText,
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                ),
                const SizedBox(height: 16),
                const AppText(
                  "[This is a computer generated result based on planetary positions. Please consult an Astrologer to confirm & understand this in detail.]",
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

