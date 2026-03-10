import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';

class PanchangScreen extends StatefulWidget {
  const PanchangScreen({super.key});

  @override
  State<PanchangScreen> createState() => _PanchangScreenState();
}

class _PanchangScreenState extends State<PanchangScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _showFullCalendar = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: Color(0xFF2E1A47),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF9F5), // Premium Ivory
      appBar: const CustomAppBar(
        title: 'Panchang',
      ),
      body: Column(
        children: [
          _buildCalendarSection(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSunMoonSection(),
                  const SizedBox(height: 24),
                  _buildCorePanchangSection(),
                  const SizedBox(height: 24),
                  _buildMuhurtaSection("Shubh Muhurta", [
                    {"title": "Abhijit Muhurta", "time": "11:45 AM - 12:32 PM"},
                    {"title": "Amrit Kaal", "time": "02:15 PM - 03:45 PM"},
                  ], Colors.green),
                  const SizedBox(height: 16),
                  _buildMuhurtaSection("Ashubh Muhurta", [
                    {"title": "Rahu Kaal", "time": "01:30 PM - 03:00 PM"},
                    {"title": "Yamaganda", "time": "06:00 AM - 07:30 AM"},
                    {"title": "Gulika Kaal", "time": "09:00 AM - 10:30 AM"},
                  ], Colors.red),
                  const SizedBox(height: 24),
                ],
              ),
            ),
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
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
                      DateFormat('MMMM yyyy').format(_selectedDate),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2E1A47),
                    ),
                    AppText(
                      DateFormat('EEEE, dd MMM').format(_selectedDate),
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
                        _showFullCalendar ? Iconsax.arrow_up_2_copy : Iconsax.calendar_copy,
                        color: AppColors.primaryColor,
                      ),
                      onPressed: () => setState(() => _showFullCalendar = !_showFullCalendar),
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.location_copy, color: AppColors.primaryColor),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_showFullCalendar)
            SizedBox(
              height: 300,
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                    _showFullCalendar = false;
                  });
                },
              ),
            )
          else
            _buildDateStrip(),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildDateStrip() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 30, // Show 30 days around selected date
        itemBuilder: (context, index) {
          // Centering today or selected date
          final date = DateTime.now().add(Duration(days: index - 5));
          final isSelected = date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 55,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [AppColors.primaryColor, AppColors.primaryColor.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(18),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(
                    DateFormat('EEE').format(date).toUpperCase(),
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
    return Row(
      children: [
        Expanded(
          child: _buildTimingCard(
            title: "Sun Timings",
            items: [
              {"label": "Sunrise", "time": "07:02 AM", "icon": Icons.wb_sunny_rounded, "color": Colors.orange},
              {"label": "Sunset", "time": "06:14 PM", "icon": Icons.wb_twilight_rounded, "color": Colors.deepOrange},
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTimingCard(
            title: "Moon Timings",
            items: [
              {"label": "Moonrise", "time": "08:24 AM", "icon": Icons.nightlight_round, "color": Colors.blueGrey},
              {"label": "Moonset", "time": "09:33 PM", "icon": Icons.mode_night_rounded, "color": Colors.indigo},
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimingCard({required String title, required List<Map<String, dynamic>> items}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(title, fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey.shade800),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(item['icon'], size: 16, color: item['color']),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(item['label'], fontSize: 11, color: Colors.grey),
                        AppText(item['time'], fontSize: 13, fontWeight: FontWeight.bold),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCorePanchangSection() {
    final details = [
      {"label": "Tithi", "value": "Shukla Dwitiya upto 07:11 PM"},
      {"label": "Nakshatra", "value": "Purva Bhadrapada upto 11:58 PM"},
      {"label": "Yoga", "value": "Sadhya upto 09:42 AM"},
      {"label": "Karana", "value": "Kaulava upto 06:15 AM"},
      {"label": "Sunsign", "value": "Kumbha (Aquarius)"},
      {"label": "Moonsign", "value": "Kumbha (Aquarius)"},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText('Panchang Details', fontSize: 15, fontWeight: FontWeight.w700),
          const SizedBox(height: 12),
          ...details.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: AppText(d['label']!, fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                    ),
                    const AppText(":  ", fontWeight: FontWeight.bold),
                    Expanded(
                      child: AppText(d['value']!, fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMuhurtaSection(String title, List<Map<String, String>> timings, Color color) {
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
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: timings
                .map((t) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppText(t['title']!, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          AppText(t['time']!, fontSize: 13, color: color, fontWeight: FontWeight.w700),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
