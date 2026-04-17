import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/utils/custom_snackbar.dart';
import '../presentation/controllers/phone_number_controller.dart';
import 'phone_verification_bottom_sheet.dart';

class AddPhoneBottomSheet extends StatefulWidget {
  const AddPhoneBottomSheet({super.key});

  @override
  State<AddPhoneBottomSheet> createState() => _AddPhoneBottomSheetState();
}

class _AddPhoneBottomSheetState extends State<AddPhoneBottomSheet> {
  final TextEditingController _countryCodeController = TextEditingController(text: '+91');
  final TextEditingController _phoneController = TextEditingController();
  late PhoneNumberController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<PhoneNumberController>();
  }

  @override
  void dispose() {
    _countryCodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _addNewPhoneNumber() async {
    if (_phoneController.text.isEmpty) {
      CustomSnackBar.showError('Please enter a phone number');
      return;
    }

    final result = await _controller.addPhoneNumber(
      _countryCodeController.text,
      _phoneController.text.trim(),
    );

    if (result.isSuccess) {
      final newPhoneId = result.body['phone']?['id'] ?? result.body['numbers']?.last['id'] ?? result.body['phone_number']?['id'] ?? result.body['id'];
      
      // Close this bottom sheet
      Get.back();

      if (newPhoneId != null) {
        _showVerificationBottomSheet(
          newPhoneId,
          '${_countryCodeController.text} ${_phoneController.text.trim()}',
        );
      }
    }
  }

  void _showVerificationBottomSheet(int phoneId, String phoneNumber) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: PhoneVerificationBottomSheet(
          phoneId: phoneId,
          phoneNumber: phoneNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 20, color: Colors.grey),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.mobile_copy, color: AppColors.primaryColor, size: 30),
          ),
          const SizedBox(height: 16),
          AppText(
            'Add New Phone Number',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2E1A47),
          ),
          const SizedBox(height: 8),
          AppText(
            'Please enter the phone number you want to add.',
            fontSize: 14,
            textAlign: TextAlign.center,
            color: Colors.grey.shade500,
            height: 1.4,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1.5)),
                ),
                child: DropdownButton<String>(
                  value: _countryCodeController.text,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _countryCodeController.text = val;
                      });
                    }
                  },
                  items: ['+91', '+1', '+44', '+971'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: AppText(value, fontSize: 16, fontWeight: FontWeight.w500),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  autofocus: true,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 1.5),
                  decoration: InputDecoration(
                    hintText: 'Phone number',
                    hintStyle: TextStyle(color: Colors.grey.shade300, letterSpacing: 1),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5)),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryColor, width: 2)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Obx(() => CustomButton(
            text: _controller.isAdding.value ? 'Adding...' : 'Add New',
            onPressed: _controller.isAdding.value ? () {} : _addNewPhoneNumber,
            backgroundColor: AppColors.primaryColor,
            borderRadius: 100,
          )),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

void showAddPhoneBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: const AddPhoneBottomSheet(),
    ),
  );
}
