import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:astro_astrologer/features/panchang/data/models/panchang_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import 'presentation/controllers/panchang_controller.dart';

class PanchangScreen extends GetView<PanchangController> {
  const PanchangScreen({super.key});

  Future<void> _selectDate(BuildContext context) async {
    await controller.pickDate(context);
  }

  @override
  Widget build(BuildContext context) {
    print('[PCB_APP] [DEBUG] PanchangScreen build called');
    return Scaffold(
      backgroundColor: const Color(0xFFFDF9F5),
      appBar: const CustomAppBar(title: 'Panchang'),
      body: Column(
        children: [
          _buildCalendarSection(),
          Expanded(
            child: Obx(() {
              print(
                '[PCB_APP] [DEBUG] Obx rebuild - isLoading: ${controller.isLoading.value}',
              );
              print(
                '[PCB_APP] [DEBUG] Obx rebuild - panchangData null: ${controller.panchangData.value == null}',
              );

              if (controller.isLoading.value) {
                print('[PCB_APP] [DEBUG] Showing shimmer loading indicator');
                return _buildShimmerLoading();
              }

              if (controller.panchangData.value == null) {
                print('[PCB_APP] [DEBUG] Showing no data message');
                return Center(
                  child: AppText(
                    controller.errorMessage.value.isEmpty
                        ? 'No data available'.tr
                        : controller.errorMessage.value,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                );
              }

              print('[PCB_APP] [DEBUG] Showing panchang data');
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGuidanceSection(
                      controller.panchangData.value!.data.guidance,
                    ),
                    _buildSunMoonSection(),
                    const SizedBox(height: 16),
                    _buildCorePanchangSection(),
                    const SizedBox(height: 24),
                    _buildMuhurtaSection(
                      "Shubh Muhurta",
                      _getAuspiciousTimings(),
                      Colors.green,
                    ),
                    const SizedBox(height: 16),
                    _buildMuhurtaSection(
                      "Ashubh Muhurta",
                      _getInauspiciousTimings(),
                      Colors.red,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Obx(
        () => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        "${DateFormat('MMMM').format(controller.selectedDate.value).tr} ${DateFormat('yyyy').format(controller.selectedDate.value)}",
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2E1A47),
                      ),
                      AppText(
                        "${DateFormat('EEEE').format(controller.selectedDate.value).tr}, ${DateFormat('dd').format(controller.selectedDate.value)} ${DateFormat('MMM').format(controller.selectedDate.value).tr}",
                        fontSize: 13,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          controller.showFullCalendar.value
                              ? Iconsax.arrow_up_2_copy
                              : Iconsax.calendar_copy,
                          color: AppColors.primaryColor,
                        ),
                        onPressed: controller.toggleCalendar,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (controller.showFullCalendar.value)
              SizedBox(
                height: 300,
                child: CalendarDatePicker(
                  initialDate: controller.selectedDate.value,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                  onDateChanged: controller.selectDate,
                ),
              )
            else
              _buildDateStrip(),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildDateStrip() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        controller: controller.scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 30,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index - 5));
          final isSelected =
              date.day == controller.selectedDate.value.day &&
              date.month == controller.selectedDate.value.month &&
              date.year == controller.selectedDate.value.year;

          return GestureDetector(
            onTap: () => controller.selectDate(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 55,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                gradient:
                    isSelected
                        ? LinearGradient(
                          colors: [
                            AppColors.primaryColor,
                            AppColors.primaryColor.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                        : null,
                color: isSelected ? null : const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(18),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(
                    DateFormat('EEE').format(date).toUpperCase().tr,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white70 : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    date.day.toString(),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : const Color(0xFF2E1A47),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSunMoonSection() {
    final data = controller.panchangData.value?.data;
    print(
      '[PCB_APP] [DEBUG] _buildSunMoonSection - data null: ${data == null}',
    );
    if (data == null) return const SizedBox.shrink();

    // Hide Sun & Moon timing section if they are all empty
    if (data.sunrise.isEmpty &&
        data.sunset.isEmpty &&
        data.moonrise.isEmpty &&
        data.moonset.isEmpty) {
      return const SizedBox.shrink();
    }

    print('[PCB_APP] [DEBUG] Sunrise: ${data.sunrise}, Sunset: ${data.sunset}');

    return Row(
      children: [
        if (data.sunrise.isNotEmpty || data.sunset.isNotEmpty)
          Expanded(
            child: _buildTimingCard(
              title: "Sun Timings",
              items: [
                if (data.sunrise.isNotEmpty)
                  {
                    "label": "Sunrise",
                    "time": controller.formatTime(data.sunrise),
                    "icon": Icons.wb_sunny_rounded,
                    "color": Colors.orange,
                  },
                if (data.sunset.isNotEmpty)
                  {
                    "label": "Sunset",
                    "time": controller.formatTime(data.sunset),
                    "icon": Icons.wb_twilight_rounded,
                    "color": Colors.deepOrange,
                  },
              ],
            ),
          ),
        if ((data.sunrise.isNotEmpty || data.sunset.isNotEmpty) &&
            (data.moonrise.isNotEmpty || data.moonset.isNotEmpty))
          const SizedBox(width: 12),
        if (data.moonrise.isNotEmpty || data.moonset.isNotEmpty)
          Expanded(
            child: _buildTimingCard(
              title: "Moon Timings",
              items: [
                if (data.moonrise.isNotEmpty)
                  {
                    "label": "Moonrise",
                    "time": controller.formatTime(data.moonrise),
                    "icon": Icons.nightlight_round,
                    "color": Colors.blueGrey,
                  },
                if (data.moonset.isNotEmpty)
                  {
                    "label": "Moonset",
                    "time": controller.formatTime(data.moonset),
                    "icon": Icons.mode_night_rounded,
                    "color": Colors.indigo,
                  },
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTimingCard({
    required String title,
    required List<Map<String, dynamic>> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            title,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(item['icon'], size: 16, color: item['color']),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(item['label'], fontSize: 11, color: Colors.grey),
                      AppText(
                        item['time'],
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidanceSection(GuidanceInfo guidance) {
    if (guidance.summary.isEmpty) return const SizedBox.shrink();

    Color badgeColor = Colors.orange;
    if (guidance.overallAuspiciousness.toLowerCase() == 'excellent') {
      badgeColor = Colors.green;
    } else if (guidance.overallAuspiciousness.toLowerCase() == 'good') {
      badgeColor = Colors.teal;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: Colors.orangeAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: AppText(
                  "Daily Cosmic Guidance",
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (guidance.overallAuspiciousness.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: badgeColor.withOpacity(0.3)),
                  ),
                  child: AppText(
                    guidance.overallAuspiciousness,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          AppText(
            guidance.summary,
            fontSize: 13,
            color: Colors.black87,
            height: 1.4,
          ),
          if (guidance.bestActivities.isNotEmpty) ...[
            const SizedBox(height: 16),
            AppText(
              "Best Activities Today:".tr,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  guidance.bestActivities
                      .map(
                        (act) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: AppText(
                            act,
                            fontSize: 11,
                            color: Colors.green.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
          if (guidance.activitiesToAvoid.isNotEmpty) ...[
            const SizedBox(height: 16),
            AppText(
              "Activities to Avoid:".tr,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  guidance.activitiesToAvoid
                      .map(
                        (act) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: AppText(
                            act,
                            fontSize: 11,
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
          if (guidance.tips.isNotEmpty) ...[
            const SizedBox(height: 16),
            AppText(
              "Daily Tips:".tr,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            ...guidance.tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 14,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppText(tip, fontSize: 12, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCorePanchangSection() {
    final data = controller.panchangData.value?.data;
    if (data == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: AppText(
            'Panchang Components'.tr,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Tithi Card
        _buildPanchangCard(
          title: "TITHI",
          subtitle:
              data.tithi.endTime.isNotEmpty
                  ? "Upto ${controller.formatTime(data.tithi.endTime)}"
                  : (data.tithi.paksha.name.isNotEmpty
                      ? "${data.tithi.paksha.name} Paksha"
                      : ""),
          name: data.tithi.name,
          deity: data.tithi.deity,
          meaning: data.tithi.interpretation.meaning,
          energy: data.tithi.interpretation.energy,
          tip: data.tithi.interpretation.tip,
          bestFor: data.tithi.interpretation.bestFor,
          avoid: data.tithi.interpretation.avoid,
          progress: data.tithi.completionPercentage,
        ),

        // Nakshatra Card
        _buildPanchangCard(
          title: "NAKSHATRA",
          subtitle:
              data.nakshatra.endTime.isNotEmpty
                  ? "Upto ${controller.formatTime(data.nakshatra.endTime)}"
                  : (data.nakshatra.gana.isNotEmpty
                      ? "Gana: ${data.nakshatra.gana}"
                      : ""),
          name:
              data.nakshatra.name +
              (data.nakshatra.pada > 0 ? " (Pada ${data.nakshatra.pada})" : ""),
          deity: data.nakshatra.deity,
          meaning: data.nakshatra.interpretation.meaning,
          energy: data.nakshatra.interpretation.energy,
          tip: data.nakshatra.interpretation.tip,
          bestFor: data.nakshatra.interpretation.bestFor,
          avoid: data.nakshatra.interpretation.avoid,
          progress: data.nakshatra.completionPercentage,
        ),

        // Yoga Card
        _buildPanchangCard(
          title: "YOGA",
          subtitle:
              data.yoga.endTime.isNotEmpty
                  ? "Upto ${controller.formatTime(data.yoga.endTime)}"
                  : data.yoga.quality,
          name: data.yoga.name,
          deity: "",
          meaning: data.yoga.interpretation.meaning,
          energy: data.yoga.interpretation.effect,
          tip: data.yoga.interpretation.guidance,
          progress: data.yoga.completionPercentage,
        ),

        // Karana Card
        _buildPanchangCard(
          title: "KARANA",
          subtitle:
              data.karana.endTime.isNotEmpty
                  ? "Upto ${controller.formatTime(data.karana.endTime)}"
                  : data.karana.type,
          name: data.karana.name,
          deity: "",
          meaning: data.karana.interpretation.meaning,
          energy:
              data.karana.interpretation.nature.isNotEmpty
                  ? "Nature: ${data.karana.interpretation.nature}"
                  : "",
          tip: data.karana.interpretation.tip,
          bestFor: data.karana.interpretation.bestFor,
          avoid: data.karana.interpretation.avoid,
          progress: data.karana.completionPercentage,
        ),

        // Vara Card
        _buildPanchangCard(
          title: "VARA",
          subtitle: data.vara.englishName,
          name: data.vara.name,
          deity: data.vara.lord,
          meaning: data.vara.interpretation.meaning,
          energy: data.vara.interpretation.energy,
          tip: data.vara.interpretation.tip,
          bestFor: data.vara.interpretation.bestFor,
          avoid: data.vara.interpretation.avoid,
        ),

        // Masa Card
        if (data.masa != null) _buildMasaCard(data.masa!),

        // Ritu Card
        if (data.ritu != null) _buildRituCard(data.ritu!),

        // Disha Shool Card
        if (data.dishaShool != null) _buildDishaShoolCard(data.dishaShool!),
      ],
    );
  }

  Widget _buildPanchangCard({
    required String title,
    required String subtitle,
    required String name,
    required String deity,
    required String meaning,
    required String energy,
    required String tip,
    List<String>? bestFor,
    List<String>? avoid,
    double? progress,
  }) {
    Color themeColor = AppColors.primaryColor;
    IconData cardIcon = Icons.auto_awesome;
    if (title.toUpperCase().contains("TITHI")) {
      themeColor = const Color(0xFFE05275);
      cardIcon = Icons.nightlight_round;
    } else if (title.toUpperCase().contains("NAKSHATRA")) {
      themeColor = const Color(0xFF5B3E96);
      cardIcon = Icons.star_rounded;
    } else if (title.toUpperCase().contains("YOGA")) {
      themeColor = const Color(0xFFD4AF37);
      cardIcon = Icons.all_inclusive;
    } else if (title.toUpperCase().contains("KARANA")) {
      themeColor = const Color(0xFF0F9D58);
      cardIcon = Icons.waves;
    } else if (title.toUpperCase().contains("VARA")) {
      themeColor = const Color(0xFFE28743);
      cardIcon = Icons.today;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF5EFE6), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E1A47).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(cardIcon, size: 14, color: themeColor),
                      const SizedBox(width: 6),
                      AppText(
                        title.tr,
                        fontSize: 11,
                        color: themeColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ],
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: AppText(
                      subtitle.tr,
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),

          // Main Info Area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  name.tr,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2E1A47),
                ),
                if (progress != null && progress > 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    themeColor,
                                    themeColor.withOpacity(0.6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      AppText(
                        "${progress.toStringAsFixed(0)}%",
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                const Divider(
                  color: Color(0xFFF9F7F5),
                  height: 16,
                  thickness: 1,
                ),

                if (deity.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.spa_outlined,
                        size: 14,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 8),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: "${"Deity/Lord:".tr} ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            TextSpan(
                              text: deity.tr,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],

                if (meaning.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF8F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AppText(
                      meaning.tr,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade800,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                if (energy.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.bolt,
                          size: 16,
                          color: Colors.orangeAccent,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 13,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(
                                  text: "${"Energy:".tr} ",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(text: energy.tr),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (bestFor != null && bestFor.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  AppText(
                    "Best For:",
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E8449),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children:
                        bestFor
                            .map(
                              (item) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFEAF2F1,
                                  ).withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFD4EFDF),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check,
                                      size: 10,
                                      color: Color(0xFF1E8449),
                                    ),
                                    const SizedBox(width: 4),
                                    AppText(
                                      item,
                                      fontSize: 11,
                                      color: const Color(0xFF1E8449),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 8),
                ],

                if (avoid != null && avoid.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  AppText(
                    "Avoid:",
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFCB4335),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children:
                        avoid
                            .map(
                              (item) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFDEDEC,
                                  ).withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFFADBD8),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.close,
                                      size: 10,
                                      color: Color(0xFFCB4335),
                                    ),
                                    const SizedBox(width: 4),
                                    AppText(
                                      item,
                                      fontSize: 11,
                                      color: const Color(0xFFCB4335),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),

          // Footer Tip
          if (tip.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.04),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                border: Border(
                  top: BorderSide(color: themeColor.withOpacity(0.08)),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, size: 18, color: themeColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppText(
                      tip,
                      fontSize: 12,
                      color: themeColor,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildMasaCard(Masa masa) {
    const themeColor = Color(0xFF2E6F40);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF5EFE6), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E1A47).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.calendar_month, size: 14, color: themeColor),
                      SizedBox(width: 6),
                      AppText(
                        "MASA (MONTH)",
                        fontSize: 11,
                        color: themeColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ],
                  ),
                ),
                if (masa.englishEquivalent.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: AppText(
                      masa.englishEquivalent,
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),

          // Main Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    AppText(
                      masa.name,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2E1A47),
                    ),
                    if (masa.nameHindi.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      AppText(
                        "(${masa.nameHindi})",
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Properties Row
                Row(
                  children: [
                    if (masa.sunSign.isNotEmpty)
                      Expanded(
                        child: _buildPropertyTile(
                          icon: Icons.brightness_5_outlined,
                          label: "Sun Sign",
                          value:
                              masa.sunSign +
                              (masa.sunSignHindi.isNotEmpty
                                  ? " (${masa.sunSignHindi})"
                                  : ""),
                          iconColor: Colors.orange.shade700,
                        ),
                      ),
                    if (masa.deityAssociation.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPropertyTile(
                          icon: Icons.bookmark_outline,
                          label: "Deity",
                          value: masa.deityAssociation,
                          iconColor: Colors.deepPurple.shade600,
                        ),
                      ),
                    ],
                  ],
                ),

                const Divider(
                  color: Color(0xFFF9F7F5),
                  height: 20,
                  thickness: 1,
                ),

                if (masa.interpretation.significance.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  AppText(
                    "Significance",
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF8F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AppText(
                      masa.interpretation.significance,
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                if (masa.interpretation.festivals.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  AppText(
                    "Festivals in this month:",
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        masa.interpretation.festivals
                            .map(
                              (fest) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.amber.shade100,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.celebration,
                                      size: 12,
                                      color: Colors.amber.shade900,
                                    ),
                                    const SizedBox(width: 6),
                                    AppText(
                                      fest,
                                      fontSize: 11.5,
                                      color: Colors.amber.shade900,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRituCard(Ritu ritu) {
    const themeColor = Color(0xFF008080);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF5EFE6), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E1A47).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.park_outlined, size: 14, color: themeColor),
                      SizedBox(width: 6),
                      AppText(
                        "RITU (SEASON)",
                        fontSize: 11,
                        color: themeColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ],
                  ),
                ),
                if (ritu.englishName.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: AppText(
                      ritu.englishName,
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),

          // Main Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    AppText(
                      ritu.name,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2E1A47),
                    ),
                    if (ritu.nameHindi.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      AppText(
                        "(${ritu.nameHindi})",
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                if (ritu.months.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                          children: [
                            TextSpan(
                              text: "Corresponding Months: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            TextSpan(
                              text: ritu.months.join(', '),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                if (ritu.description.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF8F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AppText(
                      ritu.description,
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                if (ritu.characteristics.isNotEmpty) ...[
                  const Divider(
                    color: Color(0xFFF9F7F5),
                    height: 16,
                    thickness: 1,
                  ),
                  AppText(
                    "Seasonal Characteristics",
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        ritu.characteristics
                            .map(
                              (char) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: themeColor.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: themeColor.withOpacity(0.1),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.circle,
                                      size: 6,
                                      color: themeColor,
                                    ),
                                    const SizedBox(width: 6),
                                    AppText(
                                      char,
                                      fontSize: 11.5,
                                      color: themeColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishaShoolCard(DishaShool dishaShool) {
    const themeColor = Color(0xFFD32F2F);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF5EFE6), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E1A47).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.explore, size: 14, color: themeColor),
                      SizedBox(width: 6),
                      AppText(
                        "DISHA SHOOL (TRAVEL ADVISORY)",
                        fontSize: 11,
                        color: themeColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    AppText(
                      "Avoid traveling ${dishaShool.direction}",
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2E1A47),
                    ),
                    if (dishaShool.directionHindi.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      AppText(
                        "(${dishaShool.directionHindi})",
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                AppText(
                  dishaShool.description,
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
                const SizedBox(height: 12),

                if (dishaShool.safeDirections.isNotEmpty) ...[
                  const Divider(
                    color: Color(0xFFF9F7F5),
                    height: 16,
                    thickness: 1,
                  ),
                  AppText(
                    "Safe Directions to Travel Today",
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        dishaShool.safeDirections
                            .map(
                              (dir) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.green.shade100,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      size: 12,
                                      color: Color(0xFF1E8449),
                                    ),
                                    const SizedBox(width: 6),
                                    AppText(
                                      dir,
                                      fontSize: 11.5,
                                      color: const Color(0xFF1E8449),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                if (dishaShool.remedies.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  AppText(
                    "Remedy / Parihara (If travel is unavoidable)",
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(height: 8),
                  ...dishaShool.remedies.map(
                    (rem) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 14,
                            color: themeColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppText(
                              rem,
                              fontSize: 12,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyTile({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3EFE9)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 2),
                AppText(
                  value.tr,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E1A47),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuhurtaSection(
    String title,
    List<Map<String, String>> timings,
    Color color,
  ) {
    if (timings.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: AppText(title, fontSize: 15, fontWeight: FontWeight.w700),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children:
                timings
                    .map(
                      (t) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppText(
                                t['title']!,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            AppText(
                              t['time']!,
                              fontSize: 13,
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }

  List<Map<String, String>> _getAuspiciousTimings() {
    final data = controller.panchangData.value?.data;
    if (data == null) return [];

    List<Map<String, String>> timings = [];

    for (var timing in data.auspiciousTimings) {
      timings.add({
        "title": timing.name,
        "time": controller.formatTimeRange(timing.start, timing.end),
      });
    }

    return timings;
  }

  List<Map<String, String>> _getInauspiciousTimings() {
    final data = controller.panchangData.value?.data;
    if (data == null) return [];

    List<Map<String, String>> timings = [];

    if (data.rahukaal.start.isNotEmpty && data.rahukaal.end.isNotEmpty) {
      timings.add({
        "title": "Rahu Kaal",
        "time": controller.formatTimeRange(
          data.rahukaal.start,
          data.rahukaal.end,
        ),
      });
    }

    if (data.yamagandam.start.isNotEmpty && data.yamagandam.end.isNotEmpty) {
      timings.add({
        "title": "Yamagandam",
        "time": controller.formatTimeRange(
          data.yamagandam.start,
          data.yamagandam.end,
        ),
      });
    }

    if (data.gulika.start.isNotEmpty && data.gulika.end.isNotEmpty) {
      timings.add({
        "title": "Gulika Kaal",
        "time": controller.formatTimeRange(data.gulika.start, data.gulika.end),
      });
    }

    return timings;
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Guidance Card Shimmer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 150,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 200,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 180,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            // 3 Component Card Shimmers
            ...List.generate(
              3,
              (index) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 50,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 100,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 80,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 150,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
