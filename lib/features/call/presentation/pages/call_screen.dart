import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/features/call/presentation/controllers/call_controller.dart';
import 'package:astro_astrologer/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_astrologer/features/chat/presentation/bindings/chat_binding.dart';
import 'package:astro_astrologer/core/services/network/websocket_service.dart';
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
                  // Top Bar: Status + Switch-to-Chat icon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 48), // balance right icon
                        Column(
                          children: [
                            const SizedBox(height: 32),
                            Text(
                              status == 'ongoing' ? 'Ongoing Call' : status.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (status == 'ongoing')
                              Text(
                                '$minutes:$seconds',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        // ── Switch to Chat button ──
                        if (status == 'ongoing')
                          Padding(
                            padding: const EdgeInsets.only(top: 32),
                            child: GestureDetector(
                              onTap: () => _showSwitchToChatDialog(context),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white38, width: 1.5),
                                ),
                                child: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 48),
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
                        _buildEndCallButton(onPressed: () {
                          controller.endCall();
                          Get.until((route) => route.isFirst);
                        }),

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

  // ── Switch-to-Chat confirmation dialog ─────────────────────────────────────
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
          'End the current call and start a session chat with ${controller.consumerName ?? "User"}?',
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
    final sessionId = controller.sessionId;
    final userName  = controller.consumerName ?? 'User';
    final userImage = controller.consumerImage ?? '';
    final consumerId = controller.consumerId;

    // 1. End the ongoing call
    await controller.endCall();

    // 2. Pop call screen + clear any bubble
    Get.until((route) => route.isFirst);

    // 3. Try to initiate a chat session via API
    if (consumerId != null) {
      try {
        final api = Get.find<ApiClient>();
        // Try astrologer-side initiate (may not exist on backend)
        final resp = await api.post(
          '/chat/initiate-from-call',
          body: {'consumer_id': consumerId},
        );

        if (resp.isSuccess) {
          final data   = resp.body?['data']?['session'];
          final chatId = data?['id'] as int?;
          final startedAt = data?['started_at']?.toString() ?? DateTime.now().toUtc().toIso8601String();
          if (chatId != null) {
            WebSocketService.sessionStartTimes[chatId] = startedAt;
            Get.to(
              () => ChatScreen(
                userName: userName,
                userImage: userImage,
                sessionId: chatId,
                initialStatus: 'ongoing',
                startedAtString: startedAt,
              ),
              binding: ChatBinding(),
            );
            return;
          }
        }
      } catch (_) {}
    }

    // 4. Fallback: show snackbar — chat initiated by user will auto-open via WebSocket
    Get.snackbar(
      'Call Ended',
      'Chat ke liye user ${userName} ko request karen',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primaryColor.withValues(alpha: 0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
      duration: const Duration(seconds: 5),
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
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'End',
          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
