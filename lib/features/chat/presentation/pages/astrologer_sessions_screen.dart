import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/core/widgets/app_text.dart';
import 'package:astro_astrologer/core/widgets/custom_app_bar.dart';
import 'package:astro_astrologer/features/chat/domain/models/chat_session_model.dart';
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const CustomAppBar(title: 'Chat Sessions', centerTitle: true),
      body: Obx(() {
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
                AppText(
                  controller.error.value,
                  color: Colors.red,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refresh,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                  ),
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
                const AppText(
                  'No chat sessions found',
                  textAlign: TextAlign.center,
                  color: Colors.grey,
                  fontSize: 16,
                ),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            itemCount: controller.sessions.length + 1,
            itemBuilder: (context, index) {
              if (index == controller.sessions.length) {
                return Obx(() => controller.isLoadingMore.value
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : const SizedBox.shrink());
              }
              return _SessionCard(session: controller.sessions[index]);
            },
          ),
        );
      }),
    );
  }
}

// ─── Session Card ────────────────────────────────────────────────────────────

class _SessionCard extends StatelessWidget {
  final ChatSessionModel session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final consumer = session.consumer;
    final name = consumer?.name ?? 'Unknown';
    final rawPhoto = consumer?.profilePhoto;
    final status = session.status;
    final date = _formatDate(session.createdAt);
    final duration = _formatDuration(session.durationSeconds);
    final latestMsg = session.latestMessage;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: Status pill + Date ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatusPill(status: status),
                AppText(
                  date,
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Consumer row: Avatar + Name + Stats ──
            Row(
              children: [
                _buildAvatar(name, rawPhoto),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        _toTitleCase(name),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.timer_outlined,
                            label: duration,
                            color: Colors.blue.shade400,
                          ),
                          const SizedBox(width: 8),
                          _InfoChip(
                            icon: Icons.currency_rupee,
                            label: session.totalCost.toStringAsFixed(0),
                            color: Colors.green.shade600,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Rate per minute
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppText(
                      '₹${session.ratePerMinute}/min',
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ],
                ),
              ],
            ),

            // ── Latest message preview ──
            if (latestMsg != null && latestMsg.message.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.message_outlined, size: 13, color: Colors.grey.shade400),
                    const SizedBox(width: 6),
                    Expanded(
                      child: AppText(
                        latestMsg.message.replaceAll('\n', ' '),
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (session.unreadCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: AppText(
                          '${session.unreadCount}',
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String name, String? rawPhoto) {
    final photoUrl = rawPhoto != null && rawPhoto.isNotEmpty
        ? (rawPhoto.startsWith('http')
            ? rawPhoto
            : '${AppUrls.baseImageUrl}$rawPhoto')
        : null;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    Widget letterWidget = AppText(
      initial,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryColor,
    );

    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primaryColor.withOpacity(0.12),
      child: photoUrl != null
          ? ClipOval(
              child: Image.network(
                photoUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => letterWidget,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : letterWidget,
              ),
            )
          : letterWidget,
    );
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((w) => w.isNotEmpty
            ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $h:$m $ampm';
    } catch (_) {
      return raw;
    }
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s > 0 ? '${m}m ${s}s' : '${m}m';
  }
}

// ─── Status Pill ─────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    IconData? icon;

    switch (status.toLowerCase()) {
      case 'completed':
        bg = Colors.green.shade50;
        textColor = Colors.green.shade700;
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        bg = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        icon = Icons.cancel_outlined;
        break;
      case 'rejected':
        bg = Colors.red.shade50;
        textColor = Colors.red.shade600;
        icon = Icons.block;
        break;
      default:
        bg = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        icon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          AppText(
            status[0].toUpperCase() + status.substring(1),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ],
      ),
    );
  }
}

// ─── Info Chip ────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 2),
        AppText(label, fontSize: 12, color: color, fontWeight: FontWeight.w500),
      ],
    );
  }
}
