import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import 'app_text.dart';

class ImagePickerBottomSheet extends StatelessWidget {
  final Function(File) onImagePicked;

  const ImagePickerBottomSheet({
    super.key,
    required this.onImagePicked,
  });

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (image != null) {
        onImagePicked(File(image.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),
          AppText('Upload From', fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF2E1A47)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildUploadOption(
                  icon: Iconsax.camera_copy,
                  label: 'Camera',
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImage(ImageSource.camera);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildUploadOption(
                  icon: Iconsax.gallery_copy,
                  label: 'Gallery',
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImage(ImageSource.gallery);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 32),
            const SizedBox(height: 12),
            AppText(label, fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF2E1A47)),
          ],
        ),
      ),
    );
  }
}

void showImagePickerBottomSheet(BuildContext context, Function(File) onImagePicked) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => ImagePickerBottomSheet(onImagePicked: onImagePicked),
  );
}
