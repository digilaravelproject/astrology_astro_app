import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import 'package:astro_astrologer/features/kundli/kundli_chart_widget.dart';
import 'kundli_tabs/shad_bala_tab.dart';
import 'kundli_tabs/bhav_bala_tab.dart';
import 'kundli_tabs/manglik_report_tab.dart';
import 'kundli_tabs/divisional_chart_tab.dart';
import 'kundli_tabs/kp_tab.dart';
import 'kundli_tabs/sade_sati_tab.dart';
import 'controllers/panchang_controller.dart';
import 'controllers/dasha_controller.dart';
import 'controllers/birth_chart_controller.dart';
import 'controllers/navamsha_controller.dart';
import 'controllers/transit_controller.dart';
import 'controllers/divisional_chart_controller.dart';
import 'controllers/house_cusps_controller.dart';
import 'controllers/kp_controller.dart';
import 'controllers/sade_sati_controller.dart';
import 'models/dasha_model.dart';
import 'controllers/planet_positions_controller.dart';
import 'controllers/shadbala_controller.dart';
import 'controllers/remedies_controller.dart';
import 'package:collection/collection.dart';

class KundliScreen extends StatefulWidget {
  final String fullName;
  final String gender;
  final String dob; // format: YYYY-MM-DD
  final String tob; // format: HH:mm:ss
  final String place;
  final double latitude;
  final double longitude;

  const KundliScreen({
    super.key,
    required this.fullName,
    required this.gender,
    required this.dob,
    required this.tob,
    required this.place,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<KundliScreen> createState() => _KundliScreenState();
}

class _KundliScreenState extends State<KundliScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PanchangController _panchangController = Get.put(PanchangController());
  final DashaController _dashaController = Get.put(DashaController());
  final PlanetPositionsController _planetPositionsController = Get.put(PlanetPositionsController());
  final ShadbalaController _shadbalaController = Get.put(ShadbalaController());
  final BirthChartController _birthChartController = Get.put(BirthChartController());
  final NavamshaController _navamshaController = Get.put(NavamshaController());
  final TransitController _transitController = Get.put(TransitController());
  final DivisionalChartController _divisionalChartController = Get.put(DivisionalChartController());
  final HouseCuspsController _houseCuspsController = Get.put(HouseCuspsController());
  final KPController _kpController = Get.put(KPController());
  final SadeSatiController _sadeSatiController = Get.put(SadeSatiController());
  final RemediesController _remediesController = Get.put(RemediesController());

  int _selectedTabIndex = 0;
  final List<String> _tabs = [
    "Basic",
    "Lagna",
    "Navamsa",
    "Transit",
    "Dasha",
    "Divisional Chart",
    "KP",
    "Sade Sati",
    "Shad Bala",
    "Bhav Bala",
    "Manglik Report",
    "Varshphal",
    "Remedies"
  ];

  String _selectedBasicSubTab = "Birth Details";

  String _name = "";
  String _gender = "";
  String _place = "";
  String _dobStr = "";
  String _timeStr = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    String dt = "";
    if (widget.dob.isNotEmpty) {
      if (widget.dob.contains("T")) {
        dt = widget.dob;
      } else {
        String t = widget.tob.isEmpty ? "00:00:00" : widget.tob;
        if (t.length == 5) t += ":00";
        dt = "${widget.dob}T$t";
      }
    }

    final lat = widget.latitude;
    final lng = widget.longitude;
    const tz = "+05:30";

    _name = widget.fullName;
    _gender = widget.gender;
    _place = widget.place;

    print('════════════════════════════════════════════════════════════════');
    print('🌟 [KUNDLI SCREEN OPENED] Received Data:');
    print('   • Full Name: $_name');
    print('   • Gender: $_gender');
    print('   • DOB: ${widget.dob}');
    print('   • TOB: ${widget.tob}');
    print('   • Combined ISO Datetime: $dt');
    print('   • Place of Birth (POB): $_place');
    print('   • Latitude (Lat): $lat');
    print('   • Longitude (Lng): $lng');
    print('   • Timezone (TZ): $tz');
    print('════════════════════════════════════════════════════════════════');

    try {
      final parsedDt = DateTime.parse(dt);
      final months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
      _dobStr = "${parsedDt.day.toString().padLeft(2, '0')} ${months[parsedDt.month - 1]} ${parsedDt.year}";

      int hour = parsedDt.hour;
      String ampm = hour >= 12 ? "PM" : "AM";
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      _timeStr = "${hour.toString().padLeft(2, '0')}:${parsedDt.minute.toString().padLeft(2, '0')} $ampm";
    } catch (_) {}

    final reqLat = lat;
    final reqLng = lng;

    _panchangController.fetchPanchangDetails(datetime: dt, latitude: reqLat, longitude: reqLng, timezone: tz);
    _dashaController.fetchDashaDetails(datetime: dt, latitude: reqLat, longitude: reqLng, timezone: tz);
    _planetPositionsController.fetchPlanetPositions(datetime: dt, latitude: reqLat, longitude: reqLng, timezone: tz);
    _shadbalaController.fetchShadbalaDetails(datetime: dt, latitude: reqLat, longitude: reqLng, timezone: tz);
    _birthChartController.fetchBirthChart(datetime: dt, latitude: reqLat, longitude: reqLng, timezone: tz);
    _navamshaController.fetchNavamsha(datetime: dt, latitude: reqLat, longitude: reqLng, timezone: tz);
    _transitController.fetchTransit(datetime: dt, latitude: reqLat, longitude: reqLng, timezone: tz);
    _divisionalChartController.fetchDivisionalChart(division: 2, datetime: dt, latitude: reqLat, longitude: reqLng, timezone: tz);
    _houseCuspsController.fetchHouseCusps(datetime: dt, latitude: reqLat, longitude: reqLng, timezone: tz);
    _kpController.fetchKPData(datetime: dt, latitude: reqLat, longitude: reqLng, timezone: tz);
    _sadeSatiController.fetchSadeSati(datetime: dt, latitude: reqLat, longitude: reqLng, timezone: tz);
    _remediesController.fetchGemstoneRemedies(datetime: dt, latitude: reqLat, longitude: reqLng, timezone: tz);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF9F5),
      appBar: CustomAppBar(
        title: 'Kundli',
      ),

