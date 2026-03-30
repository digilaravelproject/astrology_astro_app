import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../../core/constants/app_urls.dart';
import 'controller/training_video_controller.dart';
import 'model/training_videos_model.dart';
import 'training_video_detail_screen.dart';
import 'training_videos_list_screen.dart';

class TrainingVideosSection extends StatelessWidget {
  const TrainingVideosSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TrainingVideoController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red.withOpacity(0.5), width: 1.5),
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.red, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppText(
                  'Training Videos',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.trainingVideosScreen),
                child: AppText(
                  'View All',
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoading.value && controller.videoList.isEmpty) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final displayVideos = controller.videoList.take(3).toList();

          if (displayVideos.isEmpty) {
            return const SizedBox.shrink();
          }

          return SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 0),
              itemCount: displayVideos.length,
              itemBuilder: (context, index) {
                return _buildVideoCard(displayVideos[index], index);
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildVideoCard(TrainingVideoModel video, int index) {
    return GestureDetector(
      onTap: () => Get.to(
        () => TrainingVideoDetailScreen(
          videoId: video.id,
          preloadedVideo: video,
        ),
      ),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: index % 3 == 0 ? const Color(0xFFFFEB3B) : (index % 3 == 1 ? const Color(0xFFFFF176) : const Color(0xFFFFF9C4)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background "Phone Screen" mockup or Thumbnail
            Positioned(
              bottom: -20,
              left: 20,
              right: 20,
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border.all(color: Colors.black87, width: 2),
                ),
                padding: const EdgeInsets.all(4),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: video.thumbnailUrl.isNotEmpty
                      ? Image.network(
                          AppUrls.baseImageUrl + video.thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                              child: Icon(Icons.videocam_outlined,
                                  color: Colors.grey.shade300, size: 40)))
                      : Center(
                          child: Icon(Icons.smartphone_rounded,
                              color: Colors.grey.shade300, size: 40),
                        ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    video.title,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.3,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: Container(
                  //     padding: const EdgeInsets.all(4),
                  //     decoration: const BoxDecoration(
                  //       color: Colors.black12,
                  //       shape: BoxShape.circle,
                  //     ),
                  //     child: const Icon(Icons.play_arrow_rounded, size: 14, color: Colors.black54),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
