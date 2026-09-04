import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/routes/route_helper.dart';
import 'kundli_screen.dart';
import 'presentation/controllers/matching_controller.dart';
import 'data/models/matching_response_model.dart';

class KundliMatchScreen extends GetView<MatchingController> {
  const KundliMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> tabs = [
      'RESULTS',
      'DETAILS',
      'VARNA',
      'VASYA',
      'TARA',
      'YONI',
      'MAITRI',
      'GANA',
      'BHAKOOT',
      'NADI',
      'DOWNLOAD PDF',
      'BIRTH DETAILS',
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textColorPrimary,
            ),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: const Text('Match Result'.tr,
            style: TextStyle(
              color: AppColors.textColorPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: AppColors.textColorSecondary,
            indicatorColor: AppColors.primaryColor,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 13,
            ),
            tabs: tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryColor),
                  SizedBox(height: 16),
                  Text('Fetching Kundli Matching Details...'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColorSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          final matching = controller.matchingData.value;
          final data = matching?.data;

          return TabBarView(
            children: [
              _ResultsTab(data: data),
              _DetailsTab(data: data),
              _InterpretationTabWidget(
                title: 'Varna (Spiritual Compatibility)'.tr,
                detail: data?.gunaMilan.varna,
              ),
              _InterpretationTabWidget(
                title: 'Vasya (Mutual Attraction & Influence)'.tr,
                detail: data?.gunaMilan.vashya,
              ),
              _InterpretationTabWidget(
                title: 'Tara (Birth Star Harmony)'.tr,
                detail: data?.gunaMilan.tara,
              ),
              _InterpretationTabWidget(
                title: 'Yoni (Physical & Sexual Compatibility)'.tr,
                detail: data?.gunaMilan.yoni,
              ),
              _InterpretationTabWidget(
                title: 'Maitri (Mental & Intellectual Harmony)'.tr,
                detail: data?.gunaMilan.grahaMaitri,
              ),
              _InterpretationTabWidget(
                title: 'Gana (Temperament & Nature)'.tr,
                detail: data?.gunaMilan.gana,
              ),
              _InterpretationTabWidget(
                title: 'Bhakoot (Financial & Family Prosperity)'.tr,
                detail: data?.gunaMilan.bhakoot,
              ),
              _InterpretationTabWidget(
                title: 'Nadi (Health & Genetic Compatibility)'.tr,
                detail: data?.gunaMilan.nadi,
              ),
              const _DownloadPdfTab(),
              _BirthDetailsTab(data: data),
            ],
          );
        }),
      ),
    );
  }
}

// ===================== 1. RESULTS TAB =====================
class _ResultsTab extends StatelessWidget {
  final MatchingData? data;

  const _ResultsTab({this.data});

  @override
  Widget build(BuildContext context) {
    final score = data?.compatibilityScore ?? 0.0;
    final maxScore = data?.maxScore ?? 36;
    final verdict =
        data?.verdict.isNotEmpty == true
            ? data!.verdict
            : (score >= 18 ? 'Compatible Match' : 'Incompatible Match');
    final recommendation = data?.recommendation ?? '';

    final maleManglik = data?.doshas.manglik.male.present == true;
    final femaleManglik = data?.doshas.manglik.female.present == true;
    String mangalDoshaText = 'No Mangal Dosha detected.';
    if (maleManglik && femaleManglik) {
      mangalDoshaText = 'Both Boy and Girl are Manglik (Dosha Cancelled).';
    } else if (maleManglik) {
      mangalDoshaText = 'Boy has Mangal Dosha.';
    } else if (femaleManglik) {
      mangalDoshaText = 'Girl has Mangal Dosha.';
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ashtakoot Matching Points'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColorPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Score card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: AppColors.lightPink,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  alignment: Alignment.center,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: score.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        TextSpan(
                          text: ' /$maxScore',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColorSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  mangalDoshaText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColorPrimary,
                  ),
                ),
                const SizedBox(height: 20),