      body: Column(
        children: [
          _buildTopTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBasicTab(),
                Obx(() {
                  final planets = _birthChartController.birthChartModel.value?.data?.planets ?? [];
                  
                  // Map data for North Indian chart (key = house)
                  final northPlanetData = <int, List<String>>{};
                  for (var planet in planets) {
                    if (planet.house != null && planet.name != null) {
                      northPlanetData.putIfAbsent(planet.house!, () => []).add(planet.name!.substring(0, 2));
                    }
                  }

                  // Map data for South Indian chart (key = signNumber)
                  final southPlanetData = <int, List<String>>{};
                  for (var planet in planets) {
                    if (planet.signNumber != null && planet.name != null) {
                      southPlanetData.putIfAbsent(planet.signNumber!, () => []).add(planet.name!.substring(0, 2));
                    }
                  }

                  return KundliChartWidget(
                    title: "Lagna / Ascendant / D1 Chart",
                    northIndianPlanetData: northPlanetData,
                    southIndianPlanetData: southPlanetData,
                    isLoading: _birthChartController.isLoading.value,
                  );
                }),
                Obx(() {
                  final planets = _navamshaController.navamshaModel.value?.data?.planets ?? [];
                  
                  // Map data for North Indian chart (key = house)
                  final northPlanetData = <int, List<String>>{};
                  for (var planet in planets) {
                    if (planet.house != null && planet.name != null) {
                      northPlanetData.putIfAbsent(planet.house!, () => []).add(planet.name!.substring(0, 2));
                    }
                  }

                  // Map data for South Indian chart (key = signNumber)
                  final southPlanetData = <int, List<String>>{};
                  for (var planet in planets) {
                    if (planet.signNumber != null && planet.name != null) {
                      southPlanetData.putIfAbsent(planet.signNumber!, () => []).add(planet.name!.substring(0, 2));
                    }
                  }

                  return KundliChartWidget(
                    title: "Navamsa Chart",
                    northIndianPlanetData: northPlanetData,
                    southIndianPlanetData: southPlanetData,
                    isLoading: _navamshaController.isLoading.value,
                  );
                }),
                Obx(() {
                  final planets = _transitController.transitModel.value?.data?.planets ?? [];
                  
                  // Map data for North Indian chart (key = houseFromLagna)
                  final northPlanetData = <int, List<String>>{};
                  for (var planet in planets) {
                    if (planet.houseFromLagna != null && planet.name != null) {
                      northPlanetData.putIfAbsent(planet.houseFromLagna!, () => []).add(planet.name!.substring(0, 2));
                    }
                  }

                  // Map data for South Indian chart (key = signNumber)
                  final southPlanetData = <int, List<String>>{};
                  for (var planet in planets) {
                    if (planet.signNumber != null && planet.name != null) {
                      southPlanetData.putIfAbsent(planet.signNumber!, () => []).add(planet.name!.substring(0, 2));
                    }
                  }

                  return KundliChartWidget(
                    title: "Transit Chart",
                    northIndianPlanetData: northPlanetData,
                    southIndianPlanetData: southPlanetData,
                    isLoading: _transitController.isLoading.value,
                  );
                }),
                _buildDashaTab("Mahadasha"),
                _buildDivisionalChartTab(),
                _buildKPTab(),
                _buildSadeSatiTab(),
                _buildShadBalaTab(),
                _buildBhavBalaTab(),
                _buildManglikReportTab(),
                _buildVarshphalTab(),
                _buildRemediesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        dividerColor: Colors.transparent,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.primaryColor,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
        tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  Widget _buildBasicTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSecondaryTabs(),
          const SizedBox(height: 12),
          if (_selectedBasicSubTab == "Birth Details") _buildBirthDetails(),
          if (_selectedBasicSubTab == "Panchang Details") _buildPanchangDetails(),
          if (_selectedBasicSubTab == "Avakhada Details") _buildAvakhadaDetails(),
        ],
      ),
    );
  }

  Widget _buildBirthDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Obx(() {
        final panchang = _panchangController.panchangModel.value?.data;
        String rawTz = panchang?.timezone ?? "";
        String timezoneDisplay = "GMT+05:30";
        if (rawTz.isNotEmpty) {
          if (rawTz.contains("+") || rawTz.contains("-")) {
            timezoneDisplay = rawTz.startsWith("+") || rawTz.startsWith("-") ? rawTz : "+$rawTz";
          } else {
            try {
              double val = double.parse(rawTz);
              int hours = val.abs().toInt();
              int minutes = ((val.abs() - hours) * 60).round();
              String sign = val >= 0 ? "+" : "-";
              timezoneDisplay = "$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
            } catch (_) {
              timezoneDisplay = rawTz;
            }
          }
        }

        return Column(
          children: [
            _buildInfoRow("Name", _name, true),
            _buildInfoRow("Date of Birth", _dobStr, true),
            _buildInfoRow("Time", _timeStr, true),
            _buildInfoRow("Place", _place, true),
            _buildInfoRow("Latitude", widget.latitude.toString(), false),
            _buildInfoRow("Longitude", widget.longitude.toString(), false),
            _buildInfoRow("Timezone", timezoneDisplay, false),
          ],
        );
      }),
    );
  }

  Widget _buildPanchangDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Obx(() {
        if (_panchangController.isLoading.value) {
          return const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
          );
        }

        final data = _panchangController.panchangModel.value?.data;
        if (data == null) {
          return const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(child: AppText("Failed to load Panchang details.")),
          );
        }

        return Column(
          children: [
            _buildInfoRow("Tithi", data.tithi?.name ?? "N/A", false),
            _buildInfoRow("Karan", data.karana?.name ?? "N/A", false),
            _buildInfoRow("Yog", data.yoga?.name ?? "N/A", false),
            _buildInfoRow("Nakshatra", data.nakshatra?.name ?? "N/A", false),
            _buildInfoRow("Masa", data.masa?.name ?? "N/A", false),
            _buildInfoRow("Ritu", data.ritu?.name ?? "N/A", false),
            _buildInfoRow("Vaara", data.vaara?.name ?? "N/A", false),
          ],
        );
      }),
    );
  }

  Widget _buildAvakhadaDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Obx(() {
        final planets = _planetPositionsController.planetPositionsModel.value?.data?.planets;
        final moon = planets?.firstWhereOrNull((p) => p.name?.toLowerCase() == 'moon');
        final panchang = _panchangController.panchangModel.value?.data;

        final sign = moon?.sign ?? "N/A";
        final nakshatra = panchang?.nakshatra?.name ?? moon?.nakshatra?.name ?? "N/A";

        return Column(
          children: [
            _buildInfoRow("Sign (Rashi)", sign, false),
            _buildInfoRow("Nakshatra", nakshatra, false),
            _buildInfoRow("Tithi", panchang?.tithi?.name ?? "N/A", false),
            _buildInfoRow("Yog", panchang?.yoga?.name ?? "N/A", false),
            _buildInfoRow("Karan", panchang?.karana?.name ?? "N/A", false),
            _buildInfoRow("Vaara", panchang?.vaara?.name ?? "N/A", false),
          ],
        );
      }),
    );
  }

  Widget _buildSecondaryTabs() {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSecondaryTabItem("Birth Details"),
            const SizedBox(width: 8),
            _buildSecondaryTabItem("Panchang Details"),
            const SizedBox(width: 8),
            _buildSecondaryTabItem("Avakhada Details"),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryTabItem(String label) {
    bool isActive = _selectedBasicSubTab == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedBasicSubTab = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive ? [BoxShadow(color: AppColors.primaryColor.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))] : null,
        ),
        child: Center(
          child: AppText(
            label,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? Colors.white : AppColors.textColorSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool showEdit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 2, child: AppText(label, fontSize: 12, color: Colors.grey.shade700)),
          Expanded(flex: 3, child: AppText(value, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildDashaTab(String title) {
    if (title == "Mahadasha") {
      return Obx(() {
        if (_dashaController.isLoading.value) {
          return const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
          );
        }

        final dashaDataList = _dashaController.dashaModel.value?.data?.mahaDasha;
        if (dashaDataList == null || dashaDataList.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(child: AppText("Failed to load Dasha details.")),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AppText(title, fontSize: 16, fontWeight: FontWeight.w700, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.primaryColor.withOpacity(0.05)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(child: AppText("Planet", fontWeight: FontWeight.bold, fontSize: 12)),
                          Expanded(child: AppText("Start Date", fontWeight: FontWeight.bold, fontSize: 12)),
                          Expanded(child: AppText("End Date", fontWeight: FontWeight.bold, fontSize: 12)),
                          SizedBox(width: 20),
                        ],
                      ),
                    ),
                    ...dashaDataList.map((data) {
                      return _buildDashaRow(
                        data.planet ?? "N/A",
                        data.startDate ?? "N/A",
                        data.endDate ?? "N/A",
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      });
    }

    final dashaData = [
      ["ID", "12-Sep-2023", "12-Sep-2024"],
      ["PI", "12-Sep-2024", "12-Sep-2026"],
      ["DH", "12-Sep-2026", "12-Sep-2029"],
      ["BR", "12-Sep-2029", "12-Sep-2033"],
      ["BH", "12-Sep-2033", "12-Sep-2038"],
      ["UL", "12-Sep-2038", "12-Sep-2044"],
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AppText(title, fontSize: 16, fontWeight: FontWeight.w700, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.primaryColor.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 6)),
              ],
            ),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(child: AppText("Planet", fontWeight: FontWeight.bold, fontSize: 12)),
                      Expanded(child: AppText("Start Date", fontWeight: FontWeight.bold, fontSize: 12)),
                      Expanded(child: AppText("End Date", fontWeight: FontWeight.bold, fontSize: 12)),
                      SizedBox(width: 20),
                    ],
                  ),
                ),
                ...dashaData.map((data) => _buildDashaRow(data[0], data[1], data[2])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashaRow(String planet, String start, String end) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: AppText(planet, fontSize: 12, fontWeight: FontWeight.w500)),
          Expanded(child: AppText(start, fontSize: 12, fontWeight: FontWeight.w500)),
          Expanded(child: AppText(end, fontSize: 12, fontWeight: FontWeight.w500)),
          const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  String _formatDegree(double degree) {
    int d = degree.floor();
    double minDouble = (degree - d) * 60;
    int m = minDouble.floor();
    int s = ((minDouble - m) * 60).round();
    return "${d.toString().padLeft(2, '0')}° ${m.toString().padLeft(2, '0')}' ${s.toString().padLeft(2, '0')}\"";
  }





  Widget _buildVarshphalTab() {
    int currentYear = DateTime.now().year;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Obx(() {
            final planets = _birthChartController.birthChartModel.value?.data?.planets ?? [];
            
            // Map data for North Indian chart (key = house)
            final northPlanetData = <int, List<String>>{};
            for (var planet in planets) {
              if (planet.house != null && planet.name != null) {
                northPlanetData.putIfAbsent(planet.house!, () => []).add(planet.name!.substring(0, 2));
              }
            }

            // Map data for South Indian chart (key = signNumber)
            final southPlanetData = <int, List<String>>{};
            for (var planet in planets) {
              if (planet.signNumber != null && planet.name != null) {
                southPlanetData.putIfAbsent(planet.signNumber!, () => []).add(planet.name!.substring(0, 2));
              }
            }

            return SizedBox(
              height: 300,
              child: KundliChartWidget(
                title: "Varshphal Chart - Year $currentYear",
                northIndianPlanetData: northPlanetData,
                southIndianPlanetData: southPlanetData,
                isLoading: _birthChartController.isLoading.value,
              ),
            );
          }),
          const SizedBox(height: 20),
          _buildVarshphalInfoGrid(currentYear),
          const SizedBox(height: 20),
          _buildMuddaDashaTable(),
          const SizedBox(height: 20),
          _buildPanchaVargeeyaBalaTable(),
        ],
      ),
    );
  }

  Widget _buildVarshphalInfoGrid(int currentYear) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Obx(() {
        final panchang = _panchangController.panchangModel.value?.data;
        return Column(
          children: [
            _buildInfoRow("Year", currentYear.toString(), false),
            _buildInfoRow("Tithi", panchang?.tithi?.name ?? "N/A", false),
            _buildInfoRow("Yoga", panchang?.yoga?.name ?? "N/A", false),
            _buildInfoRow("Karana", panchang?.karana?.name ?? "N/A", false),
            _buildInfoRow("Dina Lord (Vaara)", panchang?.vaara?.name ?? "N/A", false),
          ],
        );
      }),
    );
  }

  Widget _buildMuddaDashaTable() {
    return Obx(() {
      final dashaList = _dashaController.dashaModel.value?.data?.mahaDasha;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            const AppText("Mudda Dasha", fontWeight: FontWeight.bold, fontSize: 14),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(child: AppText("Planet", fontWeight: FontWeight.bold, fontSize: 12)),
                Expanded(child: AppText("Start Date", fontWeight: FontWeight.bold, fontSize: 12)),
                Expanded(child: AppText("End Date", fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            const Divider(height: 16),
            if (dashaList != null && dashaList.isNotEmpty)
              ...dashaList.take(6).map((data) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(child: AppText(data.planet ?? "N/A", fontSize: 12)),
                    Expanded(child: AppText(data.startDate ?? "N/A", fontSize: 12)),
                    Expanded(child: AppText(data.endDate ?? "N/A", fontSize: 12)),
                  ],
                ),
              ))
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: AppText("No Dasha details available.", fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildPanchaVargeeyaBalaTable() {
    return Obx(() {
      final shadbalaData = _shadbalaController.shadbalaModel.value?.data?.shadbala;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(color: AppColors.primaryColor.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          children: [
            const AppText("Pancha Vargeeya Bala", fontWeight: FontWeight.bold, fontSize: 14),
            const SizedBox(height: 12),
            if (shadbalaData != null && shadbalaData.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 15,
                  horizontalMargin: 0,
                  headingRowHeight: 35,
                  dataRowMinHeight: 30,
                  dataRowMaxHeight: 40,
                  columns: const [
                    DataColumn(label: AppText("Planet", fontWeight: FontWeight.bold, fontSize: 12)),
                    DataColumn(label: AppText("Total Strength", fontWeight: FontWeight.bold, fontSize: 12)),
                    DataColumn(label: AppText("Ratio", fontWeight: FontWeight.bold, fontSize: 12)),
                    DataColumn(label: AppText("Req Min", fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                  rows: shadbalaData.map((data) => DataRow(
                    cells: [
                      DataCell(AppText(data.planet ?? "N/A", fontSize: 12)),
                      DataCell(AppText(data.totalStrength?.toStringAsFixed(2) ?? "N/A", fontSize: 12)),
                      DataCell(AppText(data.strengthRatio?.toStringAsFixed(2) ?? "N/A", fontSize: 12)),
                      DataCell(AppText(data.requiredMinimum?.toStringAsFixed(2) ?? "N/A", fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  )).toList(),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: AppText("Loading Bala Strength Data...", fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildDivisionalChartTab() {
    String t = widget.tob.isEmpty ? "00:00:00" : widget.tob;
    if (t.length == 5) t += ":00";
    final dt = widget.dob.isNotEmpty ? "${widget.dob}T$t" : DateTime.now().toIso8601String().split('.')[0];
    final lat = widget.latitude;
    final lng = widget.longitude;
    final panchangTz = _panchangController.panchangModel.value?.data?.timezone;
    final tz = (panchangTz != null && panchangTz.isNotEmpty) ? panchangTz : "+05:30";

    return DivisionalChartTab(
      datetime: dt,
      latitude: lat,
      longitude: lng,
      timezone: tz,
    );
  }

  Widget _buildKPTab() {
    return const KPTab();
  }

  Widget _buildSadeSatiTab() {
    return const SadeSatiTab();
  }

  Widget _buildShadBalaTab() {
    return const ShadBalaTab();
  }

  Widget _buildBhavBalaTab() {
    return const BhavBalaTab();
  }

  Widget _buildManglikReportTab() {
    return const ManglikReportTab();
  }

  Widget _buildEmptyTab(String label) {
    return Center(child: AppText("$label implementation in progress", color: Colors.grey));
  }

  Widget _buildRemediesTab() {
    return Obx(() {
      if (_remediesController.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
        );
      }

      final crystalsList = _remediesController.remediesModel.value?.data?.crystals;
      if (crystalsList == null || crystalsList.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: AppText("Failed to load Remedies details.")),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: crystalsList.map((crystal) {
            return Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    "Remedies for ${crystal.planet ?? 'Unknown'} (${crystal.planetStrength ?? ''})",
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  const SizedBox(height: 12),
                  if (crystal.gemstone != null)
                    _buildRemedyCard(
                      "Gemstone",
                      "${crystal.gemstone!.gemstone} (${crystal.gemstone!.weight}). Wear on ${crystal.gemstone!.finger} on ${crystal.gemstone!.dayToWear}. Metal: ${crystal.gemstone!.metal}.",
                      Icons.diamond_outlined,
                    ),
                  if (crystal.mantra != null)
                    _buildRemedyCard(
                      "Mantra",
                      "${crystal.mantra!.mantra}\nJapa Count: ${crystal.mantra!.japaCount}",
                      Icons.spatial_audio_off_outlined,
                    ),
                  if (crystal.charity != null)
                    _buildRemedyCard(
                      "Charity",
                      "Donate ${crystal.charity!.items?.join(', ')} to ${crystal.charity!.donateTo} on ${crystal.charity!.bestDay}.",
                      Icons.volunteer_activism_outlined,
                    ),
                  if (crystal.fasting != null)
                    _buildRemedyCard(
                      "Fasting",
                      "${crystal.fasting!.fastingType} on ${crystal.fasting!.day}s. Duration: ${crystal.fasting!.duration}.",
                      Icons.restaurant_menu_outlined,
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildRemedyCard(String title, String desc, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(title, fontWeight: FontWeight.bold, fontSize: 14),
                const SizedBox(height: 2),
                AppText(desc, fontSize: 12, color: Colors.grey.shade600),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

