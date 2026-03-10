import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_app_bar.dart';

class ProfileVideoScreen extends StatefulWidget {
  const ProfileVideoScreen({super.key});

  @override
  State<ProfileVideoScreen> createState() => _ProfileVideoScreenState();
}

class _ProfileVideoScreenState extends State<ProfileVideoScreen> {
  File? _videoFile;
  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      _videoFile = File(video.path);
      _initializePlayer();
    }
  }

  void _initializePlayer() async {
    if (_videoFile == null) return;

    // Dispose old controllers
    _chewieController?.dispose();
    await _videoPlayerController?.dispose();

    _videoPlayerController = VideoPlayerController.file(_videoFile!);
    await _videoPlayerController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
      aspectRatio: _videoPlayerController!.value.aspectRatio,
      materialProgressColors: ChewieProgressColors(
        playedColor: AppColors.primaryColor,
        handleColor: AppColors.primaryColor,
        backgroundColor: Colors.grey.shade300,
        bufferedColor: AppColors.primaryColor.withOpacity(0.3),
      ),
      placeholder: Container(color: Colors.black),
      autoInitialize: true,
    );

    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _showSubmitBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
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
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 30),
            const Icon(Icons.cloud_upload_outlined, color: AppColors.primaryColor, size: 60),
            const SizedBox(height: 20),
            AppText(
              'Confirm Video Upload',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2E1A47),
            ),
            const SizedBox(height: 10),
            AppText(
              'Your profile video will be visible to all users. Make sure it represents you professionally.',
              fontSize: 14,
              color: Colors.grey.shade600,
              textAlign: TextAlign.center,
              height: 1.5,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Cancel',
                    onPressed: () => Get.back(),
                    buttonType: ButtonStyleType.outlined,
                    borderColor: Colors.grey.shade300,
                    textColor: Colors.grey.shade700,
                    borderRadius: 100,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Submit Video',
                    onPressed: () {
                      Get.back(); // Close bottom sheet
                      Get.back(); // Close screen
                      Get.snackbar(
                        'Success',
                        'Profile video uploaded successfully!',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    backgroundColor: AppColors.primaryColor,
                    borderRadius: 100,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Profile Video',
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Upload an introductory video',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2E1A47),
            ),
            const SizedBox(height: 8),
            AppText(
              'Share your skills, experience, and how you help clients. A video helps build trust.',
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            const SizedBox(height: 40),
            
            // Video Preview Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: _videoFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Iconsax.video_play_copy, color: AppColors.primaryColor, size: 40),
                          ),
                          const SizedBox(height: 20),
                          AppText(
                            'No video selected',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(height: 8),
                          AppText(
                            'Videos should be under 2 minutes',
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: _chewieController != null && 
                               _chewieController!.videoPlayerController.value.isInitialized
                            ? Chewie(controller: _chewieController!)
                            : const Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
                      ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            if (_videoFile == null)
              CustomButton(
                text: 'Select Video',
                onPressed: _pickVideo,
                backgroundColor: AppColors.primaryColor,
                borderRadius: 100,
                prefixIcon: const Icon(Icons.add, color: Colors.white, size: 20),
              )
            else
              Column(
                children: [
                   CustomButton(
                    text: 'Change Video',
                    onPressed: _pickVideo,
                    buttonType: ButtonStyleType.outlined,
                    borderColor: AppColors.primaryColor,
                    textColor: AppColors.primaryColor,
                    borderRadius: 100,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Submit & Continue',
                    onPressed: _showSubmitBottomSheet,
                    backgroundColor: AppColors.primaryColor,
                    borderRadius: 100,
                  ),
                ],
              ),
              
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
