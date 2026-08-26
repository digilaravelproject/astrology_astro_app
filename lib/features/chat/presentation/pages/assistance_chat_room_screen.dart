import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_urls.dart';
import '../controllers/assistance_chat_room_controller.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/core/widgets/app_text.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:astro_astrologer/features/chat/domain/entities/chat_message.dart';
import 'package:astro_astrologer/features/kundli/kundli_screen.dart';
import 'package:astro_astrologer/features/kundli/create_kundli_screen.dart';
import 'package:swipe_to/swipe_to.dart';

class AssistanceChatRoomScreen extends StatefulWidget {
  final int sessionId;
  final String userName;
  final String? userImage;
  final String? gender;
  final String? dob;
  final String? tob;
  final String? place;
  final double? latitude;
  final double? longitude;

  const AssistanceChatRoomScreen({
    Key? key,
    required this.sessionId,
    required this.userName,
    this.userImage,
    this.gender,
    this.dob,
    this.tob,
    this.place,
    this.latitude,
    this.longitude,
  }) : super(key: key);

  @override
  State<AssistanceChatRoomScreen> createState() => _AssistanceChatRoomScreenState();
}

class _AssistanceChatRoomScreenState extends State<AssistanceChatRoomScreen> {
  late AssistanceChatRoomController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AssistanceChatRoomController(), tag: widget.sessionId.toString());
    controller.initSession(widget.sessionId);
  }

  @override
  void dispose() {
    Get.delete<AssistanceChatRoomController>(tag: widget.sessionId.toString());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryColor.withOpacity(0.1),
              backgroundImage: (widget.userImage != null && widget.userImage!.isNotEmpty)
                  ? NetworkImage(widget.userImage!.startsWith('http')
                      ? widget.userImage!
                      : "${AppUrls.baseImageUrl}${widget.userImage!}")
                  : null,
              child: (widget.userImage == null || widget.userImage!.isEmpty)
                  ? AppText(
                      widget.userName.isNotEmpty ? widget.userName.substring(0, 1).toUpperCase() : 'U',
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    widget.userName,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  AppText(
                    'Assistance Chat',
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                onTap: () {
                  if (widget.dob != null && widget.dob!.isNotEmpty) {
                    Get.to(() => KundliScreen(
                      fullName: widget.userName,
                      gender: widget.gender ?? '',
                      dob: widget.dob!,
                      tob: widget.tob ?? '00:00:00',
                      place: widget.place ?? '',
                      latitude: widget.latitude ?? 0.0,
                      longitude: widget.longitude ?? 0.0,
                    ));
                  } else {
                    Get.to(() => CreateKundliScreen(
                      initialKundliData: {
                        'name': widget.userName,
                      },
                    ));
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryColor.withOpacity(0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, size: 14, color: AppColors.primaryColor),
                      SizedBox(width: 4),
                      AppText(
                        'Kundli',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Obx(() {
              if (controller.limitReached.value) {
                return Container(
                  width: double.infinity,
                  color: Colors.orange.shade100,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: AppText(
                    'Daily message reply limit reached. You cannot send more replies today.',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.deepOrange.shade800,
                    textAlign: TextAlign.center,
                  ),
                );
              } else if (controller.remainingMessages.value > 0) {
                return Container(
                  width: double.infinity,
                  color: Colors.blue.shade50,
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  child: AppText(
                    'You have ${controller.remainingMessages.value} free replies left today.',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade800,
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (controller.messages.isEmpty) {
                  return const Center(
                    child: AppText(
                      'Waiting for messages...',
                      color: Colors.grey,
                    ),
                  );
                }

                return ListView.builder(
                  controller: controller.scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    return _buildMessageBubble(message);
                  },
                );
              }),
            ),
            Obx(() => _buildMessageInput()),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    bool isReply = false;
    String replyUser = '';
    String replyText = '';
    String mainText = message.text;
    
    if (message.replyTo != null) {
      isReply = true;
      replyUser = message.replyTo!.isMe ? 'You' : widget.userName;
      replyText = message.replyTo!.text;
    } else if (mainText.startsWith('>>reply>>')) {
      // Fallback for old cached messages
      isReply = true;
      final endQuote = mainText.indexOf('<<reply<<');
      if (endQuote != -1) {
        final quotePart = mainText.substring(9, endQuote);
        final colonIdx = quotePart.indexOf(': ');
        if (colonIdx != -1) {
          replyUser = quotePart.substring(0, colonIdx);
          replyText = quotePart.substring(colonIdx + 2);
        } else {
          replyText = quotePart;
        }
        mainText = mainText.substring(endQuote + 9).trimLeft();
      } else {
        final quotePartWithText = mainText.substring(9);
        final newlineIdx = quotePartWithText.indexOf('\n');
        String quotePart;
        if (newlineIdx != -1) {
          quotePart = quotePartWithText.substring(0, newlineIdx);
          mainText = quotePartWithText.substring(newlineIdx).trimLeft();
        } else {
          quotePart = quotePartWithText;
          mainText = '';
        }
        
        final colonIdx = quotePart.indexOf(': ');
        if (colonIdx != -1) {
          replyUser = quotePart.substring(0, colonIdx);
          replyText = quotePart.substring(colonIdx + 2);
        } else {
          replyUser = 'User';
          replyText = quotePart;
        }
      }
    }

    return SwipeTo(
      onRightSwipe: (details) {
        controller.setReply(message);
      },
      onLeftSwipe: (details) {
        controller.setReply(message);
      },
      child: Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.isMe ? AppColors.deepPink : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isMe ? 16 : 0),
            bottomRight: Radius.circular(message.isMe ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: const BoxConstraints(maxWidth: 280),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isReply)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: message.isMe ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border(left: BorderSide(color: message.isMe ? Colors.white : AppColors.primaryColor, width: 4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(replyUser, color: message.isMe ? Colors.white : AppColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                    const SizedBox(height: 4),
                    AppText(replyText, color: message.isMe ? Colors.white70 : Colors.black87, fontSize: 12, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            if (message.type == 'image')
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: message.image != null && message.image!.startsWith('http')
                      ? Image.network(
                          message.image!,
                          height: 150,
                          width: 200,
                          fit: BoxFit.cover,
                        )
                      : (message.image != null
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
                ),
              )
            else if (message.type == 'document')
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 8.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.document, color: Colors.black54, size: 24),
                    const SizedBox(width: 8),
                    Flexible(
                      child: AppText(
                        mainText.replaceFirst('📄 ', ''),
                        fontSize: 14,
                        color: Colors.black87,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
            else if (mainText.isNotEmpty)
              AppText(
                mainText,
                fontSize: 14,
                color: message.isMe ? Colors.white : Colors.black87,
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  _formatTime(message.time),
                  fontSize: 10,
                  color: message.isMe ? Colors.white.withOpacity(0.7) : Colors.grey[600]!,
                ),
                if (message.isMe) ...[
                  const SizedBox(width: 4),
                  _buildStatusIcon(message.status),
                ],
              ],
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildStatusIcon(String status) {
    IconData iconData;
    Color iconColor;

    switch (status) {
      case 'sending':
      case 'sending...':
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        );
      case 'sent':
        iconData = Icons.check;
        iconColor = Colors.white.withOpacity(0.7);
        break;
      case 'delivered':
        iconData = Icons.done_all;
        iconColor = Colors.white.withOpacity(0.7);
        break;
      case 'read':
      case 'seen':
        iconData = Icons.done_all;
        iconColor = Colors.blueAccent;
        break;
      case 'failed':
        iconData = Icons.error_outline;
        iconColor = Colors.red.shade200;
        break;
      default:
        iconData = Icons.access_time;
        iconColor = Colors.white.withOpacity(0.7);
    }

    return Icon(iconData, size: 14, color: iconColor);
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildMessageInput() {
    if (controller.limitReached.value) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller.replyingToMessage.value != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: const Border(left: BorderSide(color: AppColors.primaryColor, width: 4)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            controller.replyingToMessage.value!.isMe ? 'You' : widget.userName,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            controller.replyingToMessage.value!.text.replaceAll('\n', ' '),
                            color: Colors.black87,
                            fontSize: 12,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                      onPressed: () => controller.cancelReply(),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.grey),
              onPressed: _showAttachmentBottomSheet,
            ),
            Expanded(
              child: TextField(
                controller: controller.messageController,
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
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 4,
              ),
            ),
            const SizedBox(width: 8),
            Obx(() => GestureDetector(
              onTap: controller.limitReached.value ? null : controller.sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: controller.limitReached.value ? Colors.grey : AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.send_1_copy, color: Colors.white, size: 20),
              ),
            )),
          ],
        ),
        ],
      ),
      )
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      controller.sendImageAttachment(image);
    }
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      controller.sendDocumentAttachment(result.files.single);
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

