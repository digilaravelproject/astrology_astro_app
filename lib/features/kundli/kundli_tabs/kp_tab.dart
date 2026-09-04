import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import 'package:astro_astrologer/features/kundli/presentation/controllers/kp_controller.dart';

class KPTab extends StatelessWidget {
  const KPTab({super.key});

  @override
  Widget build(BuildContext context) {
    final KPController kpController = Get.find<KPController>();

    return Obx(() {
      if (kpController.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          ),
        );
      }

      if (kpController.error.value.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: AppText(
              "Error: ${kpController.error.value}",
              color: Colors.red,
            ),
          ),
        );
      }

      final data = kpController.kpFullReportModel.value?.data;
      if (data == null) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: AppText("No KP data available".tr),
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data.rulingPlanets != null)
              _buildRulingPlanets(data.rulingPlanets!),
            if (data.rulingPlanets != null) const SizedBox(height: 24),
            _buildPlanetsTable(data.planets),
            const SizedBox(height: 24),
            _buildCuspsTable(data.cusps),
          ],
        ),
      );
    });
  }

  Widget _buildRulingPlanets(rulingPlanets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText("Ruling Planets".tr,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 12),
        Container(
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
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: AppText("Factor".tr,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: AppText("Sign Lord".tr,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: AppText("Star Lord".tr,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: AppText("Sub Lord".tr,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildRulingRow(
                "Ascendant",
                rulingPlanets.ascendantSignLord ?? "-",
                rulingPlanets.ascendantNakshatraLord ?? "-",
                rulingPlanets.ascendantSubLord ?? "-",
                isEven: true,
              ),
              _buildRulingRow(
                "Moon",
                rulingPlanets.moonSignLord ?? "-",
                rulingPlanets.moonNakshatraLord ?? "-",
                rulingPlanets.moonSubLord ?? "-",
                isEven: false,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      flex: 3,
                      child: AppText("Day Lord".tr,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Center(
                        child: AppText(
                          rulingPlanets.dayLord ?? "-",
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRulingRow(
    String factor,
    String signLord,
    String starLord,
    String subLord, {
    required bool isEven,
  }) {
    return Container(
      color: isEven ? Colors.white : Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: AppText(factor, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          Expanded(
            flex: 2,
            child: Center(child: AppText(signLord, fontSize: 13)),
          ),
          Expanded(
            flex: 2,
            child: Center(child: AppText(starLord, fontSize: 13)),
          ),
          Expanded(
            flex: 2,
            child: Center(child: AppText(subLord, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetsTable(planets) {
    if (planets == null || planets.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText("KP Planets".tr, fontSize: 16, fontWeight: FontWeight.bold),
        const SizedBox(height: 12),
        Container(
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
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppText("Planet".tr,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: AppText("Degree".tr,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: AppText("Sign".tr,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: AppText("SGL".tr,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: AppText("STL".tr,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: AppText("SBL".tr,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...List.generate(planets.length, (index) {
                final p = planets[index];
                final degreeStr =
                    p.degree != null ? "${p.degree!.toStringAsFixed(2)}°" : "-";
                final sgl =
                    p.signLord != null
                        ? (p.signLord!.length >= 2
                            ? p.signLord!.substring(0, 2)
                            : p.signLord!)
                        : "-";
                final stl =
                    p.nakshatraLord != null
                        ? (p.nakshatraLord!.length >= 2
                            ? p.nakshatraLord!.substring(0, 2)
                            : p.nakshatraLord!)
                        : "-";
                final sbl =
                    p.subLord != null
                        ? (p.subLord!.length >= 2
                            ? p.subLord!.substring(0, 2)
                            : p.subLord!)
                        : "-";
                return _buildTableRowPlanets(
                  [p.planet ?? "-", degreeStr, p.sign ?? "-", sgl, stl, sbl],
                  isEven: index % 2 == 0,
                  isLast: index == planets.length - 1,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCuspsTable(cusps) {
    if (cusps == null || cusps.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText("KP Cusps (Houses)".tr,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 12),
        Container(
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
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: AppText("House".tr,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: AppText("Degree".tr,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: AppText("Sign".tr,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: AppText("SGL".tr,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: AppText("STL".tr,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: AppText("SBL".tr,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...List.generate(cusps.length, (index) {
                final c = cusps[index];
                final degreeStr =
                    c.cuspLongitude != null
                        ? "${c.cuspLongitude!.toStringAsFixed(2)}°"
                        : "-";
                final sgl =
                    c.signLord != null
                        ? (c.signLord!.length >= 2
                            ? c.signLord!.substring(0, 2)
                            : c.signLord!)
                        : "-";
                final stl =
                    c.nakshatraLord != null
                        ? (c.nakshatraLord!.length >= 2
                            ? c.nakshatraLord!.substring(0, 2)
                            : c.nakshatraLord!)
                        : "-";
                final sbl =
                    c.subLord != null
                        ? (c.subLord!.length >= 2
                            ? c.subLord!.substring(0, 2)
                            : c.subLord!)
                        : "-";
                return _buildTableRowPlanets(
                  [
                    "H${c.house?.toString() ?? '-'}",
                    degreeStr,
                    c.sign ?? "-",
                    sgl,
                    stl,
                    sbl,
                  ],
                  isEven: index % 2 == 0,
                  isLast: index == cusps.length - 1,
                  firstFlex: 1,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableRowPlanets(
    List<String> values, {
    required bool isEven,
    bool isLast = false,
    int firstFlex = 2,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isEven ? Colors.white : Colors.grey.shade50,
        borderRadius:
            isLast
                ? const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                )
                : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            flex: firstFlex,
            child: AppText(
              values[0],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(child: AppText(values[1], fontSize: 12)),
          ),
          Expanded(
            flex: 2,
            child: Center(child: AppText(values[2], fontSize: 12)),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: AppText(
                values[3],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: AppText(
                values[4],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: AppText(
                values[5],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
