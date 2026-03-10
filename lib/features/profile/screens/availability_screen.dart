import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_app_bar.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  // Weekly Schedule JSON structure
  List<Map<String, dynamic>> _schedule = [
    {'day': 'Monday', 'isOpen': true, 'slots': [{'start': '09:00', 'end': '13:00'}, {'start': '16:00', 'end': '20:00'}]},
    {'day': 'Tuesday', 'isOpen': true, 'slots': [{'start': '09:00', 'end': '18:00'}]},
    {'day': 'Wednesday', 'isOpen': true, 'slots': [{'start': '10:00', 'end': '19:00'}]},
    {'day': 'Thursday', 'isOpen': false, 'slots': []},
    {'day': 'Friday', 'isOpen': true, 'slots': [{'start': '09:00', 'end': '21:00'}]},
    {'day': 'Saturday', 'isOpen': true, 'slots': [{'start': '10:00', 'end': '14:00'}]},
    {'day': 'Sunday', 'isOpen': false, 'slots': []},
  ];

  Future<void> _selectTime(int dayIndex, int slotIndex, bool forStart) async {
    final slot = _schedule[dayIndex]['slots'][slotIndex];
    final initialTimeStr = forStart ? slot['start'] : slot['end'];
    final timeParts = initialTimeStr.split(':');
    
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
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

    if (selectedTime != null) {
      final formattedTime = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (forStart) {
          _schedule[dayIndex]['slots'][slotIndex]['start'] = formattedTime;
        } else {
          _schedule[dayIndex]['slots'][slotIndex]['end'] = formattedTime;
        }
      });
    }
  }

  void _addSlot(int dayIndex) {
    setState(() {
      _schedule[dayIndex]['slots'].add({'start': '09:00', 'end': '17:00'});
      _schedule[dayIndex]['isOpen'] = true;
    });
  }

  void _removeSlot(int dayIndex, int slotIndex) {
    setState(() {
      _schedule[dayIndex]['slots'].removeAt(slotIndex);
    });
  }

  String _formatTimeDisplay(String time24) {
    final parts = time24.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const CustomAppBar(
        title: 'Availability Settings',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   AppText(
                    'Weekly Schedule',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2E1A47),
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    'Manage your working hours for each day of the week.',
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _schedule.length,
              itemBuilder: (context, dayIndex) {
                final dayData = _schedule[dayIndex];
                final isOpen = dayData['isOpen'] as bool;
                final slots = dayData['slots'] as List;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                        child: Row(
                          children: [
                             AppText(
                              dayData['day'],
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isOpen ? const Color(0xFF2E1A47) : Colors.grey.shade400,
                            ),
                            const Spacer(),
                            if (!isOpen)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: AppText('Closed', fontSize: 13, color: Colors.red.shade300, fontWeight: FontWeight.w600),
                              ),
                            Switch.adaptive(
                              value: isOpen,
                              activeColor: AppColors.primaryColor,
                              onChanged: (val) {
                                setState(() {
                                  _schedule[dayIndex]['isOpen'] = val;
                                  if (val && slots.isEmpty) _addSlot(dayIndex);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      if (isOpen) ...[
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              ...List.generate(slots.length, (slotIndex) {
                                final slot = slots[slotIndex];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _buildTimeChip(
                                          time: slot['start'],
                                          onTap: () => _selectTime(dayIndex, slotIndex, true),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      AppText('to', fontSize: 11, color: Colors.grey.shade400, fontWeight: FontWeight.w600),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _buildTimeChip(
                                          time: slot['end'],
                                          onTap: () => _selectTime(dayIndex, slotIndex, false),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        onPressed: () => _removeSlot(dayIndex, slotIndex),
                                        icon: const Icon(Icons.remove_circle_outline_rounded, size: 20, color: Colors.redAccent),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: InkWell(
                                  onTap: () => _addSlot(dayIndex),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.add_circle_outline_rounded, size: 18, color: AppColors.primaryColor),
                                        const SizedBox(width: 6),
                                        AppText(
                                          'Add Slot',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Save Availability',
              onPressed: () => Get.back(),
              backgroundColor: AppColors.primaryColor,
              borderRadius: 100,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChip({required String time, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        alignment: Alignment.center,
        child: AppText(
          _formatTimeDisplay(time),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2E1A47),
        ),
      ),
    );
  }
}
