import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../kundli_chart_widget.dart';
import '../controllers/divisional_chart_controller.dart';
import '../controllers/house_cusps_controller.dart';
import '../controllers/planet_positions_controller.dart';

class DivisionalChartTab extends StatefulWidget {
  final String datetime;
  final double latitude;
  final double longitude;
  final String timezone;

  const DivisionalChartTab({
    super.key,
    required this.datetime,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  @override
  State<DivisionalChartTab> createState() => _DivisionalChartTabState();
}

class _DivisionalChartTabState extends State<DivisionalChartTab> {
  String _selectedStyle = "North Indian";
  String _selectedChartType = "Hora"; // Default to Hora so it loads immediately

  final List<String> _chartTypes = [
    "Chalit",
    "Sun",
    "Moon",
    "Hora",
    "Drekkana",
    "Chaturthamsha"
  ];

  final DivisionalChartController _divisionalChartController = Get.find<DivisionalChartController>();
  final HouseCuspsController _houseCuspsController = Get.find<HouseCuspsController>();
  final PlanetPositionsController _planetPositionsController = Get.find<PlanetPositionsController>();

  void _onChartTypeSelected(String type) {
    setState(() => _selectedChartType = type);
    
    int? division;
    if (type == "Hora") division = 2;
    else if (type == "Drekkana") division = 3;
    else if (type == "Chaturthamsha") division = 4;
    
    if (division != null) {
      _divisionalChartController.fetchDivisionalChart(
        division: division, 
        datetime: widget.datetime, 
        latitude: widget.latitude, 
        longitude: widget.longitude, 
        timezone: widget.timezone,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStyleToggles(),
          const SizedBox(height: 16),
          _buildChartTypeSelector(),
          SizedBox(height: 16),
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
            onTap: () => _onChartTypeSelected(type),
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
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: AspectRatio(
        aspectRatio: 1,
        child: Obx(() {
          final northPlanetData = <int, List<String>>{};
          final southPlanetData = <int, List<String>>{};
          bool isLoading = _divisionalChartController.isLoading.value;

          if (["Hora", "Drekkana", "Chaturthamsha"].contains(_selectedChartType)) {
            final positions = _divisionalChartController.divisionalChartModel.value?.data?.positions ?? [];
            for (var p in positions) {
              if (p.house != null && p.planet != null) {
                northPlanetData.putIfAbsent(p.house!, () => []).add(p.planet!.substring(0, 2));
              }
              if (p.planet != null) {
                southPlanetData.putIfAbsent(p.signNumber, () => []).add(p.planet!.substring(0, 2));
              }
            }
          } else if (["Sun", "Moon"].contains(_selectedChartType)) {
            isLoading = _planetPositionsController.isLoading.value;
            final planets = _planetPositionsController.planetPositionsModel.value?.data?.planets ?? [];
            
            // Find the anchor planet's house
            int anchorHouse = 1;
            for (var p in planets) {
              if (p.name == _selectedChartType && p.house != null) {
                anchorHouse = p.house!;
                break;
              }
            }

            for (var p in planets) {
              if (p.name != null && p.house != null && p.signNumber != null) {
                final abbr = p.name!.substring(0, 2);
                // Rotate North Indian houses
                final newHouse = (p.house! - anchorHouse + 12) % 12 + 1;
                northPlanetData.putIfAbsent(newHouse, () => []).add(abbr);
                // South Indian doesn't rotate signs
                southPlanetData.putIfAbsent(p.signNumber!, () => []).add(abbr);
              }
            }
          } else if (_selectedChartType == "Chalit") {
            isLoading = _houseCuspsController.isLoading.value || _planetPositionsController.isLoading.value;
            final cusps = _houseCuspsController.houseCuspsModel.value?.data ?? [];
            final planets = _planetPositionsController.planetPositionsModel.value?.data?.planets ?? [];
            
            if (cusps.isNotEmpty && planets.isNotEmpty) {
              // Ensure cusps are sorted by house number
              final sortedCusps = List.of(cusps)..sort((a, b) => (a.number ?? 0).compareTo(b.number ?? 0));
              
              for (var p in planets) {
                if (p.name != null && p.fullDegree != null) {
                  final abbr = p.name!.substring(0, 2);
                  final deg = p.fullDegree!;
                  
                  int house = 1;
                  int signNumber = 1;
                  
                  for (int i = 0; i < sortedCusps.length; i++) {
                    final currentCusp = sortedCusps[i];
                    final nextCusp = sortedCusps[(i + 1) % sortedCusps.length];
                    
                    final startDeg = currentCusp.cusp ?? 0.0;
                    final endDeg = nextCusp.cusp ?? 0.0;
                    
                    bool inHouse = false;
                    if (startDeg < endDeg) {
                      inHouse = deg >= startDeg && deg < endDeg;
                    } else {
                      inHouse = deg >= startDeg || deg < endDeg; // Wraps around 360
                    }
                    
                    if (inHouse) {
                      house = currentCusp.number ?? 1;
                      // Determine sign number based on cusp's sign
                      signNumber = currentCusp.signNumber ?? 1;
                      break;
                    }
                  }
                  
                  northPlanetData.putIfAbsent(house, () => []).add(abbr);
                  southPlanetData.putIfAbsent(signNumber, () => []).add(abbr);
                }
              }
            }
          }

          return KundliChartWidget(
            title: "$_selectedChartType Chart ($_selectedStyle)",
            northIndianPlanetData: northPlanetData,
            southIndianPlanetData: southPlanetData,
            isLoading: isLoading,
          );
        }),
      ),
    );
  }
}

