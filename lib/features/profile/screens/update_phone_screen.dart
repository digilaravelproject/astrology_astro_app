import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import '../widgets/phone_verification_bottom_sheet.dart';

class UpdatePhoneScreen extends StatefulWidget {
  const UpdatePhoneScreen({super.key});

  @override
  State<UpdatePhoneScreen> createState() => _UpdatePhoneScreenState();
}

class _UpdatePhoneScreenState extends State<UpdatePhoneScreen> {
  final TextEditingController _registeredController = TextEditingController(text: '9892599842');
  final TextEditingController _primaryController = TextEditingController(text: '9892599842');
  final TextEditingController _secondaryController = TextEditingController();

  String _registeredCode = '+91';
  String _primaryCode = '+91';
  String _secondaryCode = '+91';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Update Phone Number',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildInfoBanner(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildPhoneField(
                    label: 'Registered Phone Number',
                    controller: _registeredController,
                    code: _registeredCode,
                    onCodeChanged: (val) => setState(() => _registeredCode = val!),
                    isVerified: true,
                  ),
                  const SizedBox(height: 24),
                  _buildPhoneField(
                    label: 'Primary Phone Number',
                    controller: _primaryController,
                    code: _primaryCode,
                    onCodeChanged: (val) => setState(() => _primaryCode = val!),
                    isVerified: true,
                  ),
                  const SizedBox(height: 24),
                  _buildPhoneField(
                    label: 'Secondary Phone Number',
                    controller: _secondaryController,
                    code: _secondaryCode,
                    onCodeChanged: (val) => setState(() => _secondaryCode = val!),
                    isVerified: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: AppColors.lightPink,
      child: const AppText(
        'Registered number is only for logging into the application. You will receive calls and chat alerts on your primary and secondary number only.',
        fontSize: 12,
        color: Colors.black87,
        textAlign: TextAlign.center,
        height: 1.5,
      ),
    );
  }

  Widget _buildPhoneField({
    required String label,
    required TextEditingController controller,
    required String code,
    required ValueChanged<String?> onCodeChanged,
    required bool isVerified,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        const SizedBox(height: 12),
        Row(
          children: [
            // Country Code Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1.5)),
              ),
              child: DropdownButton<String>(
                value: code,
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                onChanged: onCodeChanged,
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
                controller: controller,
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
            const SizedBox(width: 12),
            // Verify Button
            SizedBox(
              height: 32,
              child: ElevatedButton(
                onPressed: isVerified ? null : () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: PhoneVerificationBottomSheet(phoneNumber: '$code ${controller.text}'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isVerified ? Colors.grey.shade300 : AppColors.primaryColor,
                  foregroundColor: isVerified ? Colors.grey.shade600 : Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: AppText(
                  isVerified ? 'Verified' : 'Verify',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isVerified ? Colors.grey.shade500 : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
