import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/core/widgets/app_text.dart';

class ChatSummaryDialog extends StatelessWidget {
  final int sessionId;
  final int durationSeconds;
  final double totalCost;

  const ChatSummaryDialog({
    super.key,
    required this.sessionId,
    required this.durationSeconds,
    required this.totalCost,
  });

  static void show({
    required int sessionId,
    required int durationSeconds,
    required double totalCost,
  }) {
    Get.dialog(
      ChatSummaryDialog(
        sessionId: sessionId,
        durationSeconds: durationSeconds,
        totalCost: totalCost,
      ),
      barrierDismissible: false,
    );
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '0s';
    final int mins = seconds ~/ 60;
    final int secs = seconds % 60;
    if (mins == 0) return '${secs}s';
    return '${mins}m ${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Check icon container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            AppText(
              'Chat Session Ended',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2E1A47),
            ),
            const SizedBox(height: 6),
            AppText(
              'Here is the summary of your session',
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
            const SizedBox(height: 24),
            
            const Divider(color: Color(0xFFF1F1F1), height: 1),
            const SizedBox(height: 16),
            
            // Session Details
            _buildSummaryRow(Icons.tag, 'Session ID', '#$sessionId'),
            _buildSummaryRow(Icons.timer_outlined, 'Duration', _formatDuration(durationSeconds)),
            _buildSummaryRow(Icons.monetization_on_outlined, 'Total Charge', '₹${totalCost.toStringAsFixed(2)}'),
            
            const SizedBox(height: 24),
            
            // Close Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const AppText(
                  'Done',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          AppText(
            label,
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          const Spacer(),
          AppText(
            value,
            fontSize: 14,
            color: const Color(0xFF2E1A47),
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }
}
