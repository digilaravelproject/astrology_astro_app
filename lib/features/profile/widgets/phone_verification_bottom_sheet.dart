import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/custom_otp_field.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/utils/custom_snackbar.dart';
import '../presentation/controllers/phone_number_controller.dart';

class PhoneVerificationBottomSheet extends StatefulWidget {
  final int phoneId;
  final String phoneNumber;
  const PhoneVerificationBottomSheet({super.key, required this.phoneId, required this.phoneNumber});

  @override
  State<PhoneVerificationBottomSheet> createState() => _PhoneVerificationBottomSheetState();
}

class _PhoneVerificationBottomSheetState extends State<PhoneVerificationBottomSheet> {
  final TextEditingController _otpController = TextEditingController();
  final PhoneNumberController _controller = Get.find<PhoneNumberController>();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const AppText(
            'Verification',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E1A47),
          ),
          const SizedBox(height: 12),
          AppText(
            'We have sent a 4-digit verification code to\n${widget.phoneNumber}',
            fontSize: 14,
            color: Colors.grey.shade600,
            textAlign: TextAlign.center,
            height: 1.5,
          ),
          const SizedBox(height: 32),
          CustomOtpField(
            length: 4,
            borderColor: Colors.grey.shade300,
            focusedBorderColor: AppColors.primaryColor,
            textColor: Colors.black87,
            controller: _otpController,
            onCompleted: (val) {
              _controller.verifyPhoneNumber(widget.phoneId, val);
            },
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText(
                'Didn\'t receive the code? ',
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              GestureDetector(
                onTap: () {
                  // Handle resend logic if needed, usually just calling addPhoneNumber again
                  _controller.addPhoneNumber(
                    widget.phoneNumber.split(' ')[0], 
                    widget.phoneNumber.split(' ')[1]
                  );
                },
                child: const AppText(
                  'Resend OTP',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Obx(() => CustomButton(
            text: _controller.isVerifying.value ? 'Verifying...' : 'Verify',
            onPressed: () {
              if (_otpController.text.length == 4) {
                _controller.verifyPhoneNumber(widget.phoneId, _otpController.text);
              } else {
                CustomSnackBar.showError('Please enter a 4-digit OTP');
              }
            },
            isLoading: _controller.isVerifying.value,
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