                // Upcoming Marriage Muhurat Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showMarriageMuhuratBottomSheet(context);
                    },
                    icon: const Icon(
                      Icons.calendar_month,
                      color: AppColors.white,
                      size: 20,
                    ),
                    label: const Text('Upcoming Marriage Muhurat'.tr,
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Conclusion Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.fieldBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('* Match Result Conclusion:'.tr,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        verdict,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColorPrimary,
                        ),
                      ),
                      if (recommendation.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          recommendation,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textColorSecondary,
                          ),
                        ),
                      ],
                      if (data?.summary.isNotEmpty == true) ...[
                        const SizedBox(height: 8),
                        Text(
                          data!.summary,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textColorSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Talk To Astrologers Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.offAllNamed(
                        RouteHelper.getDashboardRoute(),
                        arguments: {'index': 0},
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: const Text('Talk To Astrologers'.tr,
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ===================== 2. DETAILS TAB =====================
class _DetailsTab extends StatelessWidget {
  final MatchingData? data;

  const _DetailsTab({this.data});

  @override
  Widget build(BuildContext context) {
    final gunaMilan = data?.gunaMilan;

    final List<Map<String, dynamic>> gunaRows = [
      {
        'guna': 'Varna',
        'max': gunaMilan?.varna.max ?? 1,
        'obtained': (gunaMilan?.varna.score ?? 0).toDouble(),
        'area':
            '${gunaMilan?.varna.maleKootAttribute.isNotEmpty == true ? gunaMilan!.varna.maleKootAttribute : "N/A"} / ${gunaMilan?.varna.femaleKootAttribute.isNotEmpty == true ? gunaMilan!.varna.femaleKootAttribute : "N/A"}',
      },
      {
        'guna': 'Vasya',
        'max': gunaMilan?.vashya.max ?? 2,
        'obtained': (gunaMilan?.vashya.score ?? 0).toDouble(),
        'area':
            '${gunaMilan?.vashya.maleKootAttribute.isNotEmpty == true ? gunaMilan!.vashya.maleKootAttribute : "N/A"} / ${gunaMilan?.vashya.femaleKootAttribute.isNotEmpty == true ? gunaMilan!.vashya.femaleKootAttribute : "N/A"}',
      },
      {
        'guna': 'Tara',
        'max': gunaMilan?.tara.max ?? 3,
        'obtained': (gunaMilan?.tara.score ?? 0).toDouble(),
        'area':
            '${gunaMilan?.tara.maleKootAttribute.isNotEmpty == true ? gunaMilan!.tara.maleKootAttribute : "N/A"} / ${gunaMilan?.tara.femaleKootAttribute.isNotEmpty == true ? gunaMilan!.tara.femaleKootAttribute : "N/A"}',
      },
      {
        'guna': 'Yoni',
        'max': gunaMilan?.yoni.max ?? 4,
        'obtained': (gunaMilan?.yoni.score ?? 0).toDouble(),
        'area':
            '${gunaMilan?.yoni.maleKootAttribute.isNotEmpty == true ? gunaMilan!.yoni.maleKootAttribute : "N/A"} / ${gunaMilan?.yoni.femaleKootAttribute.isNotEmpty == true ? gunaMilan!.yoni.femaleKootAttribute : "N/A"}',
      },
      {
        'guna': 'Maitri',
        'max': gunaMilan?.grahaMaitri.max ?? 5,
        'obtained': (gunaMilan?.grahaMaitri.score ?? 0).toDouble(),
        'area':
            '${gunaMilan?.grahaMaitri.maleKootAttribute.isNotEmpty == true ? gunaMilan!.grahaMaitri.maleKootAttribute : "N/A"} / ${gunaMilan?.grahaMaitri.femaleKootAttribute.isNotEmpty == true ? gunaMilan!.grahaMaitri.femaleKootAttribute : "N/A"}',
      },
      {
        'guna': 'Gana',
        'max': gunaMilan?.gana.max ?? 6,
        'obtained': (gunaMilan?.gana.score ?? 0).toDouble(),
        'area':
            '${gunaMilan?.gana.maleKootAttribute.isNotEmpty == true ? gunaMilan!.gana.maleKootAttribute : "N/A"} / ${gunaMilan?.gana.femaleKootAttribute.isNotEmpty == true ? gunaMilan!.gana.femaleKootAttribute : "N/A"}',
      },
      {
        'guna': 'Bhakoot',
        'max': gunaMilan?.bhakoot.max ?? 7,
        'obtained': (gunaMilan?.bhakoot.score ?? 0).toDouble(),
        'area':
            '${gunaMilan?.bhakoot.maleKootAttribute.isNotEmpty == true ? gunaMilan!.bhakoot.maleKootAttribute : "N/A"} / ${gunaMilan?.bhakoot.femaleKootAttribute.isNotEmpty == true ? gunaMilan!.bhakoot.femaleKootAttribute : "N/A"}',
      },
      {
        'guna': 'Nadi',
        'max': gunaMilan?.nadi.max ?? 8,
        'obtained': (gunaMilan?.nadi.score ?? 0).toDouble(),
        'area':
            '${gunaMilan?.nadi.maleKootAttribute.isNotEmpty == true ? gunaMilan!.nadi.maleKootAttribute : "N/A"} / ${gunaMilan?.nadi.femaleKootAttribute.isNotEmpty == true ? gunaMilan!.nadi.femaleKootAttribute : "N/A"}',
      },
    ];

    final totalScore = data?.compatibilityScore ?? 0.0;
    final maxScore = data?.maxScore ?? 36;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Guna Milan Result in Detail'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textColorPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Data Table
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.2),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1.1),
                  3: FlexColumnWidth(1.6),
                },
                children: [
                  const TableRow(
                    decoration: BoxDecoration(color: AppColors.softPink),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 8,
                        ),
                        child: Text('Guna'.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 8,
                        ),
                        child: Text('Maximum'.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 8,
                        ),
                        child: Text('Obtained'.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 8,
                        ),
                        child: Text('Attributes (B/G)'.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...gunaRows.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return TableRow(
                      decoration: BoxDecoration(
                        color:
                            index.isOdd
                                ? AppColors.fieldBackground
                                : AppColors.white,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 8,
                          ),
                          child: Text(
                            item['guna'].toString(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColorPrimary,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 8,
                          ),
                          child: Text(
                            item['max'].toString(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textColorPrimary,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 8,
                          ),
                          child: Text(
                            (item['obtained'] as double).toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 8,
                          ),
                          child: Text(
                            item['area'].toString(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textColorSecondary,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Total Score Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.lightPink,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            alignment: Alignment.center,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: totalScore.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  TextSpan(
                    text: ' /$maxScore',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColorSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable Dynamic Interpretation Tab Widget
class _InterpretationTabWidget extends StatelessWidget {
  final String title;
  final GunaDetail? detail;

  const _InterpretationTabWidget({required this.title, this.detail});

  @override
  Widget build(BuildContext context) {
    final score = detail?.score ?? 0;
    final max = detail?.max ?? 0;
    final description =
        detail?.description.isNotEmpty == true
            ? detail!.description
            : 'Interpretation data for this guna is being processed.';
    final significance = detail?.significance ?? '';
    final tips = detail?.tips ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColorPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightPink,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Text(
                  'Score: $score / $max',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: AppColors.textColorPrimary,
                  ),
                ),
                if (detail?.maleKootAttribute.isNotEmpty == true ||
                    detail?.femaleKootAttribute.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.borderColor),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Boy's Attribute",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColorSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              detail?.maleKootAttribute ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColorPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 1,
                        color: AppColors.borderColor,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Girl's Attribute",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColorSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              detail?.femaleKootAttribute ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColorPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                if (significance.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Text('Astrological Significance:'.tr,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    significance,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: AppColors.textColorSecondary,
                    ),
                  ),
                ],
                if (tips.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Text('Key Recommendations & Tips:'.tr,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...tips.map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• '.tr,
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              tip,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textColorPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== 11. DOWNLOAD PDF TAB =====================
class _DownloadPdfTab extends StatelessWidget {
  const _DownloadPdfTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text('Download your detailed Horoscope Matching PDF report for printing, sharing on email, or WhatsApp.'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppColors.textColorPrimary,
            ),
          ),
          const SizedBox(height: 30),

          // Download PDF button
          ElevatedButton.icon(
            onPressed: () => _generateAndShareKundliPdf(context),
            icon: const Icon(
              Icons.file_download_outlined,
              color: AppColors.white,
            ),
            label: const Text('Download PDF'.tr,
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== 12. BIRTH DETAILS TAB =====================
class _BirthDetailsTab extends StatelessWidget {
  final MatchingData? data;

  const _BirthDetailsTab({this.data});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MatchingController>();

    final maleNakshatra =
        data?.maleInfo?.moonNakshatra.isNotEmpty == true
            ? data!.maleInfo!.moonNakshatra
            : (data?.gunaMilan.tara.maleKootAttribute.isNotEmpty == true
                ? data!.gunaMilan.tara.maleKootAttribute
                : 'Ardra');
    final maleSign =
        data?.maleInfo?.moonSign.isNotEmpty == true
            ? data!.maleInfo!.moonSign
            : (data?.gunaMilan.bhakoot.maleKootAttribute.isNotEmpty == true
                ? data!.gunaMilan.bhakoot.maleKootAttribute
                : 'Gemini');
    final femaleNakshatra =
        data?.femaleInfo?.moonNakshatra.isNotEmpty == true
            ? data!.femaleInfo!.moonNakshatra
            : (data?.gunaMilan.tara.femaleKootAttribute.isNotEmpty == true
                ? data!.gunaMilan.tara.femaleKootAttribute
                : 'Purva Phalguni');
    final femaleSign =
        data?.femaleInfo?.moonSign.isNotEmpty == true
            ? data!.femaleInfo!.moonSign
            : (data?.gunaMilan.bhakoot.femaleKootAttribute.isNotEmpty == true
                ? data!.gunaMilan.bhakoot.femaleKootAttribute
                : 'Leo');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPersonCard(
            title: "BOY'S DETAILS",
            name: controller.boyName,
            dob: controller.boyDobRaw,
            tob: controller.boyTobRaw,
            place: controller.boyPlace,
            nakshatra: maleNakshatra,
            rashi: maleSign,
            buttonLabel: "VIEW BOY'S KUNDLI",
            onTap: () {
              Get.to(
                () => KundliScreen(
                  fullName: controller.boyName,
                  gender: controller.boyGender,
                  dob: controller.boyDobRaw,
                  tob: controller.boyTobRaw,
                  place: controller.boyPlace,
                  latitude: controller.boyLatVal,
                  longitude: controller.boyLngVal,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildPersonCard(
            title: "GIRL'S DETAILS",
            name: controller.girlName,
            dob: controller.girlDobRaw,
            tob: controller.girlTobRaw,
            place: controller.girlPlace,
            nakshatra: femaleNakshatra,
            rashi: femaleSign,
            buttonLabel: "VIEW GIRL'S KUNDLI",
            onTap: () {
              Get.to(
                () => KundliScreen(
                  fullName: controller.girlName,
                  gender: controller.girlGender,
                  dob: controller.girlDobRaw,
                  tob: controller.girlTobRaw,
                  place: controller.girlPlace,
                  latitude: controller.girlLatVal,
                  longitude: controller.girlLngVal,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPersonCard({
    required String title,
    required String name,
    required String dob,
    required String tob,
    required String place,
    required String nakshatra,
    required String rashi,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1.5,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: AppColors.textColorPrimary,
                  fontSize: 13.5,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(
                    text: 'Name: '.tr,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: '$name\n'),
                  const TextSpan(
                    text: 'Birth Date: '.tr,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: '$dob\n'),
                  const TextSpan(
                    text: 'Birth Time: '.tr,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: '$tob\n'),
                  const TextSpan(
                    text: 'Birth Place: '.tr,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: '$place\n'),
                  const TextSpan(
                    text: 'Moon Sign (Rashi): '.tr,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: '$rashi\n'),
                  const TextSpan(
                    text: 'Moon Nakshatra: '.tr,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: nakshatra),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  buttonLabel,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showMarriageMuhuratBottomSheet(BuildContext context) {
  final now = DateTime.now();
  final monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final monthAbbr = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  // Calculate upcoming 4 months dynamically from today
  final List<Map<String, String>> dynamicMuhurats = [];
  final sampleDatesPattern = [
    '04, 07, 12, 18, 22, 25',
    '02, 06, 09, 14, 19, 27',
    '05, 08, 11, 16, 21, 28',
    '03, 10, 15, 20, 24, 29',
  ];

  for (int i = 0; i < 4; i++) {
    final futureDate = DateTime(now.year, now.month + i, 1);
    final monthName = '${monthNames[futureDate.month - 1]} ${futureDate.year}';
    final abbr = monthAbbr[futureDate.month - 1];
    final datesStr =
        '${sampleDatesPattern[i % sampleDatesPattern.length]} $abbr';
    dynamicMuhurats.add({'month': monthName, 'dates': datesStr});
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      color: AppColors.primaryColor,
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Text('Upcoming Marriage Muhurats'.tr,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.textColorSecondary,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(color: AppColors.borderColor),
            const SizedBox(height: 10),

            ...dynamicMuhurats.map(
              (m) => _buildMuhuratTile(m['month']!, m['dates']!),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Get.toNamed(RouteHelper.getPanchangRoute());
                },
                icon: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.white,
                  size: 18,
                ),
                label: const Text('VIEW DAILY PANCHANG & SHUBH MUHURAT'.tr,
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}

Widget _buildMuhuratTile(String month, String dates) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.lightPink,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.favorite,
            color: AppColors.primaryColor,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                month,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColorPrimary,
                ),
              ),
              Text(
                'Auspicious Dates: $dates',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textColorSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Future<void> _generateAndShareKundliPdf(BuildContext context) async {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('PDF generation is coming soon'.tr)),
  );
}
