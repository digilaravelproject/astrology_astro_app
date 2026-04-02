import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import '../widgets/phone_verification_bottom_sheet.dart';
import '../presentation/controllers/phone_number_controller.dart';
import '../presentation/bindings/phone_number_binding.dart';

class UpdatePhoneScreen extends StatefulWidget {
  const UpdatePhoneScreen({super.key});

  @override
  State<UpdatePhoneScreen> createState() => _UpdatePhoneScreenState();
}

class _UpdatePhoneScreenState extends State<UpdatePhoneScreen> {
  late PhoneNumberController _controller;
  final TextEditingController _newCountryCodeController = TextEditingController(text: '+91');
  final TextEditingController _newPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<PhoneNumberController>()) {
      PhoneNumberBinding().dependencies();
    }
    _controller = Get.find<PhoneNumberController>();
  }

  @override
  void dispose() {
    _newCountryCodeController.dispose();
    _newPhoneController.dispose();
    super.dispose();
  }

  void _addNewPhoneNumber() {
    if (_newPhoneController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a phone number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    _controller.addPhoneNumber(
      _newCountryCodeController.text,
      _newPhoneController.text.trim(),
    );
    _newPhoneController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Update Phone Number',
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
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
                      const SizedBox(height: 32),
                    ],

                    // Add New Phone Number Section
                    AppText(
                      'Add New Phone Number',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E1A47),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Country Code Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1.5)),
                          ),
                          child: DropdownButton<String>(
                            value: _newCountryCodeController.text,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _newCountryCodeController.text = val;
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
                        // Phone Number Input
                        Expanded(
                          child: TextField(
                            controller: _newPhoneController,
                            keyboardType: TextInputType.phone,
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
                    const SizedBox(height: 24),
                    Obx(() => CustomButton(
                      text: _controller.isAdding.value ? 'Adding...' : 'Add New',
                      onPressed: _controller.isAdding.value ? () {} : _addNewPhoneNumber,
                      backgroundColor: AppColors.primaryColor,
                      borderRadius: 100,
                    )),
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
    final isVerified = phoneNumber.isVerified;
    final isDefault = phoneNumber.isDefault;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.call_copy,
                color: AppColors.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      '${phoneNumber.countryCode} ${phoneNumber.phone}',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E1A47),
                    ),
                    const SizedBox(height: 4),
                    if (isVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const AppText(
                          'Verified',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => Padding(
                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                              child: PhoneVerificationBottomSheet(
                                phoneNumber: '${phoneNumber.countryCode} ${phoneNumber.phone}',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const AppText(
                            'Verify',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.green, size: 14),
                      SizedBox(width: 4),
                      AppText(
                        'Active',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ],
                  ),
                )
              else if (isVerified)
                TextButton(
                  onPressed: () => _setAsDefault(phoneNumber.id),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const AppText(
                    'Set Default',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
            ],
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
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E1A47),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              await _controller.setDefaultPhoneNumber(phoneId);
                              if (dialogContext.mounted) {
                                Navigator.of(dialogContext).pop();
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const AppText(
                              'Yes, Set Default',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
