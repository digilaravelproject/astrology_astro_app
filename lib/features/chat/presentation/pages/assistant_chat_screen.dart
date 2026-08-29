import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/constants/app_urls.dart';
import '../controllers/assistant_chat_list_controller.dart';
import 'assistance_chat_room_screen.dart';
import 'package:astro_astrologer/core/widgets/custom_image_widget.dart';

class AssistantChatScreen extends StatefulWidget {
  const AssistantChatScreen({super.key});

  @override
  State<AssistantChatScreen> createState() => _AssistantChatScreenState();
}

class _AssistantChatScreenState extends State<AssistantChatScreen> {
  final AssistantChatListController controller = Get.put(
    AssistantChatListController(),
  );
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToChat(int sessionId, String userName, String? userImage) {
    Get.to(
      () => AssistanceChatRoomScreen(
        sessionId: sessionId,
        userName: userName,
        userImage: userImage,
      ),
    )?.then((_) {
      // Refresh list when coming back from chat room
      controller.fetchSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(title: 'Assistant Chat Requests'.tr),
      body: Column(
        children: [
          // Search & Filter Panel
          Container(
            color: Colors.grey.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Clean Search Bar matching app UI style
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    controller.searchQuery.value = val;
                  },
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'Search chats...'.tr,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                    suffixIcon: Obx(
                      () =>
                          controller.searchQuery.value.isNotEmpty
                              ? IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  controller.searchQuery.value = '';
                                },
                              )
                              : const SizedBox.shrink(),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor,
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                // Filter Chips
                Obx(
                  () => Row(
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Unread'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Read'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sessions List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.activeSessions.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.hasError.value &&
                  controller.activeSessions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppText(
                        'Failed to load chat sessions',
                        color: Colors.grey,
                      ),
                      TextButton(
                        onPressed: controller.fetchSessions,
                        child: const Text('Retry'),
                      ),
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
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      AppText(
                        controller.searchQuery.value.isNotEmpty ||
                                controller.selectedFilter.value != 'All'
                            ? 'No matching chats found.'
                            : 'No active assistance requests.',
                        color: Colors.grey,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  final consumer = session['consumer'] ?? {};
                  final latestMessage = session['latest_message'] ?? {};

                  final sessionId = session['id'] as int;
                  final consumerName = consumer['name']?.toString() ?? 'User';
                  final consumerImage = consumer['profile_photo']?.toString();
                  final messageText =
                      latestMessage['message']?.toString() ?? 'Attachment';
                  final messageTimeStr =
                      latestMessage['created_at']?.toString() ??
                      session['updated_at']?.toString() ??
                      '';
                  final messageType =
                      latestMessage['type']?.toString() ?? 'text';

                  final consumerId = session['consumer_id'];
                  final isUnread =
                      latestMessage['sender_id'] == consumerId &&
                      latestMessage['is_read'] == false;

                  String timeFormatted = '';
                  if (messageTimeStr.isNotEmpty) {
                    final dt = DateTime.tryParse(messageTimeStr);
                    if (dt != null) {
                      timeFormatted =
                          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                    }
                  }

                  return _buildActiveUserCard(
                    sessionId: sessionId,
                    userName: consumerName,
                    userImage: consumerImage,
                    latestMessage: messageText,
                    messageType: messageType,
                    time: timeFormatted,
                    isUnread: isUnread,
                    isMe: latestMessage['sender_id'] != consumerId,
                    messageStatus:
                        latestMessage['is_read'] == true
                            ? 'seen'
                            : (latestMessage['is_delivered'] == true
                                ? 'delivered'
                                : 'sent'),
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
    return GestureDetector(
      onTap: () {
        controller.selectedFilter.value = filterName;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
            width: 1.2,
          ),
        ),
        child: AppText(
          filterName.tr,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildActiveUserCard({
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

    return GestureDetector(
      onTap: () => _navigateToChat(sessionId, userName, userImage),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor.withOpacity(0.1),
                    ),
                    child: ClipOval(
                      child:
                          (userImage != null && userImage.isNotEmpty)
                              ? CustomImageWidget(
                                imagePath:
                                    userImage.startsWith('http')
                                        ? userImage
                                        : '${AppUrls.baseImageUrl}$userImage',
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Center(
                                      child: AppText(
                                        userName.isNotEmpty
                                            ? userName
                                                .substring(0, 1)
                                                .toUpperCase()
                                            : 'U',
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                              )
                              : Center(
                                child: AppText(
                                  userName.isNotEmpty
                                      ? userName.substring(0, 1).toUpperCase()
                                      : 'U',
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                    ),
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
                            fontWeight:
                                isUnread ? FontWeight.bold : FontWeight.w600,
                            color: Colors.black87,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AppText(
                          time,
                          fontSize: 11,
                          color: isUnread ? Colors.green : Colors.grey.shade400,
                          fontWeight:
                              isUnread ? FontWeight.bold : FontWeight.normal,
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
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
