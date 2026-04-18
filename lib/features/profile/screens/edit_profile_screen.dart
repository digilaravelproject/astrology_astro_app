import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/constants/app_urls.dart';
import '../../auth/controllers/auth_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final authController = Get.find<AuthController>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _docNumberController = TextEditingController();
  final _dobController = TextEditingController();

  // Selected Lists
  File? _profileImage;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _loadUserData();
  }

  Future<void> _fetchProfile() async {
    // Specifically fetching for ID 7 as requested by user
    await authController.getProfile(authController.currentUser.value?.id ?? 0);
    _loadUserData();
  }

  void _loadUserData() {
    final user = authController.currentUser.value;
    if (user != null) {
      _nameController.text = user.name;
      _mobileController.text = user.phone;
      _emailController.text = user.email;
      _cityController.text = user.city ?? '';
      _countryController.text = user.country ?? '';
      
      final astro = user.astrologer;
      if (astro != null) {
        _docNumberController.text = astro.idProofNumber ?? '';
        _dobController.text = astro.dateOfBirth?.substring(0, 10) ?? '';
        // Other fields could be mapped if they exist in the response
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _docNumberController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      final file = File(picked.path);
      setState(() => _profileImage = file);
      // Automatically update profile photo on selection
      authController.updateProfilePhoto(file);
    }
  }

  void _saveProfile() {
    final Map<String, dynamic> data = {
      '_method': 'PUT',
      'full_name': _nameController.text.trim(),
      'phone': _mobileController.text.trim(),
      'email': _emailController.text.trim(),
      'city': _cityController.text.trim(),
      'country': _countryController.text.trim(),
      'id_proof_number': _docNumberController.text.trim(),
      'date_of_birth': _dobController.text.trim(),
    };

    if (_profileImage != null) {
      data['profile_photo'] = _profileImage;
    }

    authController.updateProfile(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Edit Profile',
        actions: [
          TextButton(
            onPressed: () => _saveProfile(),
            child: const AppText(
              'Save',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Photo
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.1), width: 4),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Obx(() {
                      final user = authController.currentUser.value;
                      final profilePhoto = user?.astrologer?.profilePhoto;
                      
                      return ClipOval(
                        child: _profileImage != null
                            ? Image.file(_profileImage!, fit: BoxFit.cover)
                            : profilePhoto != null
                                ? Image.network('${AppUrls.baseImageUrl}$profilePhoto', fit: BoxFit.cover)
                                : Image.network('https://i.pravatar.cc/300?u=a042581f4e29026704d', fit: BoxFit.cover),
                      );
                    }),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildSectionHeader('BASIC DETAILS'),
            _buildInputField(controller: _nameController, label: 'Full Name', hint: 'Enter your name', icon: Iconsax.user_copy),
            const SizedBox(height: 16),
            _buildInputField(controller: _mobileController, label: 'Mobile Number', hint: 'Enter mobile number', icon: Iconsax.call_copy, readOnly: true),
            const SizedBox(height: 16),
            _buildInputField(controller: _emailController, label: 'Email ID', hint: 'Enter email address', icon: Iconsax.sms_copy),
            const SizedBox(height: 16),
            const AppText('Date of Birth', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2E1A47)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(child: _field(_dobController, 'DD / MM / YYYY', Icons.calendar_today_outlined)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildInputField(controller: _cityController, label: 'City', hint: 'Enter city', icon: Iconsax.location_copy)),
                const SizedBox(width: 16),
                Expanded(child: _buildInputField(controller: _countryController, label: 'Country', hint: 'Enter country', icon: Iconsax.global_copy)),
              ],
            ),

            const SizedBox(height: 32),
            _buildSectionHeader('VERIFICATION DOCUMENTS'),
            _buildInputField(controller: _docNumberController, label: 'ID Proof Number', hint: 'ID number', icon: Iconsax.card_pos_copy),
            const SizedBox(height: 20),
            
            // Read-only document previews
            const AppText('Uploaded Documents', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2E1A47)),
            const SizedBox(height: 12),
            Obx(() {
              final astro = authController.currentUser.value?.astrologer;
              final idProof = astro?.idProof;
              final certificate = astro?.certificate;

              return Row(
                children: [
                  _buildDocPreview('ID Proof', Iconsax.document_text_copy, idProof),
                  const SizedBox(width: 16),
                  _buildDocPreview('Certificate', Iconsax.teacher_copy, certificate),
                ],
              );
            }),
            
            const SizedBox(height: 40),
            CustomButton(
              text: 'Save Changes',
              onPressed: () => _saveProfile(),
              backgroundColor: AppColors.primaryColor,
              borderRadius: 100,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppText(
        title,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.primaryColor.withValues(alpha: 0.8),
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF2E1A47)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: readOnly ? Colors.grey.shade100 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 14, 
              color: readOnly ? Colors.grey.shade600 : const Color(0xFF2E1A47),
              fontWeight: readOnly ? FontWeight.w500 : FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: 20, color: readOnly ? Colors.grey.shade400 : AppColors.primaryColor.withValues(alpha: 0.7)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocPreview(String label, IconData icon, String? imagePath) {
    final hasImage = imagePath != null && imagePath.isNotEmpty;
    final imageUrl = hasImage ? '${AppUrls.baseImageUrl}$imagePath' : '';

    return Expanded(
      child: GestureDetector(
        onTap: hasImage ? () => _showFullView(imageUrl) : null,
        child: Container(
          height: 100,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: hasImage
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(icon, color: Colors.grey.shade400, size: 24),
                      ),
                    ),
                    Container(
                      color: Colors.black.withValues(alpha: 0.2),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 24),
                          const SizedBox(height: 4),
                          AppText(label, fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.grey.shade400, size: 24),
                    const SizedBox(height: 8),
                    AppText(label, fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                    const SizedBox(height: 4),
                    AppText('Not Uploaded', fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.w700),
                  ],
                ),
        ),
      ),
    );
  }

  void _showFullView(String imageUrl) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(color: Colors.black.withValues(alpha: 0.8)),
            ),
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
                },
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _selectDate() async {
    final now = DateTime.now();
    final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);
    
    final picked = await showDatePicker(
      context: context,
      initialDate: eighteenYearsAgo,
      firstDate: DateTime(1900),
      lastDate: eighteenYearsAgo,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryColor, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _dobController.text =
      // '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}');
      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}');
    }
  }

  Widget _field(
      TextEditingController controller,
      String hint,
      IconData icon, {
        TextInputType? keyboard,
        List<TextInputFormatter>? formatters,
        Widget? trailing,
      }) =>
      TextField(
        controller: controller,
        keyboardType: keyboard,
        inputFormatters: formatters,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 13, color: AppColors.textColorHint),
          prefixIcon: Icon(icon, color: AppColors.primaryColor, size: 20),
          suffixIcon: trailing,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );

}
