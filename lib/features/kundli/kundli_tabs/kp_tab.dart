import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import 'package:astro_astrologer/features/kundli/kundli_chart_widget.dart';

class KPTab extends StatelessWidget {
  const KPTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBhavChalitChart(),
          const SizedBox(height: 24),
          _buildRulingPlanets(),
          const SizedBox(height: 24),
          _buildPlanetsTable(),
        ],
      ),
    );
  }

  Widget _buildBhavChalitChart() {
    final Map<int, List<String>> _kpPlanetData = {
      1: ["Asc-14.68°", "Ne-0.61°", "Me-19.25°", "Su-21.23°"],
      2: [],
      3: ["Ra®"],
      4: [],
      5: ["Ma"],
      6: ["Pl", "Sa", "Ur", "Ju"],
      7: [],
      8: [],
      9: ["Ve", "Ke®"],
      10: [],
      11: ["Mo"],
      12: [],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText("Bhav Chalit Chart", fontSize: 16, fontWeight: FontWeight.bold),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          color: Colors.white,
          child: AspectRatio(
            aspectRatio: 1,
            child: KundliChartWidget(
              title: "",
              planetData: _kpPlanetData,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRulingPlanets() {
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
                  color: AppColors.primaryColor, // header
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
              _buildTableRow(["", "Jupiter", "Saturn", "MOON"], isEven: true),
              _buildTableRow(["", "Saturn", "Moon", "Moon"], isEven: false),
              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Center(child: AppText("Day Lord", fontSize: 13, fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Center(child: AppText("Venus", fontSize: 13))),
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

  Widget _buildPlanetsTable() {
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
                  color: AppColors.primaryColor, // header
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Center(child: AppText("Planet", fontSize: 12, fontWeight: FontWeight.bold))),
                      Expanded(flex: 1, child: Center(child: AppText("cusp", fontSize: 12, fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Center(child: AppText("Sign", fontSize: 12, fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Center(child: AppText("Sign\nLord", fontSize: 12, fontWeight: FontWeight.bold, textAlign: TextAlign.center))),
                      Expanded(flex: 2, child: Center(child: AppText("Star\nLord", fontSize: 12, fontWeight: FontWeight.bold, textAlign: TextAlign.center))),
                      Expanded(flex: 2, child: Center(child: AppText("Sub\nLord", fontSize: 12, fontWeight: FontWeight.bold, textAlign: TextAlign.center))),
                    ],
                  ),
                ),
              ),
              _buildTableRowPlanets(["Sun", "1", "Scorpio", "Ma", "Me", "Ve"], isEven: true),
              // Dummy rows as placeholders for full list
              _buildTableRowPlanets(["Moon", "5", "Pisces", "Ju", "Me", "Mo"], isEven: false),
              _buildTableRowPlanets(["Mars", "11", "Virgo", "Me", "Su", "Ju"], isEven: true),
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
          Expanded(flex: 1, child: Center(child: AppText(cells[1], fontSize: 12, color: Colors.black87))),
          Expanded(flex: 2, child: Center(child: AppText(cells[2], fontSize: 12, color: Colors.black87))),
          Expanded(flex: 2, child: Center(child: AppText(cells[3], fontSize: 12, color: Colors.black87))),
          Expanded(flex: 2, child: Center(child: AppText(cells[4], fontSize: 12, color: Colors.black87))),
          Expanded(flex: 2, child: Center(child: AppText(cells[5], fontSize: 12, color: Colors.black87))),
        ],
      ),
    );
  }
}
