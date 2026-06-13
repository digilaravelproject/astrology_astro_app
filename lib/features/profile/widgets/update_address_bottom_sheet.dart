import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/core/widgets/app_text.dart';
import 'package:astro_astrologer/core/widgets/custom_button.dart';
import '../presentation/controllers/billing_controller.dart';
import '../presentation/bindings/billing_binding.dart';

class UpdateAddressBottomSheet extends StatefulWidget {
  const UpdateAddressBottomSheet({super.key});

  @override
  State<UpdateAddressBottomSheet> createState() => _UpdateAddressBottomSheetState();
}

class _UpdateAddressBottomSheetState extends State<UpdateAddressBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late BillingController _controller;

  @override
  void initState() {
    super.initState();
    // Ensure controller is registered
    if (!Get.isRegistered<BillingController>()) {
      BillingBinding().dependencies();
    }
    _controller = Get.find<BillingController>();
    
    // Fetch data every time the bottom sheet opens
    _controller.fetchBillingAddress();
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
      child: Obx(() {
        if (_controller.isInitialLoading.value) {
          return const SizedBox(
            height: 400,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          );
        }

        return SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
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
                  child: Icon(Iconsax.location_copy, color: AppColors.primaryColor, size: 30),
                ),
                const SizedBox(height: 16),
                AppText(
                  'Add Your Address',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2E1A47),
                ),
                const SizedBox(height: 8),
                AppText(
                  'Please share your address for invoice and compliance purposes.',
                  fontSize: 14,
                  textAlign: TextAlign.center,
                  color: Colors.grey.shade500,
                  height: 1.4,
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _controller.addressController,
                  placeholder: 'Enter Address',
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _controller.nameController,
                  placeholder: 'Enter Name for invoice',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _controller.pincodeController,
                        placeholder: 'Pincode',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _controller.cityController,
                        placeholder: 'City',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _controller.stateController,
                        placeholder: 'State',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _controller.countryController,
                        placeholder: 'Country',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                Obx(() => CustomButton(
                  text: 'Submit',
                  isLoading: _controller.isLoading.value,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _controller.updateAddress();
                    }
                  },
                  backgroundColor: AppColors.primaryColor,
                  borderRadius: 12,
                )),
                
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 15, color: Color(0xFF2E1A47), fontWeight: FontWeight.w500),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }
}

void showUpdateAddressBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: const UpdateAddressBottomSheet(),
    ),
  );
}
