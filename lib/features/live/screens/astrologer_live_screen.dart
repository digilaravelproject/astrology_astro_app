import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' hide navigator;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/services/network/websocket_service.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/services/network/api_checker.dart';
import '../../../core/constants/app_urls.dart';
import '../../../core/utils/custom_snackbar.dart';

class AstrologerLiveScreen extends StatefulWidget {
  final int sessionId;
  final String title;
  final String? streamKey;

  const AstrologerLiveScreen({
    super.key,
    required this.sessionId,
    required this.title,
    this.streamKey,
  });

  @override
  State<AstrologerLiveScreen> createState() => _AstrologerLiveScreenState();
}

class _AstrologerLiveScreenState extends State<AstrologerLiveScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  bool _isMuted = false;
  bool _isCameraOff = false;
  
  final RxInt viewerCount = 0.obs;
  final RxList<Map<String, dynamic>> comments = <Map<String, dynamic>>[].obs;
  
  // Super Chat Overlay State
  final RxBool showSuperChatOverlay = false.obs;
  final RxString superChatSenderName = ''.obs;
  final RxString superChatAmount = ''.obs;
  final RxString superChatText = ''.obs;
  final RxString superChatAvatar = ''.obs;
  Timer? _superChatTimer;

  StreamSubscription? _wsSubscription;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _subscribeToWebSockets();
  }

  Future<void> _initCamera() async {
    await _localRenderer.initialize();
    try {
      final Map<String, dynamic> mediaConstraints = {
        'audio': true,
        'video': {
          'facingMode': 'user', // front camera
          'width': '640',
          'height': '480',
        },
      };
      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Error opening local stream: $e");
      CustomSnackBar.showError("Could not access camera/microphone");
    }
  }

  void _subscribeToWebSockets() {
    final wsService = Get.find<WebSocketService>();
    wsService.subscribeToLiveSession(widget.sessionId);

    _wsSubscription = WebSocketService.liveSessionEvent.stream.listen((event) {
      final String? ch = event['channel'];
      if (ch != 'presence-live-session.${widget.sessionId}') return;
      
      final String? ev = event['event'];
      final dynamic payload = event['data'];
      
      debugPrint("[LIVE_WS] Event: $ev, Payload: $payload");
      
      if (ev == 'NewLiveComment' || ev == 'App\\Events\\NewLiveComment') {
        _addComment(payload);
      } else if (ev == 'SuperChatReceived' || ev == 'App\\Events\\SuperChatReceived') {
        _handleSuperChat(payload);
      } else if (ev == 'pusher_internal:subscription_succeeded' || ev == 'pusher:subscription_succeeded') {
        try {
          final presence = payload['presence'];
          if (presence != null && presence['count'] != null) {
            viewerCount.value = presence['count'];
          }
        } catch (e) {
          debugPrint("Error parsing subscription succeeded: $e");
        }
      } else if (ev == 'pusher_internal:member_added') {
        viewerCount.value++;
      } else if (ev == 'pusher_internal:member_removed') {
        if (viewerCount.value > 0) {
          viewerCount.value--;
        }
      }
    });
  }

  void _addComment(dynamic payload) {
    if (payload == null) return;
    comments.add({
      'user_name': payload['user_name'] ?? 'Viewer',
      'user_avatar': payload['user_avatar'] ?? '',
      'message': payload['message'] ?? '',
      'is_super_chat': false,
    });
    // Scroll handling is done implicitly via ListView.builder item list size updates
  }

  void _handleSuperChat(dynamic payload) {
    if (payload == null) return;
    
    // Add to comment list as a special super chat item
    comments.add({
      'user_name': payload['user_name'] ?? 'Viewer',
      'user_avatar': payload['user_avatar'] ?? '',
      'message': payload['message'] ?? '',
      'amount': payload['amount']?.toString() ?? '0',
      'is_super_chat': true,
    });

    // Display flying overlay banner
    superChatSenderName.value = payload['user_name'] ?? 'Viewer';
    superChatAmount.value = '₹${payload['amount']?.toString() ?? '0'}';
    superChatText.value = payload['message'] ?? '';
    superChatAvatar.value = payload['user_avatar'] ?? '';
    
    showSuperChatOverlay.value = true;
    
    _superChatTimer?.cancel();
    _superChatTimer = Timer(const Duration(seconds: 6), () {
      showSuperChatOverlay.value = false;
    });
  }

  Future<void> _endLiveSession() async {
    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const AppText('End Live Stream?', fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF2E1A47)),
        content: const AppText('Are you sure you want to end this live streaming session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: AppText('Keep Streaming', color: Colors.grey.shade600, fontWeight: FontWeight.w600),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const AppText('End Stream', color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );

    if (shouldEnd == true) {
      // Show loader
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      try {
        final apiClient = Get.find<ApiClient>();
        final response = await apiClient.post('${AppUrls.liveSessions}/${widget.sessionId}/stop');
        
        Get.back(); // Dismiss loader
        
        if (response.isSuccess) {
          CustomSnackBar.showSuccess("Live Session completed successfully!");
          Get.back();
        } else {
          ApiChecker.handleResponse(response);
          Get.back();
        }
      } catch (e) {
        Get.back(); // Dismiss loader
        CustomSnackBar.showError("Error ending session: $e");
        Get.back();
      }
    }
  }

  void _toggleMute() {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        final newState = !_isMuted;
        audioTracks[0].enabled = !newState;
        setState(() => _isMuted = newState);
      }
    }
  }

  void _toggleCamera() {
    if (_localStream != null) {
      final videoTracks = _localStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        final newState = !_isCameraOff;
        videoTracks[0].enabled = !newState;
        setState(() => _isCameraOff = newState);
      }
    }
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _superChatTimer?.cancel();
    Get.find<WebSocketService>().unsubscribeFromLiveSession(widget.sessionId);
    _localRenderer.dispose();
    _localStream?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera View
          Positioned.fill(
            child: _localStream != null && !_isCameraOff
                ? RTCVideoView(
                    _localRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    mirror: true,
                  )
                : Container(
                    color: const Color(0xFF1E1E1E),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isCameraOff ? Iconsax.video_slash_copy : Iconsax.video_copy,
                            color: Colors.white30,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          AppText(
                            _isCameraOff ? "Camera is off" : "Starting camera...",
                            color: Colors.white54,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // Gradient Overlay (Darken top & bottom for overlay legibility)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black54,
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black87,
                  ],
                  stops: [0.0, 0.25, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // 2. Top Bar (Live Indicator, Viewer Count, Close button)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // Live Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const AppText(
                    'LIVE',
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(width: 10),
                
                // Viewers count badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.remove_red_eye, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Obx(() => AppText(
                            '${viewerCount.value}',
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          )),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Stream Key Display if needed (Subtle)
                if (widget.streamKey != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AppText(
                      'Key: ${widget.streamKey!.substring(0, widget.streamKey!.length > 6 ? 6 : widget.streamKey!.length)}...',
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),

          // 3. Super Chat Flashy Overlay
          Obx(() {
            if (!showSuperChatOverlay.value) return const SizedBox.shrink();
            return Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 20,
              right: 20,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 400),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                curve: Curves.elasticOut,
                builder: (context, val, child) {
                  return Transform.scale(
                    scale: val,
                    child: Opacity(
                      opacity: val.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8F00), Color(0xFFFF6F00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6F00).withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          color: Colors.white24,
                        ),
                        child: ClipOval(
                          child: superChatAvatar.value.isNotEmpty
                              ? Image.network(
                                  superChatAvatar.value,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white),
                                )
                              : const Icon(Icons.person, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppText(
                                  superChatSenderName.value,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: AppText(
                                    superChatAmount.value,
                                    color: const Color(0xFFFF6F00),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            AppText(
                              superChatText.value,
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // 4. Comments Feed Overlay & controls at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Comments area
                  SizedBox(
                    height: 200,
                    child: Obx(() {
                      if (comments.isEmpty) {
                        return const Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: AppText(
                              'Comments will appear here...',
                              color: Colors.white38,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: comments.length,
                        physics: const BouncingScrollPhysics(),
                        reverse: true, // Show newest comments at bottom
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          // reverse indexing for bottom alignment
                          final comment = comments[comments.length - 1 - index];
                          final bool isSuper = comment['is_super_chat'] ?? false;
                          
                          if (isSuper) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6F00).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFFF6F00).withOpacity(0.5)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Iconsax.star_copy, color: Color(0xFFFF6F00), size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            AppText(
                                              comment['user_name'],
                                              color: const Color(0xFFFF6F00),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                            const Spacer(),
                                            AppText(
                                              '₹${comment['amount']}',
                                              color: const Color(0xFFFF6F00),
                                              fontWeight: FontWeight.w900,
                                              fontSize: 13,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        AppText(
                                          comment['message'],
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  '${comment['user_name']}: ',
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                                Expanded(
                                  child: AppText(
                                    comment['message'],
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  ),

                  const SizedBox(height: 20),

                  // Streaming controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Camera Mute
                      _buildControlBtn(
                        icon: _isCameraOff ? Iconsax.video_slash_copy : Iconsax.video_copy,
                        isActive: _isCameraOff,
                        onTap: _toggleCamera,
                      ),
                      
                      // Audio Mute
                      _buildControlBtn(
                        icon: _isMuted ? Iconsax.microphone_slash_1_copy : Iconsax.microphone_2_copy,
                        isActive: _isMuted,
                        onTap: _toggleMute,
                      ),
                      
                      const SizedBox(width: 20),
                      
                      // Stop Stream Button
                      GestureDetector(
                        onTap: _endLiveSession,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 28),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBtn({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.black45,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.black : Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
