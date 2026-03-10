import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';

class AudioRecordScreen extends StatefulWidget {
  const AudioRecordScreen({Key? key}) : super(key: key);

  @override
  State<AudioRecordScreen> createState() => _AudioRecordScreenState();
}

class _AudioRecordScreenState extends State<AudioRecordScreen> with SingleTickerProviderStateMixin {
  bool isRecording = false;
  Duration duration = Duration.zero;
  Timer? timer;
  late AnimationController pulseController;

  @override
  void initState() {
    super.initState();
    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    timer?.cancel();
    pulseController.dispose();
    super.dispose();
  }

  void startRecording() {
    setState(() {
      isRecording = true;
      duration = Duration.zero;
    });
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        duration = Duration(seconds: duration.inSeconds + 1);
      });
    });
  }

  void stopRecording() {
    timer?.cancel();
    setState(() {
      isRecording = false;
    });
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(d.inMinutes.remainder(60));
    String seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Record Introduction',
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          AppText(
            isRecording ? 'Recording...' : 'Tap to Record',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
          const SizedBox(height: 10),
          AppText(
            'Keep your voice clear and professional',
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          const Spacer(),
          
          // Timer
          AppText(
            formatDuration(duration),
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFFFA2A2),
          ),
          
          const SizedBox(height: 30),
          
          // Mock Waveform
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(20, (index) {
              return ScaleTransition(
                scale: isRecording 
                  ? Tween(begin: 0.5, end: 1.5).animate(
                      CurvedAnimation(
                        parent: pulseController, 
                        curve: Interval(index / 20, 1.0, curve: Curves.easeInOut)
                      )
                    )
                  : const AlwaysStoppedAnimation(1.0),
                child: Container(
                  width: 4,
                  height: 30 + (index % 5 * 10).toDouble(),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA2A2).withOpacity(isRecording ? 1.0 : 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          
          const Spacer(),
          
          // Record Button
          GestureDetector(
            onTap: isRecording ? stopRecording : startRecording,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isRecording ? Colors.red.shade400 : const Color(0xFFFFA2A2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isRecording ? Colors.red : const Color(0xFFFFA2A2)).withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: isRecording ? 10 : 0,
                  ),
                ],
              ),
              child: Icon(
                isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
          
          const SizedBox(height: 50),
          
          // Submit Button (Using CustomButton from core/widgets)
          Padding(
            padding: const EdgeInsets.all(20),
            child: CustomButton(
              text: 'Submit Recording',
              onPressed: () {
                if (duration.inSeconds > 0 && !isRecording) {
                  Get.back();
                  Get.back();
                  Get.snackbar(
                    'Success', 
                    'Audio submitted successfully!',
                    backgroundColor: Colors.black87,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(20),
                  );
                }
              },
              backgroundColor: duration.inSeconds > 0 && !isRecording ? AppColors.primaryColor : Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
