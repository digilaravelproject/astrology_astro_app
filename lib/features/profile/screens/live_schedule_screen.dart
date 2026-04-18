import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../presentation/controllers/live_session_controller.dart';
import '../domain/models/live_session_model.dart';
import '../../../core/utils/custom_snackbar.dart';

class LiveScheduleScreen extends StatefulWidget {
  const LiveScheduleScreen({super.key});

  @override
  State<LiveScheduleScreen> createState() => _LiveScheduleScreenState();
}

class _LiveScheduleScreenState extends State<LiveScheduleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late LiveSessionController _controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller = Get.find<LiveSessionController>();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddSessionSheet() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final durationController = TextEditingController(text: '60');
    final participantsController = TextEditingController(text: '100');
    DateTime? selectedDateTime;
    String selectedDateText = 'Select Date';
    String selectedTimeText = 'Select Time';

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
            child: SingleChildScrollView(
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
                  const AppText('Schedule Live Session', fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF2E1A47)),
                  const SizedBox(height: 24),
                  
                  // Topic Input
                  _buildLabel('Session Topic'),
                  const SizedBox(height: 8),
                  _buildTextField(titleController, 'Enter session topic...'),
                  const SizedBox(height: 16),

                  // Description Input
                  _buildLabel('Description'),
                  const SizedBox(height: 8),
                  _buildTextField(descriptionController, 'Enter session description...', maxLines: 3),
                  const SizedBox(height: 16),

                  // Duration & Participants Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Duration (Mins)'),
                            const SizedBox(height: 8),
                            _buildTextField(durationController, '60', isNumeric: true),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Max Participants'),
                            const SizedBox(height: 8),
                            _buildTextField(participantsController, '100', isNumeric: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Date & Time Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Date'),
                            const SizedBox(height: 8),
                            _buildPickerTrigger(
                              text: selectedDateText,
                              icon: Iconsax.calendar_copy,
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 90)),
                                );
                                if (date != null) {
                                  setSheetState(() {
                                    selectedDateText = DateFormat('dd MMM yyyy').format(date);
                                    if (selectedDateTime != null) {
                                      selectedDateTime = DateTime(date.year, date.month, date.day, selectedDateTime!.hour, selectedDateTime!.minute);
                                    } else {
                                      selectedDateTime = DateTime(date.year, date.month, date.day);
                                    }
                                  });
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
                            _buildLabel('Time'),
                            const SizedBox(height: 8),
                            _buildPickerTrigger(
                              text: selectedTimeText,
                              icon: Iconsax.clock_copy,
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (time != null) {
                                  final now = DateTime.now();
                                  DateTime tempDateTime;
                                  if (selectedDateTime != null) {
                                    tempDateTime = DateTime(selectedDateTime!.year, selectedDateTime!.month, selectedDateTime!.day, time.hour, time.minute);
                                  } else {
                                    tempDateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
                                  }

                                  // Check if at least 10 minutes in future
                                  if (tempDateTime.isBefore(now.add(const Duration(minutes: 10)))) {
                                    CustomSnackBar.showError('Please select a time at least 10 minutes from now');
                                    return;
                                  }

                                  setSheetState(() {
                                    selectedTimeText = time.format(context);
                                    selectedDateTime = tempDateTime;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  Obx(() => CustomButton(
                    text: 'Schedule Now',
                    isLoading: _controller.isCreating.value,
                    onPressed: () {
                      if (titleController.text.trim().isEmpty) {
                        CustomSnackBar.showError('Please enter a session topic');
                        return;
                      }
                      
                      if (descriptionController.text.trim().isEmpty) {
                        CustomSnackBar.showError('Please enter a session description');
                        return;
                      }

                      if (selectedDateText == 'Select Date') {
                        CustomSnackBar.showError('Please select a date for the session');
                        return;
                      }

                      if (selectedTimeText == 'Select Time') {
                        CustomSnackBar.showError('Please select a time for the session');
                        return;
                      }

                      if (selectedDateTime == null) {
                        CustomSnackBar.showError('Invalid date and time selected');
                        return;
                      }

                      // Check if at least 5 minutes in future at submission time
                      final now = DateTime.now();
                      if (selectedDateTime!.isBefore(now.add(const Duration(minutes: 5)))) {
                        CustomSnackBar.showError('Session must be scheduled at least 5 minutes in advance');
                        return;
                      }

                      final duration = int.tryParse(durationController.text) ?? 60;
                      if (duration < 15) {
                        CustomSnackBar.showError('Duration must be at least 15 minutes');
                        return;
                      }

                      final participants = int.tryParse(participantsController.text) ?? 100;
                      if (participants < 1) {
                        CustomSnackBar.showError('Max participants must be at least 1');
                        return;
                      }

                      _controller.createSession(
                        title: titleController.text,
                        description: descriptionController.text,
                        scheduledAt: selectedDateTime!,
                        sessionType: 'public',
                        duration: duration,
                        maxParticipants: participants,
                      );
                    },
                    backgroundColor: AppColors.primaryColor,
                    borderRadius: 100,
                  )),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return AppText(text, fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700);
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1, bool isNumeric = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumeric ? [FilteringTextInputFormatter.digitsOnly] : null,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
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
        label: const AppText('Schedule Live', color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
    );
  }

  Widget _buildUpcomingList() {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_controller.upcomingSessions.isEmpty) {
        return _buildEmptyState('No upcoming live sessions');
      }
      return RefreshIndicator(
        onRefresh: () => _controller.getSessions(),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _controller.upcomingSessions.length,
          itemBuilder: (context, index) {
            return _buildSessionCard(_controller.upcomingSessions[index], true);
          },
        ),
      );
    });
  }

  Widget _buildCompletedList() {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_controller.completedSessions.isEmpty) {
        return _buildEmptyState('No past live sessions');
      }
      return RefreshIndicator(
        onRefresh: () => _controller.getSessions(),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _controller.completedSessions.length,
          itemBuilder: (context, index) {
            return _buildSessionCard(_controller.completedSessions[index], false);
          },
        ),
      );
    });
  }

  Widget _buildSessionCard(LiveSessionModel session, bool isUpcoming) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E1A47).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUpcoming ? AppColors.primaryColor.withOpacity(0.1) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isUpcoming ? Iconsax.video_play_copy : Iconsax.video_tick_copy,
                        color: isUpcoming ? AppColors.primaryColor : Colors.grey.shade400,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            session.title,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2E1A47),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (session.sessionType == 'private')
                            Row(
                              children: [
                                Icon(Iconsax.lock_copy, size: 10, color: Colors.amber.shade700),
                                const SizedBox(width: 4),
                                AppText(
                                  'Private Session',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.amber.shade700,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (session.description != null && session.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  AppText(
                    session.description!,
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    maxLines: 2,
                    height: 1.5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Divider(height: 1, thickness: 0.8),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildInfoTag(Iconsax.calendar_copy, DateFormat('dd MMM yyyy').format(session.scheduledAt)),
                        const SizedBox(width: 16),
                        _buildInfoTag(Iconsax.clock_copy, DateFormat('hh:mm a').format(session.scheduledAt)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AppText(
                        '${session.durationMinutes}m', 
                        fontSize: 12, 
                        fontWeight: FontWeight.w700, 
                        color: Colors.grey.shade500
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isUpcoming)
            Positioned(
              top: 12,
              right: 12,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _confirmDelete(session.id),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Iconsax.trash_copy, color: Colors.red.shade300, size: 18),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primaryColor.withOpacity(0.8)),
        const SizedBox(width: 6),
        AppText(
          label, 
          fontSize: 12, 
          fontWeight: FontWeight.w700, 
          color: const Color(0xFF2E1A47).withOpacity(0.7)
        ),
      ],
    );
  }

  void _confirmDelete(int sessionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText('Delete Session?', fontWeight: FontWeight.w700, fontSize: 18),
        content: const AppText('Are you sure you want to delete this live session? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Cancel', color: Colors.grey),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _controller.deleteSession(sessionId);
            },
            child: const AppText('Delete', color: Colors.red, fontWeight: FontWeight.w700),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
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
}
