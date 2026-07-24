import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../controllers/kp_controller.dart';

class KPTab extends StatelessWidget {
  const KPTab({super.key});

  @override
  Widget build(BuildContext context) {
    final KPController kpController = Get.find<KPController>();

    return Obx(() {
      if (kpController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (kpController.error.value.isNotEmpty) {
        return Center(
          child: AppText("Error: ${kpController.error.value}", color: Colors.red),
        );
      }

      final data = kpController.kpFullReportModel.value?.data;
      if (data == null) {
        return const Center(child: AppText("No KP data available"));
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data.rulingPlanets != null) _buildRulingPlanets(data.rulingPlanets!),
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
        const AppText("Ruling Planets", fontSize: 16, fontWeight: FontWeight.bold),
        const SizedBox(height: 12),
        Container(
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
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor, 
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(child: Center(child: AppText("--", fontSize: 12, fontWeight: FontWeight.bold))),
                      Expanded(child: Center(child: AppText("Sign\nLord", fontSize: 12, fontWeight: FontWeight.bold, textAlign: TextAlign.center))),
                      Expanded(child: Center(child: AppText("Star\nLord", fontSize: 12, fontWeight: FontWeight.bold, textAlign: TextAlign.center))),
                      Expanded(child: Center(child: AppText("Sub\nLord", fontSize: 12, fontWeight: FontWeight.bold, textAlign: TextAlign.center))),
                    ],
                  ),
                ),
              ),
              _buildTableRow(["Ascendant", rulingPlanets.ascendantSignLord ?? "-", rulingPlanets.ascendantNakshatraLord ?? "-", rulingPlanets.ascendantSubLord ?? "-"], isEven: true),
              _buildTableRow(["Moon", rulingPlanets.moonSignLord ?? "-", rulingPlanets.moonNakshatraLord ?? "-", rulingPlanets.moonSubLord ?? "-"], isEven: false),
              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      const Expanded(flex: 2, child: Center(child: AppText("Day Lord", fontSize: 13, fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Center(child: AppText(rulingPlanets.dayLord ?? "-", fontSize: 13))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanetsTable(planets) {
    if (planets == null || planets.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText("Planets", fontSize: 16, fontWeight: FontWeight.bold),
        const SizedBox(height: 12),
        Container(
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
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor, 
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Center(child: AppText("Planet", fontSize: 12, fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Center(child: AppText("Degree", fontSize: 12, fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Center(child: AppText("Sign", fontSize: 12, fontWeight: FontWeight.bold))),
                      Expanded(flex: 1, child: Center(child: AppText("SGL", fontSize: 12, fontWeight: FontWeight.bold, textAlign: TextAlign.center))),
                      Expanded(flex: 1, child: Center(child: AppText("STL", fontSize: 12, fontWeight: FontWeight.bold, textAlign: TextAlign.center))),
                      Expanded(flex: 1, child: Center(child: AppText("SBL", fontSize: 12, fontWeight: FontWeight.bold, textAlign: TextAlign.center))),
                    ],
                  ),
                ),
              ),
              ...List.generate(planets.length, (index) {
                final p = planets[index];
                final degreeStr = p.degree != null ? "${p.degree!.toStringAsFixed(2)}°" : "-";
                final sgl = p.signLord != null ? p.signLord!.substring(0, 2) : "-";
                final stl = p.nakshatraLord != null ? p.nakshatraLord!.substring(0, 2) : "-";
                final sbl = p.subLord != null ? p.subLord!.substring(0, 2) : "-";
                return _buildTableRowPlanets([p.planet ?? "-", degreeStr, p.sign ?? "-", sgl, stl, sbl], isEven: index % 2 == 0);
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
        const AppText("Cusps (Houses)", fontSize: 16, fontWeight: FontWeight.bold),
        const SizedBox(height: 12),
        Container(
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
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor, 
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(flex: 1, child: Center(child: AppText("Cusp", fontSize: 12, fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Center(child: AppText("Degree", fontSize: 12, fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Center(child: AppText("Sign", fontSize: 12, fontWeight: FontWeight.bold))),
                      Expanded(flex: 1, child: Center(child: AppText("SGL", fontSize: 12, fontWeight: FontWeight.bold, textAlign: TextAlign.center))),
                      Expanded(flex: 1, child: Center(child: AppText("STL", fontSize: 12, fontWeight: FontWeight.bold, textAlign: TextAlign.center))),
                      Expanded(flex: 1, child: Center(child: AppText("SBL", fontSize: 12, fontWeight: FontWeight.bold, textAlign: TextAlign.center))),
                    ],
                  ),
                ),
              ),
              ...List.generate(cusps.length, (index) {
                final c = cusps[index];
                final degreeStr = c.cuspLongitude != null ? "${c.cuspLongitude!.toStringAsFixed(2)}°" : "-";
                final sgl = c.signLord != null ? c.signLord!.substring(0, 2) : "-";
                final stl = c.nakshatraLord != null ? c.nakshatraLord!.substring(0, 2) : "-";
                final sbl = c.subLord != null ? c.subLord!.substring(0, 2) : "-";
                return _buildTableRowPlanets([c.house?.toString() ?? "-", degreeStr, c.sign ?? "-", sgl, stl, sbl], isEven: index % 2 == 0);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableRow(List<String> cells, {required bool isEven}) {
    return Container(
      color: isEven ? Colors.transparent : Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: cells.map((text) {
          return Expanded(
            child: Center(
              child: AppText(text, fontSize: 13, color: Colors.black87),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTableRowPlanets(List<String> cells, {required bool isEven}) {
    return Container(
      decoration: BoxDecoration(
        color: isEven ? Colors.transparent : Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 2, child: Center(child: AppText(cells[0], fontSize: 12, color: Colors.black87))),
          Expanded(flex: 2, child: Center(child: AppText(cells[1], fontSize: 12, color: Colors.black87))),
          Expanded(flex: 2, child: Center(child: AppText(cells[2], fontSize: 12, color: Colors.black87))),
          Expanded(flex: 1, child: Center(child: AppText(cells[3], fontSize: 12, color: Colors.black87))),
          Expanded(flex: 1, child: Center(child: AppText(cells[4], fontSize: 12, color: Colors.black87))),
          Expanded(flex: 1, child: Center(child: AppText(cells[5], fontSize: 12, color: Colors.black87))),
        ],
      ),
    );
  }
}
