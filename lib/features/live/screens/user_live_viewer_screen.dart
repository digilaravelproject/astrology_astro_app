import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
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

class UserLiveViewerScreen extends StatefulWidget {
  final int sessionId;
  final String title;
  final String astrologerName;
  final String astrologerImage;

  const UserLiveViewerScreen({
    super.key,
    required this.sessionId,
    required this.title,
    required this.astrologerName,
    required this.astrologerImage,
  });

  @override
  State<UserLiveViewerScreen> createState() => _UserLiveViewerScreenState();
}

class _UserLiveViewerScreenState extends State<UserLiveViewerScreen> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  final RxInt viewerCount = 0.obs;
  final RxList<Map<String, dynamic>> comments = <Map<String, dynamic>>[].obs;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

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
    _joinLiveSession();
    _initVideoPlayer();
    _subscribeToWebSockets();
  }

  Future<void> _joinLiveSession() async {
    try {
      final apiClient = Get.find<ApiClient>();
      // POST /api/v1/user/live/{id}/join
      await apiClient.post('/user/live/${widget.sessionId}/join');
    } catch (e) {
      debugPrint("Error joining live session API: $e");
    }
  }

  void _initVideoPlayer() {
    // Standard high-fidelity sample stream URL
    const String sampleStreamUrl = 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';
    
    _videoController = VideoPlayerController.networkUrl(Uri.parse(sampleStreamUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
          _videoController?.setLooping(true);
          _videoController?.play();
        }
      }).catchError((e) {
        debugPrint("Error initializing video player: $e");
      });
  }

  void _subscribeToWebSockets() {
    final wsService = Get.find<WebSocketService>();
    wsService.subscribeToLiveSession(widget.sessionId);

    _wsSubscription = WebSocketService.liveSessionEvent.stream.listen((event) {
      final String? ch = event['channel'];
      if (ch != 'presence-live-session.${widget.sessionId}') return;
      
      final String? ev = event['event'];
      final dynamic payload = event['data'];
      
      debugPrint("[LIVE_WS_VIEWER] Event: $ev, Payload: $payload");
      
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
  }

  void _handleSuperChat(dynamic payload) {
    if (payload == null) return;
    
    // Add to comment list
    comments.add({
      'user_name': payload['user_name'] ?? 'Viewer',
      'user_avatar': payload['user_avatar'] ?? '',
      'message': payload['message'] ?? '',
      'amount': payload['amount']?.toString() ?? '0',
      'is_super_chat': true,
    });

    // Show flying overlay banner
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

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    
    _commentController.clear();
    _commentFocusNode.unfocus();
    
    try {
      final apiClient = Get.find<ApiClient>();
      // POST /api/v1/user/live/{id}/comment
      final response = await apiClient.post(
        '/user/live/${widget.sessionId}/comment',
        data: {'message': text},
      );
      if (!response.isSuccess) {
        CustomSnackBar.showError("Could not send comment");
      }
    } catch (e) {
      debugPrint("Error sending comment API: $e");
    }
  }

  void _showSuperChatDialog() {
    final amountController = TextEditingController(text: '50');
    final messageController = TextEditingController();
    final RxString selectedAmount = '50'.obs;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Iconsax.star_copy, color: Color(0xFFFF6F00), size: 24),
            const SizedBox(width: 8),
            const AppText('Send Super Chat', fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF2E1A47)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText('Select Tip Amount', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey),
              const SizedBox(height: 12),
              
              // Standard amounts selector
              Obx(() => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: ['20', '50', '100', '200', '500'].map((amt) {
                  final bool isSelected = selectedAmount.value == amt;
                  return InkWell(
                    onTap: () {
                      selectedAmount.value = amt;
                      amountController.text = amt;
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFF6F00) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFF6F00) : Colors.transparent,
                        ),
                      ),
                      child: AppText(
                        '₹$amt',
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
              )),
              
              const SizedBox(height: 16),
              
              // Custom Amount TextField
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  onChanged: (val) => selectedAmount.value = val,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: 'Enter custom amount...',
                    prefixText: '₹ ',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Super chat message
              const AppText('Message', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: messageController,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Add a message (optional)...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: AppText('Cancel', color: Colors.grey.shade600, fontWeight: FontWeight.w600),
          ),
          ElevatedButton(
            onPressed: () {
              final amountStr = amountController.text.trim();
              final amount = int.tryParse(amountStr) ?? 0;
              if (amount <= 0) {
                CustomSnackBar.showError('Please enter a valid amount');
                return;
              }
              Get.back();
              _sendSuperChat(amount, messageController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6F00),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const AppText('Send Tip', color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _sendSuperChat(int amount, String message) async {
    // Show loader
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    
    try {
      final apiClient = Get.find<ApiClient>();
      // POST /api/v1/user/live/{id}/super-chat
      final response = await apiClient.post(
        '/user/live/${widget.sessionId}/super-chat',
        data: {
          'amount': amount,
          'message': message.isEmpty ? 'Super Chat!' : message,
        },
      );
      
      Get.back(); // Dismiss loader
      
      if (response.isSuccess) {
        CustomSnackBar.showSuccess('Super Chat sent!');
      } else if (response.statusCode == 402) {
        // Insufficient balance
        _showRechargeDialog();
      } else {
        ApiChecker.handleResponse(response);
      }
    } catch (e) {
      Get.back(); // Dismiss loader
      CustomSnackBar.showError('Could not send Super Chat: $e');
    }
  }

  void _showRechargeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const AppText('Insufficient Balance', fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
        content: const AppText('You do not have enough balance in your wallet. Please recharge to continue.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Cancel', color: Colors.grey),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Navigate to recharge page
              CustomSnackBar.showInfo("Redirecting to recharge wallet...");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const AppText('Recharge Now', color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _leaveLiveSession() async {
    try {
      final apiClient = Get.find<ApiClient>();
      // POST /api/v1/user/live/{id}/leave
      await apiClient.post('/user/live/${widget.sessionId}/leave');
    } catch (e) {
      debugPrint("Error leaving live session API: $e");
    }
    Get.back();
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _superChatTimer?.cancel();
    Get.find<WebSocketService>().unsubscribeFromLiveSession(widget.sessionId);
    _videoController?.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Video Player
          Positioned.fill(
            child: _isVideoInitialized
                ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController!.value.size.width,
                        height: _videoController!.value.size.height,
                        child: VideoPlayer(_videoController!),
                      ),
                    ),
                  )
                : Container(
                    color: const Color(0xFF161616),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 90,
                            width: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(widget.astrologerImage),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppText(
                            "Waiting for ${widget.astrologerName}...",
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(height: 8),
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // Gradient Overlay
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

          // 2. Top Bar (Astrologer profile, Viewer count, Close button)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // Profile & Name
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(widget.astrologerImage),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppText(
                            widget.astrologerName,
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 4),
                              const AppText('LIVE', color: Colors.white70, fontSize: 8, fontWeight: FontWeight.bold),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Viewers badge
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
                
                // Close button
                GestureDetector(
                  onTap: _leaveLiveSession,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
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
              padding: EdgeInsets.fromLTRB(16, 20, 16, MediaQuery.of(context).viewInsets.bottom + 30),
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
                    height: 180,
                    child: Obx(() {
                      if (comments.isEmpty) {
                        return const Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: AppText(
                              'Say hello in the chat...',
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

                  const SizedBox(height: 12),

                  // Comment Input bar + Super Chat option
                  Row(
                    children: [
                      // Textfield
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 14),
                              Expanded(
                                child: TextField(
                                  controller: _commentController,
                                  focusNode: _commentFocusNode,
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                  decoration: const InputDecoration(
                                    hintText: 'Type a message...',
                                    hintStyle: TextStyle(color: Colors.white30),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onSubmitted: (_) => _sendComment(),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.send_rounded, color: AppColors.primaryColor, size: 20),
                                onPressed: _sendComment,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Super Chat golden button
                      GestureDetector(
                        onTap: _showSuperChatDialog,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF8F00), Color(0xFFFF6F00)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
                            ],
                          ),
                          child: const Icon(Iconsax.star_copy, color: Colors.white, size: 22),
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
}
