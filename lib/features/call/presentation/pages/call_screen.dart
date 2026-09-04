import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:astro_astrologer/core/widgets/custom_image_widget.dart';
import 'package:astro_astrologer/core/enums/session_status_enums.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/features/call/presentation/controllers/call_controller.dart';
import 'package:astro_astrologer/core/services/websocket/websocket_service.dart';
import 'package:astro_astrologer/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';

import 'package:astro_astrologer/features/call/presentation/widgets/floating_call_bubble.dart';
import 'package:astro_astrologer/core/widgets/network_ping_indicator.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late final CallController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<CallController>();
    controller.isCallScreenVisible = true;
    // Use postFrameCallback to avoid setState-during-build error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FloatingCallBubble.dismiss(stopForegroundService: false);
    });
  }

  @override
  void dispose() {
    controller.isCallScreenVisible = false;
    // Minimize to bubble if the call is still active
    if (controller.status.value.name == 'ongoing' ||
        controller.status.value.name == 'ringing' ||
        controller.status.value.name == 'dialing') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.sessionId != null && controller.consumerName != null) {
          controller.minimizeToBubble(
            Get.context!,
            controller.consumerName!,
            controller.consumerImage ?? "",
            shouldPop: false,
          );
        }
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final status = controller.status.value;
        final minutes = (controller.durationSeconds.value ~/ 60)
            .toString()
            .padLeft(2, '0');
        final seconds = (controller.durationSeconds.value % 60)
            .toString()
            .padLeft(2, '0');

        return Stack(
          fit: StackFit.expand,
          children: [
            // Blurred profile background image
            if (controller.consumerImage != null &&
                controller.consumerImage!.isNotEmpty)
              CustomImageWidget(
                imagePath:
                    controller.consumerImage!.startsWith('http')
                        ? controller.consumerImage!
                        : '${AppUrls.baseImageUrl}${controller.consumerImage!.startsWith('/') ? controller.consumerImage!.substring(1) : controller.consumerImage}',
                fit: BoxFit.cover,
                fallbackWidget: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2E1A47), Color(0xFF1A0E2E)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              )
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E1A47), Color(0xFF1A0E2E)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

            // Soft overlay blur mapping
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(color: Colors.black.withValues(alpha: 0.55)),
            ),

            // Top-down smooth dark shadow overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Main Content Layout - No strict SafeArea at top to make it look full screen
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Bar: Call Status / Sub-Title / Timer
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 56.0,
                  ), // Top margin adjusted for full-screen status overlay
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.15),
                                ),
                              ),
                              child: Text(
                                status == CallStatus.ongoing
                                    ? 'Ongoing Call'
                                    : status.name.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (status == CallStatus.ongoing) ...[
                              Text(
                                '$minutes:$seconds',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 38,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Obx(() => NetworkPingIndicator(
                              pingMs: controller.currentPingMs.value,
                            )),
                      ),
                    ],
                  ),
                ),

                // Middle Area: Pulsing profile image with premium borders
                Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildPulseCircle(delay: 0),
                        _buildPulseCircle(delay: 1),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.4),
                                Colors.white.withValues(alpha: 0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 76,
                            backgroundColor: Colors.black26,
                            child: CircleAvatar(
                              radius: 72,
                              backgroundImage:
                                  controller.consumerImage != null &&
                                          controller.consumerImage!.isNotEmpty
                                      ? CachedNetworkImageProvider(
                                        controller.consumerImage!.startsWith(
                                              'http',
                                            )
                                            ? controller.consumerImage!
                                            : '${AppUrls.baseImageUrl}${controller.consumerImage!.startsWith('/') ? controller.consumerImage!.substring(1) : controller.consumerImage}',
                                      )
                                      : null,
                              child:
                                  controller.consumerImage == null ||
                                          controller.consumerImage!.isEmpty
                                      ? const Icon(
                                        Icons.person,
                                        size: 68,
                                        color: Colors.white70,
                                      )
                                      : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      controller.consumerName ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      status == CallStatus.ringing
                          ? 'Incoming Audio Call'
                          : 'Connecting P2P...',
                      style: TextStyle(
                        color:
                            status == CallStatus.ringing
                                ? AppColors.primaryColor
                                : Colors.white.withValues(alpha: 0.7),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),

                // Bottom Controls Panel
                if (status == CallStatus.ringing) ...[
                  // ── Incoming ringing: show Accept / Decline ──
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Decline button
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                controller.rejectCall();
                                Get.back();
                              },
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withValues(alpha: 0.4),
                                      blurRadius: 18,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.call_end,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text('Decline'.tr,
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
                                String sdp = controller.incomingOfferSdp ?? '';
                                if (sdp.isEmpty &&
                                    controller.sessionId != null) {
                                  sdp =
                                      await controller
                                          .fetchOfferSdpFromCurrentSession() ??
                                      '';
                                }
                                if (sdp.isEmpty) return;
                                final success = await controller.acceptCall(
                                  sdp,
                                );
                                if (success) {
                                  // Already on CallScreen — just pop dialog overlay if open
                                  if (Get.isDialogOpen == true) Get.back();
                                } else {
                                  Get.back();
                                }
                              },
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 18,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.call,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text('Accept'.tr,
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
                ] else ...[
                  // ── Active / ongoing call controls ──
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Mute button
                        _buildControlButton(
                          icon:
                              controller.isMuted.value
                                  ? Icons.mic_off
                                  : Icons.mic,
                          label: 'Mute'.tr,
                          isActive: controller.isMuted.value,
                          onPressed: () => controller.toggleMute(),
                        ),

                        // Switch to Chat (visible during ongoing call)
                        if (controller.isPackageCall)
                          _buildControlButton(
                            icon: Icons.swap_calls_rounded,
                            label: 'Chat'.tr,
                            isActive: false,
                            onPressed: () => _showSwitchToChatDialog(context),
                          ),

                        _buildEndCallButton(onPressed: () => _onEndTapped()),

                        // Speaker button
                        _buildControlButton(
                          icon:
                              controller.isSpeakerOn.value
                                  ? Icons.volume_up
                                  : Icons.volume_down,
                          label: 'Speaker'.tr,
                          isActive: controller.isSpeakerOn.value,
                          onPressed: () => controller.toggleSpeaker(),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPulseCircle({required int delay}) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 1.0, end: 1.8),
      duration: Duration(seconds: 2 + delay),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Container(
          width: 140 * value,
          height: 140 * value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: (0.15 * (2.0 - value))),
          ),
        );
      },
      onEnd: () {},
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.white : Colors.white12,
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(
              icon,
              color: isActive ? AppColors.primaryColor : Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildEndCallButton({required VoidCallback onPressed}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 75,
            height: 75,
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
            child: const Icon(Icons.call_end, color: Colors.white, size: 36),
          ),
        ),
        const SizedBox(height: 8),
        Text('End'.tr,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Decides which end dialog to show based on session state
  void _onEndTapped() {
    if (controller.isPackageCall) {
      if (controller.isChatAlsoActive) {
        _showGranularEndModal(context);
      } else {
        _showSingleEndDialog(context);
      }
    } else {
      // Normal (non-package) call
      if (controller.status.value.name == 'ringing' ||
          controller.status.value.name == 'dialing' ||
          controller.status.value.name == 'waiting') {
        controller.rejectCall();
      } else {
        controller.endCall();
      }
    }
  }

  /// Case A: Both Chat + Call active — 3-option granular modal
  void _showGranularEndModal(BuildContext context) {
    final rem = WebSocketService.packageRemainingSeconds.value;
    final m = (rem ~/ 60).toString().padLeft(2, '0');
    final s = (rem % 60).toString().padLeft(2, '0');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // Title
                Row(
                  children: [
                    Icon(
                      Icons.help_outline_rounded,
                      color: Color(0xFF6B21A8),
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Text('End Consultation Options'.tr,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Package time remaining: $m:$s',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Option 1: End Call Only
                _buildEndOption(
                  icon: Icons.call_end_rounded,
                  iconColor: Colors.blue.shade700,
                  bgColor: Colors.blue.shade50,
                  title: 'End Call Only (Continue Chatting)'.tr,
                  subtitle: 'Hangs up audio and returns you to the active chat thread.'.tr,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    controller.terminateChannelOnly();
                  },
                ),
                const SizedBox(height: 12),

                // Option 2: End Entire Session
                _buildEndOption(
                  icon: Icons.cancel_rounded,
                  iconColor: Colors.red,
                  bgColor: Colors.red.shade50,
                  title: 'End Entire Session'.tr,
                  subtitle: 'Completes consultation and finalises package time.'.tr,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    controller.terminateEntireSession();
                  },
                ),
                const SizedBox(height: 12),

                // Option 3: Cancel
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text('Cancel'.tr,
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  /// Case B: Call only (no active chat) — simple confirmation
  void _showSingleEndDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text('End Consultation'.tr,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text('Are you sure you want to end this consultation?'.tr,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Cancel'.tr,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  controller.terminateEntireSession();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('End Session'.tr),
              ),
            ],
          ),
    );
  }

  Widget _buildEndOption({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: iconColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _showSwitchToChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.chat_bubble_rounded,
                  color: AppColors.primaryColor,
                  size: 22,
                ),
                SizedBox(width: 10),
                Text('Switch to Chat'.tr,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              'End the current call and start a chat session with ${controller.consumerName ?? "User"}?',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Cancel'.tr,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _switchToChat();
                },
                icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                label: Text('Switch'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _switchToChat() async {
    final subSessionId = controller.subSessionId ?? 0;
    final consumerName = controller.consumerName ?? 'User';
    final consumerImage = controller.consumerImage ?? '';

    // Show loader
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      ),
      barrierDismissible: false,
    );

    try {
      final apiClient = Get.find<ApiClient>();
      Map<String, dynamic> spawnData = {};

      if (subSessionId > 0 && controller.isPackageCall) {
        final response = await apiClient.post(
          AppUrls.packageSpawnChannel,
          data: {'sub_session_id': subSessionId, 'channel_type': 'chat'},
        );
        if (response.isSuccess) {
          spawnData = response.body is Map ? response.body['data'] ?? {} : {};
        }
        controller.cleanUp();
      }

      if (Get.isDialogOpen ?? false) Get.back(); // Dismiss loader

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      final activeChatSessionId =
          int.tryParse(spawnData['chat_session_id']?.toString() ?? '') ?? 0;

      Get.to(
        () => ChatScreen(
          userName: consumerName,
          userImage: consumerImage,
          sessionId: activeChatSessionId,
          initialStatus: spawnData['chat_status']?.toString() ?? 'ongoing',
        ),
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      CustomSnackBar.showError("Failed to switch: $e");
    }
  }
}
