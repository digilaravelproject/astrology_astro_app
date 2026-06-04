import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/core/widgets/app_text.dart';
import 'package:astro_astrologer/core/widgets/custom_app_bar.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/features/chat/presentation/controllers/chat_controller.dart';
import 'package:astro_astrologer/features/chat/domain/entities/chat_message.dart';
import 'package:astro_astrologer/features/chat/presentation/widgets/floating_chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String userName;
  final String userImage;
  final int sessionId;
  final String initialStatus;
  final String? startedAtString;

  const ChatScreen({
    super.key,
    required this.userName,
    required this.userImage,
    required this.sessionId,
    required this.initialStatus,
    this.startedAtString,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late final ChatController _controller;
  late AnimationController _pulseController;
  late AnimationController _dotController;
  late Animation<double> _pulse1;
  late Animation<double> _pulse2;
  late Animation<double> _pulse3;

  @override
  void initState() {
    super.initState();
    // Dismiss floating bubble if active
    if (FloatingChatBubble.isActive) {
      FloatingChatBubble.dismiss();
    }
    // Retrieve or instantiate controller
    _controller = Get.find<ChatController>();
    _controller.initSession(
      sessionId: widget.sessionId,
      currentUserId: 0,
      initialStatus: widget.initialStatus,
      userName: widget.userName,
      startedAtString: widget.startedAtString,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _pulse1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _pulse2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOut),
      ),
    );
    _pulse3 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_controller.status.value == 'ongoing') {
          _controller.minimizeToBubble(
            context,
            widget.userName,
            widget.userImage,
            shouldPop: false,
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: CustomAppBar(
          title: widget.userName,
          centerTitle: false,
          showLeading: true,
          onLeadingPressed: () {
            if (_controller.status.value == 'ongoing') {
              _controller.minimizeToBubble(
                context,
                widget.userName,
                widget.userImage,
              );
            } else {
              Navigator.of(context).pop();
            }
          },
          actions: [
            Obx(() {
              if (_controller.status.value == 'ongoing') {
                return TextButton(
                  onPressed: () => _showEndChatConfirmation(context),
                  child: const AppText(
                    "End Chat",
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
        body: Column(
          children: [
            // Timer / Status Bar
            Obx(() {
              final seconds = _controller.elapsedSeconds.value;
              final status = _controller.status.value.toLowerCase();
              final isEnded = status == 'ended' || status == 'completed' || status == 'cancelled' || status == 'rejected';
              final isInitiated = status == 'initiated';

              if (isInitiated) return const SizedBox.shrink();

              String statusText = "Chat has ended";
              if (status == 'ongoing') {
                statusText = "Chat in progress • ${_formatDuration(seconds)} mins";
              } else if (status == 'cancelled') {
                statusText = "Chat Cancelled";
              } else if (status == 'rejected') {
                statusText = "Chat Rejected";
              } else if (status == 'completed') {
                statusText = "Chat Completed";
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: isEnded ? Colors.grey.shade300 : AppColors.lightPink.withOpacity(0.3),
                child: Center(
                  child: AppText(
                    statusText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isEnded ? Colors.black54 : AppColors.deepPink,
                  ),
                ),
              );
            }),

            // Messages List
            Expanded(
              child: Obx(() {
                final isInitiated = _controller.status.value == 'initiated';
                if (isInitiated) {
                  return _buildRingingScreen();
                }

                if (_controller.isLoading.value && _controller.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  controller: _controller.scrollController,
                  padding: const EdgeInsets.all(16),
                  reverse: true, // Show latest messages at bottom
                  itemCount: _controller.messages.length,
                  itemBuilder: (context, index) {
                    // Reverse index for display
                    final message = _controller.messages[_controller.messages.length - 1 - index];
                    final isMe = message.isMe;
                    final status = message.status;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.deepPink : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (message.type == 'image')
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: message.image != null && message.image!.startsWith('http')
                                    ? Image.network(
                                        message.image!,
                                        height: 150,
                                        width: 200,
                                        fit: BoxFit.cover,
                                      )
                                    : (message.image != null && File(message.image!).existsSync()
                                        ? Image.file(
                                            File(message.image!),
                                            height: 150,
                                            width: 200,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            message.attachmentUrl != null && message.attachmentUrl!.startsWith('http')
                                                ? message.attachmentUrl!
                                                : '${AppUrls.baseImageUrl}${message.attachmentUrl ?? ""}',
                                            height: 150,
                                            width: 200,
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, e, s) => Container(
                                              height: 150,
                                              width: 200,
                                              color: Colors.grey,
                                              child: const Icon(Icons.broken_image, color: Colors.white),
                                            ),
                                          )),
                              )
                            else if (message.type == 'document')
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Iconsax.document, color: Colors.white, size: 24),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: AppText(
                                        message.text.replaceFirst('📄 ', ''),
                                        fontSize: 14,
                                        color: isMe ? Colors.white : Colors.black87,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              AppText(
                                message.text,
                                fontSize: 14,
                                color: isMe ? Colors.white : Colors.black87,
                                height: 1.4,
                              ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppText(
                                  "${message.time.hour.toString().padLeft(2, '0')}:${message.time.minute.toString().padLeft(2, '0')}",
                                  fontSize: 10,
                                  color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey,
                                ),
                                if (isMe) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    status == 'sending...'
                                        ? Icons.access_time
                                        : status == 'sent'
                                            ? Icons.check
                                            : Icons.done_all,
                                    size: 16,
                                    color: status == 'seen'
                                        ? Colors.blueAccent
                                        : Colors.white.withOpacity(0.7),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            // Input Area
            Obx(() {
              final status = _controller.status.value.toLowerCase();
              final isEnded = status == 'ended' || status == 'completed' || status == 'cancelled' || status == 'rejected';
              final isInitiated = status == 'initiated';
              if (isEnded || isInitiated) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Colors.grey),
                        onPressed: _showAttachmentBottomSheet,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller.messageController,
                          decoration: InputDecoration(
                            hintText: "Type a message...",
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _controller.sendTextMessage(),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: AppColors.deepPink,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Iconsax.send_1_copy, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRingingScreen() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.deepPink.withOpacity(0.15),
              ),
              clipBehavior: Clip.hardEdge,
              child: widget.userImage.isNotEmpty
                  ? Image.network(
                      widget.userImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            widget.userName.isNotEmpty
                                ? widget.userName.substring(0, 1).toUpperCase()
                                : 'U',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepPink,
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        widget.userName.isNotEmpty
                            ? widget.userName.substring(0, 1).toUpperCase()
                            : 'U',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepPink,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 28),

            // Astrologer name
            Text(
              widget.userName,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
                letterSpacing: 0.3,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Astrologer',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 20),

            // Animated "Ringing..." dots
            AnimatedBuilder(
              animation: _dotController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Waiting for acceptance',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.deepPink,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 2),
                    _buildDot(0),
                    _buildDot(1),
                    _buildDot(2),
                  ],
                );
              },
            ),

            const SizedBox(height: 56),

            // End Call button
            GestureDetector(
              onTap: () => _showEndChatConfirmation(context),
              child: const Icon(Icons.call_end_rounded, color: Colors.red, size: 48),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final progress = _dotController.value;
    final delay = index * 0.25;
    final adjustedProgress = ((progress - delay) % 1.0 + 1.0) % 1.0;
    final opacity = adjustedProgress < 0.5
        ? adjustedProgress * 2
        : 1.0 - ((adjustedProgress - 0.5) * 2);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Opacity(
        opacity: opacity.clamp(0.2, 1.0),
        child: Text(
          '.',
          style: TextStyle(
            fontSize: 22,
            color: AppColors.deepPink,
            fontWeight: FontWeight.bold,
            height: 0.9,
          ),
        ),
      ),
    );
  }

  void _showEndChatConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("End Chat"),
        content: const Text("Are you sure you want to end this chat session?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _controller.endChatSession();
            },
            child: const Text("End Chat", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      _controller.sendImageAttachment(image);
    }
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      _controller.sendDocumentAttachment(result.files.single);
    }
  }

  void _showAttachmentBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Iconsax.camera,
                  color: Colors.blue,
                  label: "Camera",
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildAttachmentOption(
                  icon: Iconsax.gallery,
                  color: Colors.purple,
                  label: "Gallery",
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                _buildAttachmentOption(
                  icon: Iconsax.document,
                  color: Colors.orange,
                  label: "Document",
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickDocument();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          AppText(
            label,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ],
      ),
    );
  }
}
