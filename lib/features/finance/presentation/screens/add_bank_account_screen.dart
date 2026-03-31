import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../controllers/finance_controller.dart';

class AddBankAccountScreen extends StatefulWidget {
  const AddBankAccountScreen({super.key});

  @override
  State<AddBankAccountScreen> createState() => _AddBankAccountScreenState();
}

class _AddBankAccountScreenState extends State<AddBankAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _holderNameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  late FinanceController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<FinanceController>();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  void dispose() {
    _holderNameController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _controller.addBankAccount(
        accountHolderName: _holderNameController.text.trim(),
        bankName: _bankNameController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        ifscCode: _ifscController.text.trim(),
        passbookDocument: _selectedImage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const CustomAppBar(
        title: 'Add Bank Account',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                label: 'Account Holder Name',
                controller: _holderNameController,
                hint: 'Enter holder name',
                icon: Iconsax.user_copy,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Bank Name',
                controller: _bankNameController,
                hint: 'Enter your bank name',
                icon: Iconsax.bank_copy,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Account Number',
                controller: _accountNumberController,
                hint: 'Enter account number',
                icon: Iconsax.card_copy,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'IFSC Code',
                controller: _ifscController,
                hint: 'Enter 11-digit IFSC code',
                icon: Iconsax.code_copy,
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 32),

              // Image Upload Section
              AppText(
                'Upload Passbook / Cancelled Cheque (Optional)',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2E1A47),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Iconsax.camera_copy, color: AppColors.primaryColor, size: 24),
                      ),
                      const SizedBox(height: 12),
                      AppText(
                        'Tap to upload image',
                        fontSize: 13,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),
              Obx(() => CustomButton(
                text: _controller.isAddingAccount.value ? 'Adding...' : 'Save Account',
                onPressed: _controller.isAddingAccount.value ? () {} : _submitForm,
              )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.words,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2E1A47),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2E1A47),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              prefixIcon: Icon(icon, color: AppColors.primaryColor.withOpacity(0.5), size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              if (label == 'Account Number' && value.trim().length < 9) {
                return 'Account number must be at least 9 digits';
              }
              if (label == 'IFSC Code' && value.trim().length != 11) {
                return 'IFSC code must be 11 characters';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
