import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/core/widgets/app_text.dart';
import 'package:astro_astrologer/features/kundli/presentation/controllers/dasha_controller.dart';
import 'package:astro_astrologer/features/kundli/data/models/dasha_model.dart';

class DashaTab extends StatelessWidget {
  final DashaController controller;

  const DashaTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.breadcrumbs.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          ),
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.05),
                    ),
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
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: AppText("Planet".tr,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Expanded(
                              child: AppText("Start Date".tr,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Expanded(
                              child: AppText("End Date".tr,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(width: 24),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),

                      if (controller.currentDashaItems.isEmpty &&
                          !controller.isLoading.value)
                        Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(
                            child: AppText("No dasha details available.".tr),
                          ),
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
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
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

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (canGoBack)
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 18,
                  color: AppColors.primaryColor,
                ),
                onPressed: () => controller.goBack(),
              ),
            AppText(
              controller.currentTitle,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        if (canGoBack) ...[
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(controller.breadcrumbs.length, (index) {
                final item = controller.breadcrumbs[index];
                final isLast = index == controller.breadcrumbs.length - 1;

                // Show standard level name for root/first item or display label
                String displayTitle = item.title;
                if (index == 0) {
                  displayTitle = "Mahadasha";
                } else if (index == 1) {
                  displayTitle = "AntarDasha > ${item.title}";
                } else if (index == 2) {
                  displayTitle = "PratyantarDasha > ${item.title}";
                } else if (index == 3) {
                  displayTitle = "SookshmaDasha > ${item.title}";
                } else if (index == 4) {
                  displayTitle = "PranaDasha > ${item.title}";
                }

                return GestureDetector(
                  onTap: () {
                    if (!isLast) {
                      controller.navigateToBreadcrumbIndex(index);
                    }
                  },
                  child: Row(
                    children: [
                      if (index > 0)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isLast
                                  ? AppColors.primaryColor.withOpacity(0.1)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AppText(
                          displayTitle,
                          fontSize: 12,
                          fontWeight:
                              isLast ? FontWeight.w700 : FontWeight.w500,
                          color:
                              isLast
                                  ? AppColors.primaryColor
                                  : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDashaRow(DashaItem item) {
    final isClickable = controller.currentLevel != DashaLevel.pranadasha;

    // Build planet hierarchy path from breadcrumbs
    final selectedPlanets =
        controller.breadcrumbs
            .where((b) => b.planet != null && b.planet!.isNotEmpty)
            .map((b) => b.planet!)
            .toList();

    final currentPlanet = item.planet ?? "N/A";
    final fullPlanetPath = [...selectedPlanets, currentPlanet].join(" - ");

    return InkWell(
      onTap: isClickable ? () => controller.onDashaItemClick(item) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: AppText(
                fullPlanetPath,
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
