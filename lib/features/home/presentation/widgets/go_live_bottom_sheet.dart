import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/widgets/app_text.dart';
import 'package:astro_astrologer/features/live/presentation/controllers/live_controller.dart';
import 'package:astro_astrologer/routes/app_routes.dart';

void showGoLiveBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder:
        (context) => SafeArea(
          top: false,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 25),
                AppText('Go Live'.tr,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2E1A47),
                ),
                const SizedBox(height: 12),
                AppText('Would you like to go live instantly or schedule it for later?'.tr,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                Obx(() {
                  final liveController = Get.find<LiveController>();
                  final isCreating = liveController.isCreating.value;

                  return SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed:
                          isCreating
                              ? null
                              : () {
                                liveController.createSession(
                                  title: "Instant Live Session".tr,
                                  description: "Broadcasting Live",
                                  sessionType: "public",
                                  duration: 60,
                                  maxParticipants: 100,
                                  isInstant: true,
                                );
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF4CAF50,
                        ), // Green for Go Live
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child:
                          isCreating
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : AppText('Go Live Instantly'.tr,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                    ),
                  );
                }),

                const SizedBox(height: 12),

                // Schedule for Later Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    onPressed: () {
                      Get.back();
                      Get.toNamed(AppRoutes.liveSchedule);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF2196F3),
                        width: 1.5,
                      ), // Blue for Schedule
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: AppText('Schedule for Later'.tr,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2196F3),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
  );
}
