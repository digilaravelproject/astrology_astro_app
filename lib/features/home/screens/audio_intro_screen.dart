import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_app_bar.dart';

class AudioIntroScreen extends StatefulWidget {
  const AudioIntroScreen({super.key});

  @override
  State<AudioIntroScreen> createState() => _AudioIntroScreenState();
}

class _AudioIntroScreenState extends State<AudioIntroScreen> {
  File? _audioFile;
  bool isPlaying = false;

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      setState(() {
        _audioFile = File(result.files.single.path!);
      });
    }
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
            const Icon(Icons.mic_none_outlined, color: AppColors.primaryColor, size: 60),
            const SizedBox(height: 20),
            AppText(
              'Confirm Audio Upload',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2E1A47),
            ),
            const SizedBox(height: 10),
            AppText(
              'Your audio introduction will help users trust you more. Make sure it is clear and professional.',
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
                    text: 'Submit Audio',
                    onPressed: () {
                      Get.back(); // Close bottom sheet
                      Get.back(); // Close screen
                      Get.snackbar(
                        'Success',
                        'Audio introduction uploaded successfully!',
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
        title: 'Audio Introduction',
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Record or upload your voice',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2E1A47),
            ),
            const SizedBox(height: 8),
            AppText(
              'Vocal introductions increase consultation rates by up to 50%. Speak clearly about your expertise.',
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            const SizedBox(height: 40),
            
            // Audio Preview Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: _audioFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Iconsax.microphone_2_copy, color: AppColors.primaryColor, size: 40),
                          ),
                          const SizedBox(height: 20),
                          AppText(
                            'No audio selected',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(height: 8),
                          AppText(
                            'Audio should be clear and under 60 seconds',
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.audiotrack_rounded, color: AppColors.primaryColor, size: 60),
                          ),
                          const SizedBox(height: 24),
                          AppText(
                            _audioFile!.path.split('/').last,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2E1A47),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => isPlaying = !isPlaying),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            if (_audioFile == null)
              CustomButton(
                text: 'Select Audio',
                onPressed: _pickAudio,
                backgroundColor: AppColors.primaryColor,
                borderRadius: 100,
                prefixIcon: const Icon(Icons.add, color: Colors.white, size: 20),
              )
            else
              Column(
                children: [
                   CustomButton(
                    text: 'Change Audio',
                    onPressed: _pickAudio,
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
