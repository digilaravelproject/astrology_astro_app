import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/image_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/auth_controller.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final size = MediaQuery.of(context).size;
    final errorMessage = ''.obs;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Stack(
        children: [
          // Fixed white background layer
          Positioned.fill(
            child: Container(color: Colors.white),
          ),
          // Background image - Fixed (temporarily disabled)
          // Positioned.fill(
          //   child: Opacity(
          //     opacity: 0.4,
          //     child: Image.asset(
          //       ImageConstants.loginBackground,
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ),
          Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 25,
                  right: 25,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.06),

                    AppText(
                      'Verification',
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                      height: 1.1,
                      letterSpacing: -1,
                    ),

                    const SizedBox(height: 15),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: AppText(
                        'Enter OTP sent to\n+91 ${authController.mobileController.text}',
                        textAlign: TextAlign.center,
                        fontSize: 14,
                        color: AppColors.black.withOpacity(0.3),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),

                    SizedBox(height: size.height * 0.08),

                    _buildOtpInput(context, authController, errorMessage),

                    // Error message
                    Obx(() => errorMessage.value.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: AppText(
                              errorMessage.value,
                              fontSize: 12,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                              textAlign: TextAlign.center,
                            ),
                          )
                        : const SizedBox.shrink()),

                    SizedBox(height: size.height * 0.08),

                    Obx(() => CustomButton(
                          text: 'Verify',
                          borderRadius: 100,
                          onPressed: () {
                            // Validate OTP before proceeding
                            if (authController.otpController.text.isEmpty) {
                              errorMessage.value = 'Please enter OTP';
                              return;
                            }

                            if (authController.otpController.text.length != 4) {
                              errorMessage.value = 'Please enter valid 4-digit OTP';
                              return;
                            }

                            // Clear error and proceed
                            errorMessage.value = '';
                            // Navigate to registration name screen
                            Get.offAllNamed('/dashboard');
                          },
                          isLoading: authController.isLoading.value,
                        )),

                    const SizedBox(height: 40),

                    _buildResendSection(authController),
                  ],
                ),
              ),
            ),
          ),
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildOtpInput(
      BuildContext context, AuthController authController, RxString errorMessage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        4,
        (index) => Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColors.deepPink.withOpacity(0.3),
              width: 0.9,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepPink.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: TextField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textColorPrimary,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              decoration: const InputDecoration(
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                counterText: "",
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                // Clear error when user starts typing
                if (errorMessage.value.isNotEmpty) {
                  errorMessage.value = '';
                }

                if (value.isNotEmpty) {
                  if (index < 3) FocusScope.of(context).nextFocus();

                  String currentOtp = authController.otpController.text;
                  if (currentOtp.length <= index) {
                    authController.otpController.text = currentOtp + value;
                  } else {
                    List<String> chars = currentOtp.split('');
                    chars[index] = value;
                    authController.otpController.text = chars.join('');
                  }
                } else {
                  if (index > 0) FocusScope.of(context).previousFocus();
                  String currentOtp = authController.otpController.text;
                  if (currentOtp.length > index) {
                    List<String> chars = currentOtp.split('');
                    chars.removeAt(index);
                    authController.otpController.text = chars.join('');
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResendSection(AuthController authController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppText(
          'Didn\'t receive code? ',
          color: AppColors.textColorSecondary,
          fontSize: 14,
        ),
        GestureDetector(
          onTap: () {
            // Resend OTP logic
          },
          child: AppText(
            'Resend',
            color: AppColors.deepPink,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 50,
      left: 20,
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            size: 20, color: AppColors.black),
        onPressed: () => Get.back(),
      ),
    );
  }
}
