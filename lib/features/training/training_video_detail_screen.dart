import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import 'controller/training_video_detail_controller.dart';
import 'model/training_videos_model.dart';

class TrainingVideoDetailScreen extends StatefulWidget {
  final int videoId;
  final TrainingVideoModel? preloadedVideo;

  const TrainingVideoDetailScreen({
    super.key,
    required this.videoId,
    this.preloadedVideo,
  });

  @override
  State<TrainingVideoDetailScreen> createState() => _TrainingVideoDetailScreenState();
}

class _TrainingVideoDetailScreenState extends State<TrainingVideoDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TrainingVideoDetailController _controller;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _videoInitialized = false;
  bool _videoError = false;
  bool _isInitializing = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<TrainingVideoDetailController>();
    _controller.fetchVideoDetail(widget.videoId);

    // Pulse animation for play button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializePlayer(String url) async {
    if (_videoInitialized || _isInitializing || url.isEmpty) return;
    setState(() => _isInitializing = true);
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoPlayerController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primaryColor,
          handleColor: AppColors.primaryColor,
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white38,
        ),
        placeholder: Container(color: Colors.black),
        autoInitialize: true,
      );
      if (mounted) {
        setState(() {
          _videoInitialized = true;
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _videoError = true;
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        body: Obx(() {
          final video = _controller.video.value ?? widget.preloadedVideo;
          final isLoading = _controller.isLoading.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video Player / Thumbnail
              _buildVideoSection(video),

              // Info Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: isLoading && video == null
                      ? const Center(child: CircularProgressIndicator())
                      : _buildInfoSection(video),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildVideoSection(TrainingVideoModel? video) {
    return Stack(
      children: [
        // Video player or thumbnail
        AspectRatio(
          aspectRatio: 22 / 12,
          child: _videoInitialized && _chewieController != null
              ? Chewie(controller: _chewieController!)
              : _buildThumbnail(video),
        ),

        // Back button (always on top)
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 8,
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnail(TrainingVideoModel? video) {
    final thumbnailUrl = video != null && video.thumbnailUrl.isNotEmpty
        ? '${AppUrls.baseImageUrl}${video.thumbnailUrl}'
        : null;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Thumbnail Image
        thumbnailUrl != null
            ? CachedNetworkImage(
                imageUrl: thumbnailUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: const Color(0xFF1A1A2E),
                  child: const Center(child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),

        // Gradient overlay (bottom-heavy for title readability)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.6),
              ],
            ),
          ),
        ),

        // Play button
        if (!_isInitializing)
          Center(
            child: GestureDetector(
              onTap: () {
                final url = _controller.video.value?.videoUrl ??
                    widget.preloadedVideo?.videoUrl ?? '';
                if (url.isNotEmpty) {
                  _initializePlayer(AppUrls.baseImageUrl + url);
                }
              },
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.45),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: _videoError
                      ? const Icon(Icons.refresh_rounded, color: Colors.white, size: 32)
                      : const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 42),
                ),
              ),
            ),
          )
        else
          const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)),

        if (_videoError)
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const AppText('Video unavailable. Tap to retry.', color: Colors.white, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF1A1A2E),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_outline_rounded, color: Colors.white.withOpacity(0.15), size: 72),
            const SizedBox(height: 12),
            AppText('Loading thumbnail...', color: Colors.white38, fontSize: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(TrainingVideoModel? video) {
    if (video == null) {
      return const Center(child: AppText('Video not found', color: Colors.grey));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Type badge + sort order
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.label_outlined, size: 13, color: AppColors.primaryColor),
                    const SizedBox(width: 5),
                    AppText(video.type, fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sort_rounded, size: 13, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    AppText('#${video.sortOrder}', fontSize: 12, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Title
          AppText(
            video.title,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1A2E),
            height: 1.35,
          ),
          const SizedBox(height: 16),

          // Divider
          Divider(color: Colors.grey.shade100, thickness: 1.2),
          const SizedBox(height: 16),

          // About section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.info_outline_rounded, color: AppColors.primaryColor, size: 18),
              ),
              const SizedBox(width: 10),
              const AppText('About this video', fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
            ],
          ),
          const SizedBox(height: 12),

          AppText(
            video.description,
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.7,
          ),
          const SizedBox(height: 24),

          // Watch button
        /*  GestureDetector(
            onTap: () {
              _initializePlayer('https://www.w3schools.com/html/mov_bbb.mp4');
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor,
                    AppColors.primaryColor.withOpacity(0.75),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  AppText('Watch Video', color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                ],
              ),
            ),
          ),*/
        ],
      ),
    );
  }
}
