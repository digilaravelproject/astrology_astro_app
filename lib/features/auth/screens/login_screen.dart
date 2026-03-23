import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/image_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/auth_controller.dart';
import 'registration_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
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
          // Background image - Stays fixed behind everything (temporarily disabled)
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
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Logo
                      Image.asset(
                        ImageConstants.logo,
                        width: 170,
                        height: 170,
                      ),
                      
                      const SizedBox(height: 30),

                      Column(
                        children: [
                          AppText(
                            'Astrologer',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepPink,
                            height: 1.2,
                            textAlign: TextAlign.center,
                          ),
                          AppText(
                            'Partner Portal',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepPink,
                            height: 1.2,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      
                      // Login using OTP text
                      AppText(
                        'Login using OTP',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.errorColor,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Phone Input
                      _buildPhoneInput(authController, errorMessage),
                      
                      // Error message
                      Obx(() => errorMessage.value.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8, left: 20),
                              child: AppText(
                                errorMessage.value,
                                fontSize: 12,
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : const SizedBox.shrink()),
                      
                      const SizedBox(height: 30),
                      
                      // Send OTP Button
                      Obx(() => CustomButton(
                        text: 'Send OTP',
                        isLoading: authController.isLoading.value,
                        borderRadius: 100,
                        onPressed: () {
                          // Validate mobile number before proceeding
                          if (authController.mobileController.text.isEmpty) {
                            errorMessage.value = 'Please enter mobile number';
                            return;
                          }
                          
                          if (authController.mobileController.text.length != 10) {
                            errorMessage.value = 'Please enter valid 10-digit mobile number';
                            return;
                          }
                          
                          // Clear error and proceed
                          errorMessage.value = '';
                          // Call sendOtp API
                          authController.sendOtp();
                        },
                      )),
                      
                      const SizedBox(height: 16),

                      // Sign Up link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppText('New astrologer? ', fontSize: 13, color: Colors.black54),
                          GestureDetector(
                            onTap: () => Get.to(() => const RegistrationScreen(), transition: Transition.rightToLeft),
                            child: AppText(
                              'Sign Up',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      _buildBottomFeatures(),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Loading overlay on top of everything
          // Obx(() => authController.isLoading.value
          //     ? const LoadingWidget(type: LoadingType.overlay)
          //     : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildPhoneInput(AuthController authController, RxString errorMessage) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              AppText(
                '+91',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: TextFormField(
                  controller: authController.mobileController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  onChanged: (value) {
                    // Clear error when user starts typing
                    if (errorMessage.value.isNotEmpty) {
                      errorMessage.value = '';
                    }
                  },
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter Mobile Number',
                    hintStyle: TextStyle(
                      color: Colors.black26,
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                    ),
                    counterText: "",
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.black12,
          ),
        ],
      ),
    );
  }



  Widget _buildBottomFeatures() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(25),
      shadowColor: Colors.black.withOpacity(0.2),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.7),
              Colors.white.withOpacity(0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _buildFeatureItem(
                  icon: Icons.person_outline,
                  title: 'Expert',
                  subtitle: 'Astrologers',
                  color: AppColors.deepPink,
                ),
              ),

              _buildDivider(),

              Expanded(
                child: _buildFeatureItem(
                  icon: Icons.lock_outline,
                  title: '100%',
                  subtitle: 'Private & Confidential',
                  color: AppColors.deepPink,
                ),
              ),

              _buildDivider(),

              Expanded(
                child: _buildFeatureItem(
                  icon: Icons.verified_user_outlined,
                  title: 'Verified',
                  subtitle: 'Platform',
                  color: AppColors.deepPink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Center Divider
  Widget _buildDivider() {
    return const VerticalDivider(
      width: 20,
      thickness: 1,
      color: Colors.black12,
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: color,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AppText(
          title,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF8B1538),
        ),
        const SizedBox(height: 2),
        AppText(
          subtitle,
          textAlign: TextAlign.center,
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF8B1538),
          height: 1.2,
        ),
      ],
    );
  }
}
