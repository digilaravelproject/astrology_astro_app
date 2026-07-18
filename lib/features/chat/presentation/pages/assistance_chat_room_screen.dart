import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/assistance_chat_room_controller.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/core/widgets/app_text.dart';
import 'package:astro_astrologer/features/chat/domain/entities/chat_message.dart';

class AssistanceChatRoomScreen extends StatefulWidget {
  final int sessionId;
  final String userName;
  final String? userImage;

  const AssistanceChatRoomScreen({
    Key? key,
    required this.sessionId,
    required this.userName,
    this.userImage,
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
              backgroundImage: widget.userImage != null 
                  ? NetworkImage(widget.userImage!) 
                  : null,
              child: widget.userImage == null
                  ? AppText(
                      widget.userName.substring(0, 1).toUpperCase(),
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
                    'You have reached your daily free assistance reply limit.',
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
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.isMe ? AppColors.primaryColor : Colors.white,
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
            if (message.type == 'image' && message.image != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    message.image!,
                    height: 150,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            AppText(
              message.text,
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
                  color: message.isMe ? Colors.white70 : Colors.grey.shade500,
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
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData iconData;
    Color iconColor;

    switch (status) {
      case 'sending':
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
          ),
        );
      case 'sent':
        iconData = Icons.check;
        iconColor = Colors.white70;
        break;
      case 'delivered':
        iconData = Icons.done_all;
        iconColor = Colors.white70;
        break;
      case 'read':
        iconData = Icons.done_all;
        iconColor = Colors.blue.shade200;
        break;
      case 'failed':
        iconData = Icons.error_outline;
        iconColor = Colors.red.shade200;
        break;
      default:
        iconData = Icons.access_time;
        iconColor = Colors.white70;
    }

    return Icon(iconData, size: 14, color: iconColor);
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller.messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 4,
                  enabled: !controller.limitReached.value,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(() => GestureDetector(
              onTap: controller.limitReached.value ? null : controller.sendMessage,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: controller.limitReached.value ? Colors.grey : AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
