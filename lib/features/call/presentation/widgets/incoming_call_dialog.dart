import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/features/call/presentation/controllers/call_controller.dart';
import 'package:astro_astrologer/features/call/presentation/pages/call_screen.dart';
import 'package:astro_astrologer/core/utils/logger.dart';

class IncomingCallDialog extends StatelessWidget {
  final String offerSdp;

  const IncomingCallDialog({
    super.key,
    required this.offerSdp,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CallController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),

          // Dialog content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Call details
                Padding(
                  padding: const EdgeInsets.only(top: 80.0),
                  child: Column(
                    children: [
                      Text(
                        'INCOMING AUDIO CALL',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 30),
                      CircleAvatar(
                        radius: 65,
                        backgroundColor: AppColors.primaryColor.withValues(alpha: 0.2),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: controller.consumerImage != null && controller.consumerImage!.isNotEmpty
                              ? CachedNetworkImageProvider(
                                  controller.consumerImage!.startsWith('http')
                                      ? controller.consumerImage!
                                      : '${AppUrls.baseImageUrl}${controller.consumerImage!.startsWith('/') ? controller.consumerImage!.substring(1) : controller.consumerImage}'
                                )
                              : null,
                          child: controller.consumerImage == null || controller.consumerImage!.isEmpty
                              ? const Icon(Icons.person, size: 50, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        controller.consumerName ?? 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Suryapath Kundli Call Session',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Accept/Reject Actions
                Padding(
                  padding: const EdgeInsets.only(bottom: 80.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Decline button
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Logger.d('IncomingCallDialog: Decline button clicked. Calling rejectCall...');
                              controller.rejectCall();
                              Get.back(); // Close dialog
                            },
                            child: Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withValues(alpha: 0.4),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.call_end,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Decline',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      // Accept button
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              Logger.d('IncomingCallDialog: Accept button clicked. Closing dialog.');
                              Get.back(); // Pop incoming dialog
                              Logger.d('IncomingCallDialog: Calling controller.acceptCall()...');
                              final success = await controller.acceptCall(offerSdp);
                              Logger.d('IncomingCallDialog: acceptCall finished. success = $success');
                              if (success) {
                                Logger.d('IncomingCallDialog: Navigating to CallScreen.');
                                Get.to(() => const CallScreen()); // Go to active CallScreen
                              } else {
                                Logger.e('IncomingCallDialog: acceptCall failed. Will not navigate.');
                              }
                            },
                            child: Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withValues(alpha: 0.4),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.call,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Accept',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
