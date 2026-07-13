import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import 'package:astro_astrologer/features/kundli/kundli_chart_widget.dart';
import 'package:astro_astrologer/features/kundli/kundli_list_screen.dart';
import 'package:astro_astrologer/features/chat/presentation/pages/chat_screen.dart';
import 'kundli_tabs/shad_bala_tab.dart';
import 'kundli_tabs/bhav_bala_tab.dart';
import 'kundli_tabs/manglik_report_tab.dart';
import 'kundli_tabs/divisional_chart_tab.dart';
import 'kundli_tabs/kp_tab.dart';
import 'kundli_tabs/sade_sati_tab.dart';
import 'create_kundli_screen.dart';
import 'controllers/panchang_controller.dart';
import 'controllers/dasha_controller.dart';
import 'controllers/ashtakvarga_controller.dart';
import 'controllers/planet_positions_controller.dart';
import 'controllers/shadbala_controller.dart';
import 'controllers/remedies_controller.dart';
import 'package:collection/collection.dart';

class KundliScreen extends StatefulWidget {
  const KundliScreen({super.key});

  @override
  State<KundliScreen> createState() => _KundliScreenState();
}

class _KundliScreenState extends State<KundliScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PanchangController _panchangController = Get.put(PanchangController());
  final DashaController _dashaController = Get.put(DashaController());
  final AshtakvargaController _ashtakvargaController = Get.put(AshtakvargaController());
  final PlanetPositionsController _planetPositionsController = Get.put(PlanetPositionsController());
  final ShadbalaController _shadbalaController = Get.put(ShadbalaController());
  final RemediesController _remediesController = Get.put(RemediesController());
  final List<String> _tabs = [
    "Basic",
    "Lagna",
    "Navamsa",
    "Transit",
    "Dasha",
    "Yogini Dasha",
    "Ashtakvarga",
    "Planets",
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _panchangController.fetchPanchangDetails();
    _dashaController.fetchDashaDetails();
    _dashaController.fetchYoginiDashaDetails();
    _ashtakvargaController.fetchAshtakvargaDetails();
    _planetPositionsController.fetchPlanetPositions();
    _shadbalaController.fetchShadbalaDetails();
    _remediesController.fetchGemstoneRemedies();
  }

  final Map<int, List<String>> _samplePlanetData = {
    1: ["Ju", "Me"],
    4: ["Ma"],
    7: ["Sa", "Ra"],
    9: ["Su", "Ke"],
    10: ["Ve", "Mo"],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF9F5), // Premium Ivory/Off-white
      appBar: CustomAppBar(
        title: 'Kundli',
        actions: [
          GestureDetector(
            onTap: () => Get.to(() => const KundliListScreen()),
            child: const Icon(Icons.add, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => Get.to(() => const ChatScreen(
              userName: 'Chat with Astrologer',
              userImage: 'https://randomuser.me/api/portraits/men/32.jpg',
              sessionId: 888, // dummy
              initialStatus: 'ongoing',
            )),
            child: const Icon(Iconsax.message_2_copy, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          _buildTopTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBasicTab(),
                KundliChartWidget(title: "Lagna / Ascendant / D1 Chart", planetData: _samplePlanetData),
                KundliChartWidget(title: "Navamsa Chart", planetData: _samplePlanetData),
                KundliChartWidget(title: "Transit Chart", planetData: _samplePlanetData),
                _buildDashaTab("Mahadasha"),
                _buildDashaTab("Yogini Dasha"),
                _buildAshtakvargaTab(),
                _buildPlanetsTab(),
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
          _buildGemstoneRecommendation(),
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
      child: Column(
        children: [
          _buildInfoRow("Name", "Utkarsha", true),
          _buildInfoRow("Date of Birth", "05 July 1994", true),
          _buildInfoRow("Time", "08:13 PM", true),
          _buildInfoRow("Place", "New Delhi, Delhi, India", true),
          _buildInfoRow("Latitude", "28.65", false),
          _buildInfoRow("Longitude", "77.23", false),
          _buildInfoRow("Timezone", "GMT+5.5", false),
          _buildInfoRow("Sunrise", "5:28:30 AM", false),
          _buildInfoRow("Sunset", "7:23:12 PM", false),
          _buildInfoRow("Ayanamsha", "23.78038", false),
        ],
      ),
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
      child: Column(
        children: [
          _buildInfoRow("Varna", "Brahmin", false),
          _buildInfoRow("Vashya", "Chatushpad", false),
          _buildInfoRow("Yoni", "Go", false),
          _buildInfoRow("Gan", "Dev", false),
          _buildInfoRow("Nadi", "Antya", false),
          _buildInfoRow("Sign", "Taurus", false),
          _buildInfoRow("Sign Lord", "Venus", false),
        ],
      ),
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
          if (showEdit) 
            GestureDetector(
              onTap: () {
                Get.to(() => const CreateKundliScreen(
                  hideMatchingTab: true,
                  initialKundliData: {
                    'name': 'Utkarsha',
                    'dob': '05 July 1994',
                    'time': '08:13 PM',
                    'place': 'New Delhi, Delhi, India',
                    'gender': 'Male',
                  }
                ));
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
                child: Icon(Icons.edit, size: 15, color: Colors.black.withOpacity(0.6)),
              ),
            ),
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

    if (title == "Yogini Dasha") {
      return Obx(() {
        if (_dashaController.isYoginiLoading.value) {
          return const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
          );
        }

        final dashaDataList = _dashaController.yoginiDashaModel.value?.data?.mahadashas;
        if (dashaDataList == null || dashaDataList.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(child: AppText("Failed to load Yogini Dasha details.")),
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
                          Expanded(child: AppText("Yogini", fontWeight: FontWeight.bold, fontSize: 12)),
                          Expanded(child: AppText("Start Date", fontWeight: FontWeight.bold, fontSize: 12)),
                          Expanded(child: AppText("End Date", fontWeight: FontWeight.bold, fontSize: 12)),
                          SizedBox(width: 20),
                        ],
                      ),
                    ),
                    ...dashaDataList.map((data) {
                      String start = (data.startDate ?? "N/A").split('T')[0];
                      String end = (data.endDate ?? "N/A").split('T')[0];
                      return _buildDashaRow(
                        data.yogini ?? "N/A",
                        start,
                        end,
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

  Widget _buildPlanetsTab() {
    return Obx(() {
      if (_planetPositionsController.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
        );
      }

      final planetsList = _planetPositionsController.planetPositionsModel.value?.data?.planets;
      if (planetsList == null || planetsList.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: AppText("Failed to load Planet Positions.")),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
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
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: AppText("Planet", fontWeight: FontWeight.bold, fontSize: 12)),
                    Expanded(flex: 2, child: AppText("Sign", fontWeight: FontWeight.bold, fontSize: 12)),
                    Expanded(flex: 3, child: AppText("Degree", fontWeight: FontWeight.bold, fontSize: 12)),
                    Expanded(flex: 3, child: AppText("Nakshatra", fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
              ...planetsList.map((data) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: AppText(data.name ?? "N/A", fontSize: 11)),
                    Expanded(flex: 2, child: AppText(data.sign ?? "N/A", fontSize: 11)),
                    Expanded(flex: 3, child: AppText(data.normDegree != null ? _formatDegree(data.normDegree!) : "N/A", fontSize: 11)),
                    Expanded(flex: 3, child: AppText(data.nakshatra?.name ?? "N/A", fontSize: 11)),
                  ],
                ),
              )),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAshtakvargaTab() {
    return Obx(() {
      if (_ashtakvargaController.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
        );
      }

      final bhinnashtakavarga = _ashtakvargaController.ashtakvargaModel.value?.data?.bhinnashtakavarga;
      if (bhinnashtakavarga == null || bhinnashtakavarga.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: AppText("Failed to load Ashtakvarga details.")),
        );
      }

      final signs = ["Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo", "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"];
      final signShorts = ["Ari", "Tau", "Gem", "Can", "Leo", "Vir", "Lib", "Sco", "Sag", "Cap", "Aqu", "Pis"];
      final planets = ["Sun", "Moon", "Mars", "Mercury", "Jupiter", "Venus", "Saturn"];

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: DataTable(
              columnSpacing: 15,
              horizontalMargin: 0,
              headingRowHeight: 35,
              dataRowMinHeight: 30,
              dataRowMaxHeight: 40,
              columns: [
                const DataColumn(label: AppText("Planet", fontWeight: FontWeight.bold, fontSize: 12)),
                ...signShorts.map((s) => DataColumn(label: AppText(s, fontWeight: FontWeight.bold, fontSize: 12))),
              ],
              rows: planets.map((p) {
                final planetData = bhinnashtakavarga[p];
                return DataRow(
                  cells: [
                    DataCell(AppText(p, fontSize: 11)),
                    ...signs.map((signName) {
                      String pointsStr = "0";
                      if (planetData != null && planetData.strongSigns != null) {
                        final signMatch = planetData.strongSigns!.firstWhereOrNull((s) => s.sign == signName);
                        if (signMatch != null) {
                          pointsStr = signMatch.points?.toString() ?? "0";
                        }
                      }
                      return DataCell(AppText(pointsStr, fontSize: 11));
                    }),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildKPSystemTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
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
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(flex: 2, child: AppText("Planet", fontWeight: FontWeight.bold, fontSize: 12)),
                  Expanded(flex: 3, child: AppText("Sign Lord", fontWeight: FontWeight.bold, fontSize: 12)),
                  Expanded(flex: 3, child: AppText("Star Lord", fontWeight: FontWeight.bold, fontSize: 12)),
                  Expanded(flex: 2, child: AppText("Sub Lord", fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
            ...["Sun", "Moon", "Mars", "Merc", "Jup", "Ven", "Sat"].map((p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(flex: 2, child: AppText(p, fontSize: 11)),
                  Expanded(flex: 3, child: AppText("Jupiter", fontSize: 11)),
                  Expanded(flex: 3, child: AppText("Rahu", fontSize: 11)),
                  Expanded(flex: 2, child: AppText("Mars", fontSize: 11)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildVarshphalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(
            height: 300,
            child: KundliChartWidget(title: "Varshphal Chart - Year 2026"),
          ),
          const SizedBox(height: 20),
          _buildVarshphalInfoGrid(),
          const SizedBox(height: 20),
          _buildMuddaDashaTable(),
          const SizedBox(height: 20),
          _buildPanchaVargeeyaBalaTable(),
        ],
      ),
    );
  }

  Widget _buildVarshphalInfoGrid() {
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
          _buildInfoRow("Muntha", "Libra", false),
          _buildInfoRow("Year Lord", "Saturn", false),
          _buildInfoRow("Muntha Lord", "Venus", false),
          _buildInfoRow("Ascendant Lord", "Mercury", false),
          _buildInfoRow("Tithi", "Shukla-Navami", false),
          _buildInfoRow("Yoga", "Dhriti", false),
          _buildInfoRow("Karana", "Kaulava", false),
          _buildInfoRow("Dina Lord", "Friday", false),
        ],
      ),
    );
  }

  Widget _buildMuddaDashaTable() {
    final muddaData = [
      ["Sun", "10-Feb-2026", "28-Feb-2026"],
      ["Moon", "28-Feb-2026", "31-Mar-2026"],
      ["Mars", "31-Mar-2026", "21-Apr-2026"],
      ["Rahu", "21-Apr-2026", "15-Jun-2026"],
      ["Jupiter", "15-Jun-2026", "02-Aug-2026"],
      ["Saturn", "02-Aug-2026", "29-Sep-2026"],
    ];

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
          ...muddaData.map((data) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(child: AppText(data[0], fontSize: 12)),
                Expanded(child: AppText(data[1], fontSize: 12)),
                Expanded(child: AppText(data[2], fontSize: 12)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPanchaVargeeyaBalaTable() {
    final balaData = [
      ["Sun", "15.2", "12.4", "18.1", "11.5", "57.2"],
      ["Moon", "12.1", "10.2", "14.5", "10.1", "46.9"],
      ["Mars", "10.5", "9.8", "12.2", "8.9", "41.4"],
      ["Merc", "18.4", "15.2", "20.1", "14.5", "68.2"],
      ["Jup", "14.1", "11.2", "16.5", "12.1", "53.9"],
      ["Ven", "16.8", "13.4", "19.2", "13.8", "63.2"],
      ["Sat", "11.2", "9.5", "13.1", "10.2", "44.0"],
    ];

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
                DataColumn(label: AppText("Ksh", fontWeight: FontWeight.bold, fontSize: 12)),
                DataColumn(label: AppText("Dre", fontWeight: FontWeight.bold, fontSize: 12)),
                DataColumn(label: AppText("Nav", fontWeight: FontWeight.bold, fontSize: 12)),
                DataColumn(label: AppText("Hor", fontWeight: FontWeight.bold, fontSize: 12)),
                DataColumn(label: AppText("Total", fontWeight: FontWeight.bold, fontSize: 12)),
              ],
              rows: balaData.map((data) => DataRow(
                cells: [
                  DataCell(AppText(data[0], fontSize: 12)),
                  DataCell(AppText(data[1], fontSize: 12)),
                  DataCell(AppText(data[2], fontSize: 12)),
                  DataCell(AppText(data[3], fontSize: 12)),
                  DataCell(AppText(data[4], fontSize: 12)),
                  DataCell(AppText(data[5], fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivisionalChartTab() {
    return const DivisionalChartTab();
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

  Widget _buildGemstoneRecommendation() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText("Recommended gemstone based on user's kundli.", fontSize: 11, fontWeight: FontWeight.w500),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppColors.primaryColor, width: 1.2),
                ),
                child: const Icon(Icons.diamond, color: AppColors.primaryColor, size: 22),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText("Emerald", fontSize: 13, fontWeight: FontWeight.bold),
                  SizedBox(height: 1),
                  AppText("Emerald (Career Growth)", fontSize: 10, color: Colors.black54),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
