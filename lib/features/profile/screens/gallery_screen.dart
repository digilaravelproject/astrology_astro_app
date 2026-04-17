import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/image_picker_bottom_sheet.dart';
import 'package:astro_astrologer/features/profile/controllers/gallery_controller.dart';
import 'package:astro_astrologer/features/profile/model/gallery_model.dart';
import 'package:astro_astrologer/core/utils/logger.dart';
import 'package:astro_astrologer/features/profile/repository/gallery_repository.dart';
import 'package:astro_astrologer/features/profile/usecase/gallery_usecases.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<GalleryController>()) {
       Get.lazyPut(() => GalleryRepository(apiClient: Get.find()));
       Get.lazyPut(() => GetGalleryImagesUseCase(repository: Get.find()));
       Get.lazyPut(() => UploadGalleryImagesUseCase(repository: Get.find()));
       Get.lazyPut(() => ToggleGalleryVisibilityUseCase(repository: Get.find()));
       Get.lazyPut(() => DeleteGalleryImageUseCase(repository: Get.find()));
       Get.put(GalleryController(
         getGalleryImagesUseCase: Get.find(),
         uploadGalleryImagesUseCase: Get.find(),
         toggleGalleryVisibilityUseCase: Get.find(),
         deleteGalleryImageUseCase: Get.find(),
       ));
    }
    final controller = Get.find<GalleryController>();
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: const CustomAppBar(
          title: 'Gallery',
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              width: double.infinity,
              child: const TabBar(
                isScrollable: false,
                dividerColor: Color(0xFFEEEEEE),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primaryColor,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Poppins'),
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, fontFamily: 'Poppins'),
                tabs: [
                  Tab(text: 'Profile Gallery'),
                  Tab(text: 'Live event DP'),
                ],
              ),
            ),
            _buildNoticeBanner(),
            Expanded(
              child: TabBarView(
                children: [
                  GalleryGridView(tabType: 'profile'),
                  GalleryGridView(tabType: 'live'),
                ],
              ),
            ),
            _buildUploadButton(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildNoticeBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFEAB0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Iconsax.info_circle_copy, color: Color(0xFFB88E00), size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: AppText(
              'Admin takes upto 7 days to approve the image. Your image shall be visible to customers when you enable at least 3 images.',
              fontSize: 13,
              color: Color(0xFF856404),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context, GalleryController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Obx(() => ElevatedButton(
        onPressed: controller.isUploading.value ? null : () => _showUploadOptions(context, controller),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          elevation: 0,
        ),
        child: controller.isUploading.value 
          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.add_square_copy, size: 20),
                const SizedBox(width: 8),
                AppText('Upload Image', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
              ],
            ),
      )),
    );
  }

  void _showUploadOptions(BuildContext context, GalleryController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ImagePickerBottomSheet(
        onImagePicked: (file) {
          controller.uploadImages([file]);
        },
      ),
    );
    
    // For multiple images, we can add a specific button or handle it here
    // But since the current BottomSheet handles one, we'll stick to it or expand it.
  }
}

class GalleryGridView extends StatelessWidget {
  final String tabType;
  const GalleryGridView({super.key, required this.tabType});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GalleryController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // Filter images based on tabType
      final images = tabType == 'live' 
          ? controller.images.where((img) => img.status.toLowerCase() == 'verified').toList()
          : controller.images.toList();

      if (images.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.gallery_copy, size: 60, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              AppText('No images found', fontSize: 16, color: Colors.grey.shade500),
            ],
          ),
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return _buildGalleryItem(context, controller, images[index]);
        },
      );
    });
  }

  Widget _buildGalleryItem(BuildContext context, GalleryController controller, GalleryImage item) {
    final bool isVerified = item.status == 'verified';
    final bool isEnabled = item.isVisible;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                item.url,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isVerified ? const Color(0xFFF3FFF3) : const Color(0xFFFFF9F3),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isVerified ? Icons.check_circle : Iconsax.info_circle_copy,
                      color: isVerified ? Colors.green : Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    AppText(
                      isVerified ? 'verified' : 'Pending',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isVerified ? Colors.green : Colors.orange,
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      height: 20,
                      width: 34,
                      child: Transform.scale(
                        scale: 0.7,
                        child: Switch(
                          value: isEnabled,
                          onChanged: (val) {
                            controller.toggleVisibility(item.id);
                          },
                          activeColor: AppColors.primaryColor,
                          activeTrackColor: AppColors.primaryColor.withOpacity(0.2),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showDeleteDialog(context, controller, item.id),
                      child: const Icon(Iconsax.trash_copy, color: Colors.grey, size: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, GalleryController controller, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const AppText('Confirm Delete', fontSize: 18, fontWeight: FontWeight.w700),
        content: const AppText('Are you sure you want to delete this image?', fontSize: 15),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText('No', color: Colors.grey, fontWeight: FontWeight.w600),
          ),
          TextButton(
            onPressed: () {
              controller.deleteImage(id);
              Navigator.pop(context);
            },
            child: const AppText('Yes', color: Colors.red, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
