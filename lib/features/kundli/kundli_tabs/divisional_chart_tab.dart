import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/features/kundli/kundli_chart_widget.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/divisional_chart_controller.dart';

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
  String _selectedChartType = "D2 (Hora)";

  final Map<String, String> _chartTypesMap = const {
    "Chalit": "chalit",
    "Sun": "SUN",
    "Moon": "MOON",
    "D1 (Birth)": "D1",
    "D2 (Hora)": "D2",
    "D3 (Drekkana)": "D3",
    "D4 (Chaturthamsha)": "D4",
    "D5 (Panchmansha)": "D5",
    "D7 (Saptamansha)": "D7",
    "D8 (Ashtamansha)": "D8",
    "D9 (Navamansha)": "D9",
    "D10 (Dashamansha)": "D10",
    "D12 (Dwadashamsha)": "D12",
    "D16 (Shodashamsha)": "D16",
    "D20 (Vishamansha)": "D20",
    "D24 (Chaturvimshamsha)": "D24",
    "D27 (Bhamsha)": "D27",
    "D30 (Trishamansha)": "D30",
    "D40 (Khavedamsha)": "D40",
    "D45 (Akshvedansha)": "D45",
    "D60 (Shashtymsha)": "D60",
  };

  late final DivisionalChartController _divisionalChartController;

  @override
  void initState() {
    super.initState();
    _divisionalChartController = Get.find<DivisionalChartController>();
    _fetchCurrentChartSvg(_selectedChartType);
  }

  void _onChartTypeSelected(String type) {
    setState(() => _selectedChartType = type);
    _fetchCurrentChartSvg(type);
  }

  void _fetchCurrentChartSvg(String type) {
    final chartId = _chartTypesMap[type] ?? "D2";
    _divisionalChartController.fetchDivisionalChartSvg(
      chartId: chartId,
      datetime: widget.datetime,
      latitude: widget.latitude,
      longitude: widget.longitude,
      timezone: widget.timezone,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildChartTypeSelector(),
          const SizedBox(height: 16),
          _buildChartArea(),
        ],
      ),
    );
  }

  Widget _buildChartTypeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _chartTypesMap.keys.map((type) {
          bool isSelected = _selectedChartType == type;
          return GestureDetector(
            onTap: () => _onChartTypeSelected(type),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
                ),
              ),
              child: AppText(
                type,
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
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
        aspectRatio: 0.85,
        child: Obx(() {
          return KundliChartWidget(
            title: "$_selectedChartType Chart",
            northIndianSvg: _divisionalChartController.northChartSvg.value,
            southIndianSvg: _divisionalChartController.southChartSvg.value,
            isLoading: _divisionalChartController.isSvgLoading.value,
          );
        }),
      ),
    );
  }
}
