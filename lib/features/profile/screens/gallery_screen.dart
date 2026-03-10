import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/image_picker_bottom_sheet.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            const Expanded(
              child: TabBarView(
                children: [
                  GalleryGridView(tabType: 'profile'),
                  GalleryGridView(tabType: 'live'),
                ],
              ),
            ),
            _buildUploadButton(context),
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
          Expanded(
            child: AppText(
              'Admin takes upto 7 days to approve the image. Your image shall be visible to customers when you enable at least 3 images.',
              fontSize: 13,
              color: const Color(0xFF856404),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: () => _showUploadOptions(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.add_square_copy, size: 20),
            const SizedBox(width: 8),
            AppText('Upload Image', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
          ],
        ),
      ),
    );
  }

  void _showUploadOptions(BuildContext context) {
    showImagePickerBottomSheet(context, (file) {
      // Handle the picked image file
      debugPrint('Picked image path: ${file.path}');
      // You can add logic here to upload the image or update UI
    });
  }
}

class GalleryGridView extends StatefulWidget {
  final String tabType;
  const GalleryGridView({super.key, required this.tabType});

  @override
  State<GalleryGridView> createState() => _GalleryGridViewState();
}

class _GalleryGridViewState extends State<GalleryGridView> {
  late List<Map<String, dynamic>> images;

  @override
  void initState() {
    super.initState();
    // Mock data for images
    images = widget.tabType == 'profile'
        ? [
            {'url': 'https://i.pravatar.cc/300?u=1', 'status': 'verified', 'isEnabled': false},
            {'url': 'https://i.pravatar.cc/300?u=2', 'status': 'verified', 'isEnabled': false},
            {'url': 'https://i.pravatar.cc/300?u=3', 'status': 'verified', 'isEnabled': true},
          ]
        : [
            {'url': 'https://i.pravatar.cc/300?u=4', 'status': 'pending', 'isEnabled': false},
          ];
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: AppText('Confirm Delete', fontSize: 18, fontWeight: FontWeight.w700),
        content: AppText('Are you sure you want to delete this image?', fontSize: 15),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AppText('No', color: Colors.grey, fontWeight: FontWeight.w600),
          ),
          TextButton(
            onPressed: () {
              setState(() => images.removeAt(index));
              Navigator.pop(context);
              Get.snackbar(
                'Success',
                'Image deleted successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
              );
            },
            child: AppText('Yes', color: Colors.red, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        return _buildGalleryItem(images[index], index);
      },
    );
  }

  Widget _buildGalleryItem(Map<String, dynamic> item, int index) {
    final bool isVerified = item['status'] == 'verified';
    final bool isEnabled = item['isEnabled'];

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
                item['url'],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isVerified ? const Color(0xFFFFF3F3) : const Color(0xFFFBEAEA),
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
                      color: isVerified ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    AppText(
                      isVerified ? 'verified' : 'Pending',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isVerified ? Colors.green : Colors.red,
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (isVerified) ...[
                      SizedBox(
                        height: 24,
                        width: 40,
                        child: Switch(
                          value: isEnabled,
                          onChanged: (val) {
                            setState(() => item['isEnabled'] = val);
                          },
                          activeColor: AppColors.primaryColor,
                          activeTrackColor: AppColors.primaryColor.withOpacity(0.2),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    GestureDetector(
                      onTap: () => _showDeleteDialog(index),
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
}
