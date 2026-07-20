import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/constants/app_urls.dart';
import '../controllers/assistant_chat_list_controller.dart';
import 'assistance_chat_room_screen.dart';

class AssistantChatScreen extends StatefulWidget {
  const AssistantChatScreen({super.key});

  @override
  State<AssistantChatScreen> createState() => _AssistantChatScreenState();
}

class _AssistantChatScreenState extends State<AssistantChatScreen> {
  final AssistantChatListController controller = Get.put(AssistantChatListController());
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToChat(int sessionId, String userName, String? userImage) {
     Get.to(() => AssistanceChatRoomScreen(
        sessionId: sessionId,
        userName: userName,
        userImage: userImage,
     ))?.then((_) {
       // Refresh list when coming back from chat room
       controller.fetchSessions();
     });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Assistant Chat Requests',
      ),
      body: Column(
        children: [
          // Search & Filter Panel
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      controller.searchQuery.value = val;
                    },
                    decoration: InputDecoration(
                      hintText: 'Search chats...',
                      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20),
                      suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                controller.searchQuery.value = '';
                              },
                            )
                          : const SizedBox.shrink()),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Filter Chips
                Obx(() => Row(
                      children: [
                        _buildFilterChip('All'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Unread'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Read'),
                      ],
                    )),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          
          // Sessions List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.activeSessions.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.hasError.value && controller.activeSessions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppText('Failed to load chat sessions', color: Colors.grey),
                      TextButton(
                        onPressed: controller.fetchSessions,
                        child: const Text('Retry'),
                      )
                    ],
                  ),
                );
              }

              final sessions = controller.filteredSessions;

              if (sessions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      AppText(
                        controller.searchQuery.value.isNotEmpty || controller.selectedFilter.value != 'All'
                            ? 'No matching chats found.'
                            : 'No active assistance requests.',
                        color: Colors.grey,
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: sessions.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  indent: 76,
                  color: Colors.grey.shade100,
                ),
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  final consumer = session['consumer'] ?? {};
                  final latestMessage = session['latest_message'] ?? {};
                  
                  final sessionId = session['id'] as int;
                  final consumerName = consumer['name']?.toString() ?? 'User';
                  final consumerImage = consumer['profile_photo']?.toString();
                  final messageText = latestMessage['message']?.toString() ?? 'Attachment';
                  final messageTimeStr = latestMessage['created_at']?.toString() ?? session['updated_at']?.toString() ?? '';
                  final messageType = latestMessage['type']?.toString() ?? 'text';
                  
                  final consumerId = session['consumer_id'];
                  final isUnread = latestMessage['sender_id'] == consumerId && latestMessage['is_read'] == false;
                  
                  String timeFormatted = '';
                  if (messageTimeStr.isNotEmpty) {
                     final dt = DateTime.tryParse(messageTimeStr);
                     if (dt != null) {
                        timeFormatted = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                     }
                  }

                  return _buildWhatsAppListTile(
                    sessionId: sessionId,
                    userName: consumerName,
                    userImage: consumerImage,
                    latestMessage: messageText,
                    messageType: messageType,
                    time: timeFormatted,
                    isUnread: isUnread,
                    isMe: latestMessage['sender_id'] != consumerId,
                    messageStatus: latestMessage['is_read'] == true
                        ? 'seen'
                        : (latestMessage['is_delivered'] == true ? 'delivered' : 'sent'),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterName) {
    final isSelected = controller.selectedFilter.value == filterName;
    final activeColor = AppColors.primaryColor;
    return GestureDetector(
      onTap: () {
        controller.selectedFilter.value = filterName;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor.withOpacity(0.3) : Colors.transparent,
            width: 1,
          ),
        ),
        child: AppText(
          filterName,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? activeColor : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildWhatsAppListTile({
    required int sessionId,
    required String userName,
    required String? userImage,
    required String latestMessage,
    required String messageType,
    required String time,
    required bool isUnread,
    required bool isMe,
    required String messageStatus,
  }) {
    Widget messagePreview;
    if (messageType == 'image') {
      messagePreview = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 4),
          Expanded(
            child: AppText(
              'Photo',
              fontSize: 13,
              color: Colors.grey.shade500,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else if (messageType == 'document') {
      messagePreview = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insert_drive_file, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 4),
          Expanded(
            child: AppText(
              'Document',
              fontSize: 13,
              color: Colors.grey.shade500,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else {
      messagePreview = AppText(
        latestMessage,
        fontSize: 13,
        color: isUnread ? Colors.black87 : Colors.grey.shade500,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }

    return InkWell(
      onTap: () => _navigateToChat(sessionId, userName, userImage),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  backgroundImage: (userImage != null && userImage.isNotEmpty)
                      ? NetworkImage(userImage.startsWith('http') ? userImage : '${AppUrls.baseImageUrl}$userImage')
                      : null,
                  child: (userImage == null || userImage.isEmpty)
                      ? AppText(
                          userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'U',
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )
                      : null,
                ),
                if (isUnread)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AppText(
                          userName,
                          fontSize: 15,
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                          color: Colors.black87,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppText(
                        time,
                        fontSize: 11,
                        color: isUnread ? Colors.green : Colors.grey.shade400,
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (isMe) ...[
                        _buildMessageStatusIcon(messageStatus),
                        const SizedBox(width: 4),
                      ],
                      Expanded(child: messagePreview),
                      if (isUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const AppText(
                            '1',
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageStatusIcon(String status) {
    IconData iconData;
    Color iconColor;

    switch (status) {
      case 'sent':
        iconData = Icons.check;
        iconColor = Colors.grey.shade400;
        break;
      case 'delivered':
        iconData = Icons.done_all;
        iconColor = Colors.grey.shade400;
        break;
      case 'seen':
        iconData = Icons.done_all;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.check;
        iconColor = Colors.grey.shade400;
    }

    return Icon(iconData, size: 16, color: iconColor);
  }
}
