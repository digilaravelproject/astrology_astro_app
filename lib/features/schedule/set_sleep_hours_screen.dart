import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_text.dart';
import 'presentation/controllers/schedule_controller.dart';

class SetSleepHoursScreen extends StatefulWidget {
  const SetSleepHoursScreen({Key? key}) : super(key: key);

  @override
  State<SetSleepHoursScreen> createState() => _SetSleepHoursScreenState();
}

class _SetSleepHoursScreenState extends State<SetSleepHoursScreen> {
  TimeOfDay startTime = const TimeOfDay(hour: 22, minute: 0); // 10:00 PM
  TimeOfDay endTime = const TimeOfDay(hour: 6, minute: 0); // 06:00 AM
  
  late final ScheduleController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ScheduleController>();
    
    // Load current values if already available in controller
    _loadCurrentSleepHours();
    
    // Refresh sleep hours data when screen opens
    _controller.refreshSleepHours().then((_) {
      _loadCurrentSleepHours();
    });
    
    // Listen to changes in sleep hours data
    ever(_controller.sleepHours, (sleepHours) {
      if (sleepHours != null && mounted) {
        setState(() {
          startTime = _parseTimeString(sleepHours.sleepStartTime);
          endTime = _parseTimeString(sleepHours.sleepEndTime);
        });
      }
    });
  }

  void _loadCurrentSleepHours() {
    final sleepHours = _controller.sleepHours.value;
    if (sleepHours != null) {
      setState(() {
        startTime = _parseTimeString(sleepHours.sleepStartTime);
        endTime = _parseTimeString(sleepHours.sleepEndTime);
      });
    }
  }

  TimeOfDay _parseTimeString(String timeString) {
    try {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    
    // Manual format to avoiding bringing in intl package unless necessary
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  String _calculateSleepDuration() {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    
    int durationMinutes;
    if (endMinutes > startMinutes) {
      // Same day (e.g., 2 AM to 6 AM)
      durationMinutes = endMinutes - startMinutes;
    } else {
      // Next day (e.g., 10 PM to 6 AM)
      durationMinutes = (24 * 60) - startMinutes + endMinutes;
    }
    
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    
    if (minutes == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${minutes}m';
    }
  }

  Future<void> _saveSleepHours() async {
    await _controller.setSleepHours(startTime, endTime);
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final initialTime = isStart ? startTime : endTime;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        if (isStart) {
          startTime = pickedTime;
        } else {
          endTime = pickedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: AppText(
          'Set Sleep Hours',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    AppText(
                      'When do you want to rest?',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2C2C2C),
                    ),
                    const SizedBox(height: 12),
                    AppText(
                      'Choose your Sleep Time for up to 8 hours.\nEmergency sessions will be paused during your\nselected time.',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                      textAlign: TextAlign.center,
                      height: 1.5,
                    ),
                    const SizedBox(height: 30),
                    
                    // Start Sleep Time Card
                    GestureDetector(
                      onTap: () => _selectTime(context, true),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              'START SLEEP TIME',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade500,
                              letterSpacing: 1.2,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.nights_stay_outlined,
                                    color: AppColors.primaryColor.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                AppText(
                                  _formatTime(startTime),
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1A1A24),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Down Arrow Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // End Sleep Time Card
                    GestureDetector(
                      onTap: () => _selectTime(context, false),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              'END SLEEP TIME',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade500,
                              letterSpacing: 1.2,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF9C4), // Light yellow
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.wb_sunny_outlined,
                                    color: Color(0xFFFBC02D), // Dark yellow
                                  ),
                                ),
                                const SizedBox(width: 16),
                                AppText(
                                  _formatTime(endTime),
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1A1A24),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Total Rest Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          AppText(
                            'Total Rest: ',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                          AppText(
                            _calculateSleepDuration(),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Remove sleep time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, size: 16, color: Colors.grey.shade500),
                        const SizedBox(width: 6),
                        AppText(
                          'Remove sleep time',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 50),
                    
                    // Repeat Daily Details
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'Repeat Daily',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C2C2C),
                        ),
                        const SizedBox(height: 6),
                        AppText(
                          'The Sleep Time you set will be automatically repeated daily.',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade500,
                          height: 1.4,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            
            // Save Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: _controller.isLoading.value ? null : _saveSleepHours,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor, // Make it primary when active
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : AppText(
                          'Save Sleep Schedule',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
