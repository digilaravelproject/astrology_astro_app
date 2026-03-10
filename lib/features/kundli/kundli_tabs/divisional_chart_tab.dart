import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import 'package:astro_astrologer/features/kundli/kundli_chart_widget.dart';

class DivisionalChartTab extends StatefulWidget {
  const DivisionalChartTab({super.key});

  @override
  State<DivisionalChartTab> createState() => _DivisionalChartTabState();
}

class _DivisionalChartTabState extends State<DivisionalChartTab> {
  String _selectedStyle = "North Indian";
  String _selectedChartType = "Chalit";

  final List<String> _chartTypes = [
    "Chalit",
    "Sun",
    "Moon",
    "Hora",
    "Drekkana",
    "Chaturthamsha"
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStyleToggles(),
          const SizedBox(height: 16),
          _buildChartTypeSelector(),
          const SizedBox(height: 16),
          _buildChartArea(),
        ],
      ),
    );
  }

  Widget _buildStyleToggles() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => setState(() => _selectedStyle = "North Indian"),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: _selectedStyle == "North Indian" ? AppColors.primaryColor : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: AppText(
              "North Indian",
              color: _selectedStyle == "North Indian" ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => setState(() => _selectedStyle = "South Indian"),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: _selectedStyle == "South Indian" ? AppColors.primaryColor : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(8),
            ),
            child: AppText(
              "South Indian",
              color: _selectedStyle == "South Indian" ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartTypeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _chartTypes.map((type) {
          bool isSelected = _selectedChartType == type;
          return GestureDetector(
            onTap: () => setState(() => _selectedChartType = type),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: AppText(
                type,
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartArea() {
    // Dummy data based on the screenshot
    final Map<int, List<String>> _divisionalPlanetData = {
      1: ["Asc-14.68°", "Ne-0.61°", "Me-19.25°", "Su-21.23°"],
      2: [],
      3: ["Ra-0.91°R"],
      4: [],
      5: ["Ma-2.06°"],
      6: ["Pl-2.51°", "Sa-26.09°", "Ju-8.3°"],
      7: ["Ur-7.67°"],
      8: [],
      9: ["Ke-0.91°R", "Ve-5.11°"],
      10: [],
      11: [],
      12: ["Mo-20.99°"],
    };

    return Container(
      width: double.infinity,
      color: Colors.white,
      child: AspectRatio(
        aspectRatio: 1,
        child: KundliChartWidget(
          title: "$_selectedChartType Chart ($_selectedStyle)",
          planetData: _divisionalPlanetData,
        ),
      ),
    );
  }
}
