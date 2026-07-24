import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/core/widgets/app_text.dart';
import 'package:astro_astrologer/core/widgets/custom_app_bar.dart';
import 'package:astro_astrologer/core/widgets/custom_button.dart';
import 'package:astro_astrologer/features/chat/domain/models/chat_session_model.dart';
import 'package:astro_astrologer/features/chat/presentation/bindings/chat_binding.dart';
import 'package:astro_astrologer/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_astrologer/features/chat/presentation/pages/create_default_message_screen.dart';
import 'package:astro_astrologer/features/kundli/kundli_screen.dart';
import 'package:astro_astrologer/features/home/widgets/animated_favorite_button.dart';
import 'package:astro_astrologer/features/home/widgets/add_note_bottom_sheet.dart';
import 'package:astro_astrologer/features/chat/presentation/pages/assistance_chat_room_screen.dart';

import 'controllers/astrologer_sessions_controller.dart';

class AstrologerSessionsScreen extends StatelessWidget {
  AstrologerSessionsScreen({super.key}) {
    if (!Get.isRegistered<AstrologerSessionsController>()) {
      Get.put(AstrologerSessionsController(Get.find<ApiClient>()));
    }
  }

  AstrologerSessionsController get controller =>
      Get.find<AstrologerSessionsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const CustomAppBar(title: 'Chat History', centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryColor),
                );
              }

              if (controller.error.value.isNotEmpty && controller.sessions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                      const SizedBox(height: 12),
                      AppText(controller.error.value, color: Colors.red, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.refresh,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                        child: const AppText('Retry', color: Colors.white),
                      ),
                    ],
                  ),
                );
              }

              if (controller.sessions.isEmpty) {
                return RefreshIndicator(
                  color: AppColors.primaryColor,
                  onRefresh: controller.refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                      const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const AppText('No chat sessions found', textAlign: TextAlign.center, color: Colors.grey, fontSize: 16),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primaryColor,
                onRefresh: controller.refresh,
                child: ListView.builder(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 20),
                  itemCount: controller.sessions.length + 1,
                  itemBuilder: (context, index) {
                    if (index == controller.sessions.length) {
                      return Obx(() => controller.isLoadingMore.value
                          ? const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: CircularProgressIndicator(color: AppColors.primaryColor, strokeWidth: 2)),
                            )
                          : const SizedBox.shrink());
                    }
                    return _buildHistoryCard(context, session: controller.sessions[index]);
                  },
                ),
              );
            }),
          ),

          // Footer note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
            child: Center(
              child: AppText('Data shown for last 3 days only', fontSize: 13, fontWeight: FontWeight.w500, color: Colors.red.shade200),
            ),
          ),

          // Sticky create default message button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: CustomButton(
                  text: "Create default message",
                  onPressed: () => Get.to(() => const CreateDefaultMessageScreen(), binding: ChatBinding()),
                  height: 48,
                  backgroundColor: AppColors.primaryColor,
                  borderRadius: 10,
                  prefixIcon: const Icon(Icons.add, color: Colors.white, size: 18),
                  textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, {required ChatSessionModel session}) {
    final consumer = session.consumer;
    final name = _toTitleCase(consumer?.name ?? 'Unknown');
    final rawPhoto = consumer?.profilePhoto;
    final photoUrl = rawPhoto != null && rawPhoto.isNotEmpty
        ? (rawPhoto.startsWith('http') ? rawPhoto : '${AppUrls.baseImageUrl}$rawPhoto')
        : '';
    final status = _capitalise(session.status);
    final date = _formatDate(session.createdAt);
    final duration = _formatDuration(session.durationSeconds);
    final dob = _formatDob(consumer?.dateOfBirth, consumer?.timeOfBirth);
    final pob = _toTitleCase(consumer?.placeOfBirth ?? 'N/A');
    final gender = _toTitleCase(consumer?.gender ?? 'N/A');
    final rate = '₹ ${session.ratePerMinute}/min';
    final totalCost = session.totalCost.toStringAsFixed(1);

    // Build detail map
    final details = <String, String>{
      'Name': name,
      'Gender': gender,
      'DOB': dob,
      'Duration': duration,
      'Rate': rate,
      'POB': pob,
    };

    String? dobPart;
    String? tobPart;
    if (consumer != null && consumer.dateOfBirth != null) {
      try {
        // date_of_birth is UTC; toLocal() gives correct IST date
        final dobDate = DateTime.parse(consumer.dateOfBirth!).toLocal();
        dobPart = "${dobDate.year}-${dobDate.month.toString().padLeft(2, '0')}-${dobDate.day.toString().padLeft(2, '0')}";
        // time_of_birth is already IST (e.g. "19:12"), use directly
        tobPart = "00:00:00";
        if (consumer.timeOfBirth != null && consumer.timeOfBirth!.isNotEmpty) {
          tobPart = consumer.timeOfBirth!;
          if (tobPart.length == 5) tobPart += ":00";
        }
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(top: 14, bottom: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: () => Get.to(
              () => ChatScreen(
                userName: name,
                userImage: photoUrl,
                sessionId: session.id,
                initialStatus: session.status,
              ),
              binding: ChatBinding(),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top Pills row ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.lightBlue.shade50.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: AppText('Session #${session.id}', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue.shade400),
                      ),
                      _buildStatusPill(status),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Consumer Avatar + Name + ID ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildAvatar(name, rawPhoto, photoUrl),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(name, fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                            const SizedBox(height: 2),
                            AppText('ID: #${session.consumerId}${session.providerId}', fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Session Date + Total Amount box ──
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText('Session Date', fontSize: 12, color: Colors.grey.shade500),
                              const SizedBox(height: 2),
                              AppText(date, fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AppText('Total Amount', fontSize: 12, color: Colors.grey.shade500),
                            const SizedBox(height: 2),
                            AppText('₹ $totalCost', fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF2E1A47)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 16),

                  // ── Detail rows ──
                  ...details.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 80,
                            child: AppText(entry.key, fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                          const AppText(':  ', fontWeight: FontWeight.bold),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: AppText(entry.value, fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                                ),
                                 if (entry.key == 'Name' || entry.key == 'POB')
                                   GestureDetector(
                                     onTap: () {
                                       Clipboard.setData(ClipboardData(text: entry.value));
                                       Get.snackbar(
                                         'Copied',
                                         '${entry.key} copied to clipboard',
                                         snackPosition: SnackPosition.BOTTOM,
                                         duration: const Duration(seconds: 2),
                                         backgroundColor: Colors.black87,
                                         colorText: Colors.white,
                                       );
                                     },
                                     child: Padding(
                                       padding: const EdgeInsets.only(left: 8),
                                       child: Icon(Icons.copy_rounded, size: 14, color: AppColors.primaryColor.withValues(alpha: 0.7)),
                                     ),
                                   ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // ── Action Buttons ──
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Open Kundli',
                          onPressed: () => Get.to(() => KundliScreen(
                            fullName: name,
                            gender: consumer?.gender ?? "",
                            dob: dobPart ?? "",
                            tob: tobPart ?? "",
                            place: pob,
                            latitude: consumer?.latitude ?? 0.0,
                            longitude: consumer?.longitude ?? 0.0,
                          )),
                          height: 42,
                          padding: EdgeInsets.zero,
                          buttonType: ButtonStyleType.outlined,
                          borderRadius: 8,
                          textStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomButton(
                          text: 'Chat Assistant',
                          onPressed: () {
                            if (session.chatAssistanceSessionId != null) {
                              Get.to(() => AssistanceChatRoomScreen(
                                sessionId: session.chatAssistanceSessionId!,
                                userName: name,
                                userImage: photoUrl,
                              ));
                            } else {
                              Get.snackbar("Error", "No Chat Assistance Session available");
                            }
                          },
                          height: 42,
                          padding: EdgeInsets.zero,
                          backgroundColor: const Color(0xFF2CB772),
                          prefixIcon: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 12),
                          borderRadius: 8,
                          textColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  if (session.status == 'completed') ...[
                    const SizedBox(height: 12),
                    const AppText('Refund', fontSize: 14, color: Colors.red, fontWeight: FontWeight.w500),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──

  Widget _buildAvatar(String name, String? rawPhoto, String photoUrl) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    Widget letterWidget = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryColor.withValues(alpha: 0.7), AppColors.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(child: AppText(initial, fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
    );

    if (photoUrl.isEmpty) return letterWidget;

    return ClipOval(
      child: Image.network(
        photoUrl,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => letterWidget,
        loadingBuilder: (_, child, progress) => progress == null ? child : letterWidget,
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    Color bg;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'completed':
        bg = Colors.green.shade50.withValues(alpha: 0.5);
        textColor = Colors.green.shade700;
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        bg = Colors.orange.shade50.withValues(alpha: 0.5);
        textColor = Colors.orange.shade700;
        icon = Icons.cancel_outlined;
        break;
      case 'rejected':
        bg = Colors.red.shade50.withValues(alpha: 0.5);
        textColor = Colors.red.shade600;
        icon = Icons.block;
        break;
      default:
        bg = Colors.blue.shade50.withValues(alpha: 0.5);
        textColor = Colors.blue.shade700;
        icon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(status, fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
          const SizedBox(width: 4),
          Icon(icon, color: textColor, size: 14),
        ],
      ),
    );
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}' : '').join(' ');
  }

  String _capitalise(String text) => text.isNotEmpty ? '${text[0].toUpperCase()}${text.substring(1)}' : text;

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '${dt.day} ${months[dt.month - 1]} ${dt.year.toString().substring(2)}, $h:$m $ampm';
    } catch (_) {
      return raw;
    }
  }

  String _formatDob(String? dob, String? tob) {
    if (dob == null || dob.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(dob).toLocal();
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final dateStr = '${dt.day}-${months[dt.month - 1]}-${dt.year}';
      return tob != null && tob.isNotEmpty ? '$dateStr, $tob' : dateStr;
    } catch (_) {
      return dob;
    }
  }

  String _formatDuration(int seconds) {
    if (seconds == 0) return '0 seconds';
    if (seconds < 60) return '$seconds seconds';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s > 0 ? '$m minutes ($s sec)' : '$m minutes';
  }
}
