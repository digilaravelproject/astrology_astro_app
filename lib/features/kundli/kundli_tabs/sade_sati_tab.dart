import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../controllers/sade_sati_controller.dart';
import '../models/sade_sati_model.dart';

class SadeSatiTab extends StatelessWidget {
  const SadeSatiTab({super.key});

  @override
  Widget build(BuildContext context) {
    final SadeSatiController controller = Get.find<SadeSatiController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.error.value.isNotEmpty) {
        return Center(
          child: AppText("Error: ${controller.error.value}", color: Colors.red),
        );
      }

      final data = controller.sadeSatiModel.value?.data;
      if (data == null) {
        return const Center(child: AppText("No Sade Sati data available"));
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSadesatiStatusCard(data),
            const SizedBox(height: 16),
            if (data.guidance != null) _buildGuidanceSection(data.guidance!),
            const SizedBox(height: 16),
            if (data.effects != null && data.effects!.isNotEmpty) _buildEffectsSection(data.effects!),
          ],
        ),
      );
    });
  }

  Widget _buildSadesatiStatusCard(SadeSatiData data) {
    final bool isUndergoing = data.isInSadeSati ?? false;
    final String phaseName = data.phaseName ?? "No Phase";
    final String summary = data.guidance?.summary ?? data.description ?? "";
    final String title = isUndergoing ? "Currently in Sade Sati" : "Sade Sati";

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
            child: Center(
              child: AppText(title, fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isUndergoing ? const Color(0xFFEA4335) : const Color(0xFF34A853), // Red if Yes, Green if No
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AppText(isUndergoing ? "Yes" : "No", fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(phaseName, fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      const SizedBox(height: 4),
                      AppText(
                        summary,
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidanceSection(SadeSatiGuidance guidance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (guidance.mantra != null && guidance.mantra!.isNotEmpty)
          _buildInfoCard("Mantra", guidance.mantra!, Icons.self_improvement, Colors.orange),
        const SizedBox(height: 16),
        if (guidance.doList != null && guidance.doList!.isNotEmpty)
          _buildListCard("Do's", guidance.doList!, Icons.check_circle, Colors.green),
        const SizedBox(height: 16),
        if (guidance.avoid != null && guidance.avoid!.isNotEmpty)
          _buildListCard("Avoid", guidance.avoid!, Icons.cancel, Colors.red),
      ],
    );
  }

  Widget _buildEffectsSection(List<String> effects) {
    return _buildListCard("Effects & Predictions", effects, Icons.insights, Colors.blue);
  }

  Widget _buildInfoCard(String title, String content, IconData icon, Color iconColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              AppText(title, fontSize: 16, fontWeight: FontWeight.bold),
            ],
          ),
          const SizedBox(height: 12),
          AppText(content, fontSize: 14, height: 1.4, color: Colors.black87),
        ],
      ),
    );
  }

  Widget _buildListCard(String title, List<String> items, IconData icon, Color iconColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              AppText(title, fontSize: 16, fontWeight: FontWeight.bold),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Icon(Icons.circle, size: 6, color: Colors.black54),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: AppText(item, fontSize: 14, height: 1.4, color: Colors.black87)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
