import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_app_bar.dart';

class LiveScheduleScreen extends StatefulWidget {
  const LiveScheduleScreen({super.key});

  @override
  State<LiveScheduleScreen> createState() => _LiveScheduleScreenState();
}

class _LiveScheduleScreenState extends State<LiveScheduleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock data for live sessions
  final List<Map<String, dynamic>> _upcomingSessions = [
    {
      'title': 'Vedic Astrology & Career Growth',
      'date': '20 Feb 2026',
      'time': '06:00 PM',
      'isPrivate': false,
    },
    {
      'title': 'Tarot Reading for Love Life',
      'date': '21 Feb 2026',
      'time': '11:00 AM',
      'isPrivate': true,
    },
  ];

  final List<Map<String, dynamic>> _completedSessions = [
    {
      'title': 'Weekly Horoscope Discussion',
      'date': '18 Feb 2026',
      'time': '07:30 PM',
      'duration': '45 mins',
    },
    {
      'title': 'Marriage & Relationship Guide',
      'date': '15 Feb 2026',
      'time': '05:00 PM',
      'duration': '60 mins',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddSessionSheet() {
    final titleController = TextEditingController();
    String selectedDate = 'Select Date';
    String selectedTime = 'Select Time';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AppText('Schedule Live Session', fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF2E1A47)),
                const SizedBox(height: 24),
                
                // Topic Input
                AppText('Session Topic', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: titleController,
                    style: TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Enter session topic...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Date & Time Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText('Date', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                          const SizedBox(height: 10),
                          _buildPickerTrigger(
                            text: selectedDate,
                            icon: Iconsax.calendar_copy,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 30)),
                              );
                              if (date != null) {
                                setSheetState(() => selectedDate = '${date.day} ${monthNames[date.month-1]} ${date.year}');
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText('Time', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                          const SizedBox(height: 10),
                          _buildPickerTrigger(
                            text: selectedTime,
                            icon: Iconsax.clock_copy,
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                setSheetState(() => selectedTime = time.format(context));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                CustomButton(
                  text: 'Schedule Now',
                  onPressed: () {
                    if (titleController.text.isNotEmpty && selectedDate != 'Select Date' && selectedTime != 'Select Time') {
                      setState(() {
                        _upcomingSessions.insert(0, {
                          'title': titleController.text,
                          'date': selectedDate,
                          'time': selectedTime,
                          'isPrivate': false,
                        });
                      });
                      Get.back();
                      Get.snackbar(
                        'Success',
                        'Live session scheduled successfully!',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  backgroundColor: AppColors.primaryColor,
                  borderRadius: 100,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPickerTrigger({required String text, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primaryColor),
            const SizedBox(width: 10),
            Expanded(
              child: AppText(
                text,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: text.contains('Select') ? Colors.grey : const Color(0xFF2E1A47),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const CustomAppBar(
        title: 'Live Schedule',
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            width: double.infinity,
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              dividerColor: Colors.transparent,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primaryColor,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Poppins'),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13, fontFamily: 'Poppins'),
              tabs: const [
                Tab(text: "Upcoming"),
                Tab(text: "Completed"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUpcomingList(),
                _buildCompletedList(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSessionSheet,
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: AppText('Schedule Live', color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
    );
  }

  Widget _buildUpcomingList() {
    if (_upcomingSessions.isEmpty) {
      return _buildEmptyState('No upcoming live sessions');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _upcomingSessions.length,
      itemBuilder: (context, index) {
        final session = _upcomingSessions[index];
        return _buildSessionCard(
          session: session,
          isUpcoming: true,
          onDelete: () => setState(() => _upcomingSessions.removeAt(index)),
        );
      },
    );
  }

  Widget _buildCompletedList() {
    if (_completedSessions.isEmpty) {
      return _buildEmptyState('No past live sessions');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _completedSessions.length,
      itemBuilder: (context, index) {
        final session = _completedSessions[index];
        return _buildSessionCard(
          session: session,
          isUpcoming: false,
        );
      },
    );
  }

  Widget _buildSessionCard({required Map<String, dynamic> session, bool isUpcoming = true, VoidCallback? onDelete}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUpcoming ? AppColors.primaryColor.withOpacity(0.08) : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isUpcoming ? Iconsax.video_play_copy : Iconsax.video_tick_copy,
                    color: isUpcoming ? AppColors.primaryColor : Colors.grey.shade400,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        session['title'],
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E1A47),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      if (session['isPrivate'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: Colors.amber.shade100),
                          ),
                          child: AppText(
                            'Private Session',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.amber.shade700,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isUpcoming && onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade300, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            Row(
              children: [
                _buildInfoTag(Iconsax.calendar_copy, session['date']),
                const SizedBox(width: 16),
                _buildInfoTag(Iconsax.clock_copy, session['time']),
                if (!isUpcoming) ...[
                  const Spacer(),
                  AppText(session['duration'], fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primaryColor.withOpacity(0.6)),
        const SizedBox(width: 6),
        AppText(label, fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.video_slash_copy, size: 64, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          AppText(message, fontSize: 14, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
        ],
      ),
    );
  }

  final List<String> monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
}
