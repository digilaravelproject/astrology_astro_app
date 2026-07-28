import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/core/widgets/app_text.dart';
import '../controllers/dasha_controller.dart';
import '../models/dasha_model.dart';

class DashaTab extends StatelessWidget {
  final DashaController controller;

  const DashaTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.breadcrumbs.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Breadcrumbs / Title Header
            _buildHeader(context),
            const SizedBox(height: 12),

            // Dasha List Container
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.primaryColor.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header Row
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(child: AppText("Planet", fontWeight: FontWeight.bold, fontSize: 12)),
                            Expanded(child: AppText("Start Date", fontWeight: FontWeight.bold, fontSize: 12)),
                            Expanded(child: AppText("End Date", fontWeight: FontWeight.bold, fontSize: 12)),
                            SizedBox(width: 24),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),

                      if (controller.currentDashaItems.isEmpty && !controller.isLoading.value)
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(child: AppText("No dasha details available.")),
                        )
                      else
                        ...controller.currentDashaItems.map((item) {
                          return _buildDashaRow(item);
                        }),
                    ],
                  ),
                ),

                if (controller.isLoading.value)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: AppColors.primaryColor),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(BuildContext context) {
    final canGoBack = controller.breadcrumbs.length > 1;
    final breadcrumbPath = controller.breadcrumbs.map((b) => b.title).join(' > ');

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (canGoBack)
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 18, color: AppColors.primaryColor),
                onPressed: () => controller.goBack(),
              ),
            Expanded(
              child: AppText(
                canGoBack ? breadcrumbPath : controller.currentTitle,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (canGoBack) const SizedBox(width: 48), // Balance back button spacing
          ],
        ),
      ],
    );
  }

  Widget _buildDashaRow(DashaItem item) {
    final isClickable = controller.currentLevel != DashaLevel.pranadasha;

    return InkWell(
      onTap: isClickable ? () => controller.onDashaItemClick(item) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: AppText(
                item.planet != null ? item.planet!.replaceAll(' - ', ' -\n') : "N/A",
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: AppText(
                item.startDate ?? "N/A",
                fontSize: 11,
                color: Colors.grey[700],
              ),
            ),
            Expanded(
              child: AppText(
                item.endDate ?? "N/A",
                fontSize: 11,
                color: Colors.grey[700],
              ),
            ),
            Icon(
              isClickable ? Icons.chevron_right : Icons.check_circle_outline,
              size: 18,
              color: isClickable ? Colors.grey[400] : Colors.green[300],
            ),
          ],
        ),
      ),
    );
  }
}
