import 'package:flutter/material.dart';
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
      appBar: const CustomAppBar(
        title: 'Pay Slip',
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthField(
              label: 'Select start date',
              controller: _startMonthController,
              onTap: () => _selectDate(context, _startMonthController),
            ),
            const SizedBox(height: 24),
            _buildMonthField(
              label: 'Select end date',
              controller: _endMonthController,
              onTap: () => _selectDate(context, _endMonthController),
            ),
            const Spacer(),
            CustomButton(
              text: 'Send on Email',
              onPressed: () {
                if (_startMonthController.text.isEmpty || _endMonthController.text.isEmpty) {
                  CustomSnackBar.showError('Please select both start and end dates');
                  return;
                }
                CustomSnackBar.showSuccess('Pay slip sent to your registered email', title: 'Success');
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
                  color: controller.text.isEmpty ? Colors.grey.shade400 : const Color(0xFF2E1A47),
                ),
                Icon(Iconsax.calendar_1_copy, color: Colors.grey.shade400, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
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

    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }
}
