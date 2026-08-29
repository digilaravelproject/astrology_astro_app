import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/utils/custom_snackbar.dart';

class PaySlipScreen extends StatefulWidget {
  const PaySlipScreen({super.key});

  @override
  State<PaySlipScreen> createState() => _PaySlipScreenState();
}

class _PaySlipScreenState extends State<PaySlipScreen> {
  final TextEditingController _startMonthController = TextEditingController();
  final TextEditingController _endMonthController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Pay Slip'.tr),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthField(
              label: 'Select start date'.tr,
              controller: _startMonthController,
              onTap: () => _selectDate(context, _startMonthController),
            ),
            const SizedBox(height: 24),
            _buildMonthField(
              label: 'Select end date'.tr,
              controller: _endMonthController,
              onTap: () => _selectDate(context, _endMonthController),
            ),
            const Spacer(),
            CustomButton(
              text: 'Send on Email'.tr,
              onPressed: () {
                if (_startMonthController.text.isEmpty ||
                    _endMonthController.text.isEmpty) {
                  CustomSnackBar.showError(
                    'Please select both start and end dates',
                  );
                  return;
                }
                CustomSnackBar.showSuccess(
                  'Pay slip sent to your registered email',
                  title: 'Success',
                );
              },
              backgroundColor: AppColors.primaryColor,
              borderRadius: 100,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade600,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  controller.text.isEmpty ? label : controller.text,
                  fontSize: 15,
                  color:
                      controller.text.isEmpty
                          ? Colors.grey.shade400
                          : const Color(0xFF2E1A47),
                ),
                Icon(
                  Iconsax.calendar_1_copy,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime tempDate = DateTime.now();

    final result = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final formattedHeader =
                "${_getDayName(tempDate.weekday)}, ${_getMonthShort(tempDate.month)} ${tempDate.day}, ${tempDate.year}";
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        formattedHeader,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    const Divider(
                      height: 1,
                      color: AppColors.primaryColor,
                      thickness: 1.5,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 180,
                      child: Theme(
                        data: ThemeData.light().copyWith(
                          cupertinoOverrideTheme: const CupertinoThemeData(
                            textTheme: CupertinoTextThemeData(
                              dateTimePickerTextStyle: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          initialDateTime: tempDate,
                          minimumDate: DateTime(2020),
                          maximumDate: DateTime(2101),
                          onDateTimeChanged: (DateTime newDate) {
                            setModalState(() {
                              tempDate = newDate;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: Colors.black12),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop(tempDate);
                      },
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'Done'.tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        controller.text = DateFormat('dd MMM yyyy').format(result);
      });
    }
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(weekday - 1) % 7];
  }

  String _getMonthShort(int month) {
    const months = [
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
    return months[(month - 1) % 12];
  }
}
