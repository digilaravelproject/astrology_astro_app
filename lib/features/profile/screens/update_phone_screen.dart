import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import '../widgets/add_phone_bottom_sheet.dart';
import '../widgets/phone_verification_bottom_sheet.dart';
import '../presentation/controllers/phone_number_controller.dart';
import '../presentation/bindings/phone_number_binding.dart';
import '../../../core/utils/custom_snackbar.dart';

class UpdatePhoneScreen extends StatefulWidget {
  const UpdatePhoneScreen({super.key});

  @override
  State<UpdatePhoneScreen> createState() => _UpdatePhoneScreenState();
}

class _UpdatePhoneScreenState extends State<UpdatePhoneScreen> {
  late PhoneNumberController _controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<PhoneNumberController>()) {
      PhoneNumberBinding().dependencies();
    }
    _controller = Get.find<PhoneNumberController>();
  }

  Future<void> _verifyExistingNumber(dynamic phoneNumber) async {
    final result = await _controller.addPhoneNumber(
      phoneNumber.countryCode,
      phoneNumber.phone,
    );

    if (result.isSuccess) {
      final newPhoneId = result.body['numbers']?.last['id'] ?? result.body['phone_number']?['id'] ?? result.body['id'] ?? phoneNumber.id;
      _showVerificationBottomSheet(
        newPhoneId,
        '${phoneNumber.countryCode} ${phoneNumber.phone}',
      );
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Update Phone Number',
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddPhoneBottomSheet(context),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const AppText('Add New', color: Colors.white, fontWeight: FontWeight.w600),
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.phoneNumbers.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildInfoBanner(),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Existing Phone Numbers
                    if (_controller.phoneNumbers.isNotEmpty) ...[
                      AppText(
                        'Your Phone Numbers',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E1A47),
                      ),
                      const SizedBox(height: 16),
                      ..._controller.phoneNumbers.map((phoneNumber) {
                        return _buildPhoneCard(phoneNumber);
                      }).toList(),
                      const SizedBox(height: 80), // Space for FAB
                    ],
                    
                    if (_controller.phoneNumbers.isEmpty)
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.mobile_copy, size: 60, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              AppText(
                                'No phone numbers added yet',
                                fontSize: 16,
                                color: Colors.grey.shade500,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: AppColors.lightPink,
      child: const AppText(
        'You will receive calls and chat alerts on your verified phone numbers.',
        fontSize: 12,
        color: Colors.black87,
        textAlign: TextAlign.center,
        height: 1.5,
      ),
    );
  }

  Widget _buildPhoneCard(dynamic phoneNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Iconsax.call_copy,
              color: AppColors.primaryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  '${phoneNumber.countryCode} ${phoneNumber.phone}',
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2E1A47),
                ),
                if (!phoneNumber.isVerified)
                  GestureDetector(
                    onTap: () => _verifyExistingNumber(phoneNumber),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.shade100),
                      ),
                      child: const AppText(
                        'Verify',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.orange,
                      ),
                    ),
                  )
                else if (phoneNumber.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.green, size: 14),
                        SizedBox(width: 4),
                        AppText(
                          'Active',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                        ),
                      ],
                    ),
                  )
                else
                  InkWell(
                    onTap: () => _setAsDefault(phoneNumber.id),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
                      ),
                      child: const AppText(
                        'Set Default',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _setAsDefault(int phoneId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Obx(() {
          final isLoading = _controller.isLoading.value;
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.verify_copy,
                      color: AppColors.primaryColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const AppText(
                    'Set as Default?',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E1A47),
                  ),
                  const SizedBox(height: 12),
                  AppText(
                    'Are you sure you want to set this as your default phone number?',
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: CircularProgressIndicator(),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: const AppText(
                              'Cancel',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E1A47),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              await _controller.setDefaultPhoneNumber(phoneId);
                              if (dialogContext.mounted) {
                                Navigator.of(dialogContext).pop();
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const AppText(
                              'Set Default',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
