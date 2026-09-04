import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/widgets/app_text.dart';
import 'package:astro_astrologer/core/widgets/custom_app_bar.dart';
import 'presentation/controllers/remedy_controller.dart';
import 'presentation/bindings/remedy_binding.dart';
import 'presentation/screens/remedy_detail_screen.dart';
import 'package:astro_astrologer/core/widgets/custom_image_widget.dart';

class SuggestedRemediesScreen extends StatefulWidget {
  const SuggestedRemediesScreen({super.key});

  @override
  State<SuggestedRemediesScreen> createState() =>
      _SuggestedRemediesScreenState();
}

class _SuggestedRemediesScreenState extends State<SuggestedRemediesScreen> {
  late RemedyController _controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<RemedyController>()) {
      RemedyBinding().dependencies();
    }
    _controller = Get.find<RemedyController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const CustomAppBar(title: 'Suggested Remedies'.tr),
      body: SafeArea(
        top: false,
        child: Obx(() {
          if (_controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.remedies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.healing_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  AppText('No remedies available'.tr,
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.remedies.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final remedy = _controller.remedies[index];
              return InkWell(
                onTap:
                    () => Get.to(() => RemedyDetailScreen(remedyId: remedy.id)),
                borderRadius: BorderRadius.circular(16),
                child: RemedyCard(
                  title: remedy.title,
                  description: remedy.description,
                  image: remedy.image,
                  isActive: remedy.isActive,
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class RemedyCard extends StatelessWidget {
  final String title;
  final String description;
  final String? image;
  final bool isActive;

  const RemedyCard({
    super.key,
    required this.title,
    required this.description,
    required this.image,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          if (image != null)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: CustomImageWidget(
                imagePath:
                    image!.startsWith('http')
                        ? image!
                        : '${AppUrls.baseImageUrl}$image',
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 180,
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: double.infinity,
                    height: 180,
                    color: Colors.grey.shade200,
                    child: Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Icon(
                Icons.healing_outlined,
                size: 64,
                color: AppColors.primaryColor.withValues(alpha: 0.5),
              ),
            ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppText(
                        title,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E1A47),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isActive
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AppText(
                        isActive ? 'Active' : 'Inactive',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AppText(
                  description,
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  height: 1.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
