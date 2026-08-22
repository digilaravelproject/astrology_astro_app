import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/features/call/presentation/controllers/call_controller.dart';
import 'package:astro_astrologer/core/services/network/websocket_service.dart';
import 'package:astro_astrologer/features/chat/presentation/pages/chat_screen.dart';

import 'package:astro_astrologer/features/call/presentation/widgets/floating_call_bubble.dart';

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
    FloatingCallBubble.dismiss();
  }

  @override
  void dispose() {
    controller.isCallScreenVisible = false;
    // Minimize to bubble if the call is still active
    if (controller.status.value == 'ongoing' || 
        controller.status.value == 'ringing' || 
        controller.status.value == 'dialing') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.sessionId != null && controller.consumerName != null) {
          controller.minimizeToBubble(Get.context!, controller.consumerName!, controller.consumerImage ?? "", shouldPop: false);
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
        final minutes = (controller.durationSeconds.value ~/ 60).toString().padLeft(2, '0');
        final seconds = (controller.durationSeconds.value % 60).toString().padLeft(2, '0');

        return Stack(
          fit: StackFit.expand,
          children: [
            // Blurred profile background
            if (controller.consumerImage != null && controller.consumerImage!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: controller.consumerImage!.startsWith('http')
                    ? controller.consumerImage!
                    : '${AppUrls.baseImageUrl}${controller.consumerImage!.startsWith('/') ? controller.consumerImage!.substring(1) : controller.consumerImage}',
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(color: AppColors.primaryColor.withValues(alpha: 0.8)),
              )
            else
              Container(color: AppColors.primaryColor.withValues(alpha: 0.8)),
            
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: Colors.black.withValues(alpha: 0.4),
              ),
            ),

            // Main UI content
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Title / Timing & Switch to Chat action
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                status == 'ongoing' ? 'Ongoing Call' : status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (status == 'ongoing') ...[
                                Text(
                                  '$minutes:$seconds',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Dual-timer row — package master countdown
                                if (controller.isPackageCall)
                                  Obx(() {
                                    final rem = WebSocketService.packageRemainingSeconds.value;
                                    final m = (rem ~/ 60).toString().padLeft(2, '0');
                                    final s = (rem % 60).toString().padLeft(2, '0');
                                    return Container(
                                      margin: const EdgeInsets.only(top: 6),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.timer_outlined, color: Colors.amberAccent, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Package Left: $m:$s',
                                            style: const TextStyle(
                                              color: Colors.amberAccent,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              ],
                            ],
                          ),
                        ),
                        if (controller.isPackageCall)
                          Positioned(
                            right: 0,
                            top: 12,
                            child: IconButton(
                              icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 26),
                              tooltip: "Switch to Chat",
                              onPressed: () => _showSwitchToChatDialog(context),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Middle Profile Display
                  Column(
                    children: [
                      // Pulsing avatar
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildPulseCircle(delay: 0),
                          _buildPulseCircle(delay: 1),
                          CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.white24,
                            child: CircleAvatar(
                              radius: 66,
                              backgroundImage: controller.consumerImage != null && controller.consumerImage!.isNotEmpty
                                  ? CachedNetworkImageProvider(
                                      controller.consumerImage!.startsWith('http')
                                          ? controller.consumerImage!
                                          : '${AppUrls.baseImageUrl}${controller.consumerImage!.startsWith('/') ? controller.consumerImage!.substring(1) : controller.consumerImage}'
                                    )
                                  : null,
                              child: controller.consumerImage == null || controller.consumerImage!.isEmpty
                                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        controller.consumerName ?? 'User',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        status == 'ringing' ? 'Ringing...' : 'Connecting P2P...',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  // Bottom Controls
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Mute button
                        _buildControlButton(
                          icon: controller.isMuted.value ? Icons.mic_off : Icons.mic,
                          label: 'Mute',
                          isActive: controller.isMuted.value,
                          onPressed: () => controller.toggleMute(),
                        ),

                        // End Call (Red Button)
                        _buildEndCallButton(onPressed: () => _onEndTapped()),

                        // Speaker button
                        _buildControlButton(
                          icon: controller.isSpeakerOn.value ? Icons.volume_up : Icons.volume_down,
                          label: 'Speaker',
                          isActive: controller.isSpeakerOn.value,
                          onPressed: () => controller.toggleSpeaker(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
      controller.endCall();
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
      builder: (ctx) => Container(
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
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Title
            const Row(
              children: [
                Icon(Icons.help_outline_rounded, color: Color(0xFF6B21A8), size: 22),
                SizedBox(width: 8),
                Text(
                  'End Consultation Options',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Package time remaining: $m:$s',
                style: TextStyle(fontSize: 13, color: Colors.orange.shade700, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 20),

            // Option 1: End Call Only
            _buildEndOption(
              icon: Icons.call_end_rounded,
              iconColor: Colors.blue.shade700,
              bgColor: Colors.blue.shade50,
              title: 'End Call Only (Continue Chatting)',
              subtitle: 'Hangs up audio and returns you to the active chat thread.',
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
              title: 'End Entire Session',
              subtitle: 'Completes consultation and finalises package time.',
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
                child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 15)),
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
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('End Consultation', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to end this consultation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.terminateEntireSession();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('End Session'),
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
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
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
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.chat_bubble_rounded, color: AppColors.primaryColor, size: 22),
            SizedBox(width: 10),
            Text('Switch to Chat', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'End the current call and start a chat session with ${controller.consumerName ?? "User"}?',
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              _switchToChat();
            },
            icon: const Icon(Icons.chat_bubble_rounded, size: 16),
            label: const Text('Switch'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    Get.dialog(const Center(child: CircularProgressIndicator(color: AppColors.primaryColor)), barrierDismissible: false);

    try {
      final apiClient = Get.find<ApiClient>();
      Map<String, dynamic> spawnData = {};

      if (subSessionId > 0 && controller.isPackageCall) {
        final response = await apiClient.post(
          AppUrls.packageSpawnChannel,
          data: {
            'sub_session_id': subSessionId,
            'channel_type': 'chat',
          },
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

      final activeChatSessionId = int.tryParse(spawnData['chat_session_id']?.toString() ?? '') ?? 0;
      
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
