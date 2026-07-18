import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../controllers/assistant_chat_list_controller.dart';
import 'assistance_chat_room_screen.dart';

class AssistantChatScreen extends StatefulWidget {
  const AssistantChatScreen({super.key});

  @override
  State<AssistantChatScreen> createState() => _AssistantChatScreenState();
}

class _AssistantChatScreenState extends State<AssistantChatScreen> {
  final AssistantChatListController controller = Get.put(AssistantChatListController());

  void _navigateToChat(int sessionId, String userName, String? userImage) {
     Get.to(() => AssistanceChatRoomScreen(
        sessionId: sessionId,
        userName: userName,
        userImage: userImage,
     ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: CustomAppBar(
        title: 'Assistant Chat Requests',
      ),
      body: Obx(() {
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

        if (controller.activeSessions.isEmpty) {
          return const Center(
            child: AppText(
              'No active assistance requests.',
              color: Colors.grey,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.activeSessions.length,
          itemBuilder: (context, index) {
            final session = controller.activeSessions[index];
            final consumer = session['consumer'] ?? {};
            final latestMessage = session['latest_message'] ?? {};
            
            final sessionId = session['id'] as int;
            final consumerName = consumer['name']?.toString() ?? 'User';
            final consumerImage = consumer['profile_photo']?.toString();
            final messageText = latestMessage['message']?.toString() ?? 'Attachment';
            final messageTimeStr = latestMessage['created_at']?.toString() ?? session['updated_at']?.toString() ?? '';
            
            String timeFormatted = '';
            if (messageTimeStr.isNotEmpty) {
               final dt = DateTime.tryParse(messageTimeStr);
               if (dt != null) {
                  timeFormatted = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
               }
            }

            return _buildActiveUserCard(
              sessionId: sessionId,
              userName: consumerName,
              userImage: consumerImage,
              latestMessage: messageText,
              time: timeFormatted,
            );
          },
        );
      }),
    );
  }

  Widget _buildActiveUserCard({
    required int sessionId,
    required String userName,
    required String? userImage,
    required String latestMessage,
    required String time,
  }) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                    backgroundImage: userImage != null ? NetworkImage(userImage) : null,
                    child: userImage == null 
                      ? AppText(userName.substring(0, 1).toUpperCase(), color: AppColors.primaryColor, fontWeight: FontWeight.bold)
                      : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppText(userName, fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  AppText(time, fontSize: 10, color: Colors.grey.shade400),
                ],
              ),
              const SizedBox(height: 12),
              AppText(latestMessage, fontSize: 12, color: Colors.grey.shade600, overflow: TextOverflow.ellipsis, maxLines: 1),
            ],
          ),
        ),
      ),
    );
  }
}
