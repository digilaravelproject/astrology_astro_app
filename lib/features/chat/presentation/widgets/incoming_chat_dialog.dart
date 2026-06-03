import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../res/default_res.dart';
import '../../../../core/services/network/api_client.dart';
import '../pages/chat_screen.dart';
import '../bindings/chat_binding.dart';
import 'dart:convert';

class IncomingChatDialog extends StatelessWidget {
  final Map<String, dynamic> sessionData;
  final Map<String, dynamic> senderData;

  const IncomingChatDialog({
    super.key,
    required this.sessionData,
    required this.senderData,
  });

  static const Color _orange = Color(0xFFE07B2D);
  static const Color _darkText = Color(0xFF1A1A2E);

  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'N/A';
    try {
      final DateTime date = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return isoString;
    }
  }

  String _formatLanguages(dynamic languages) {
    if (languages is List) {
      return languages.join(', ');
    } else if (languages is String) {
      try {
        final List<dynamic> decoded = jsonDecode(languages);
        return decoded.join(', ');
      } catch (e) {
        return languages;
      }
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final name = senderData['name'] ?? 'User';
    final profilePhoto = senderData['profile_photo'] != null
        ? '${AppUrls.baseImageUrl}${senderData['profile_photo']}'
        : null;
    final ratePerMin = sessionData['rate_per_minute']?.toString() ?? '0';
    final gender = senderData['gender'] ?? 'N/A';
    final dob = _formatDate(senderData['date_of_birth']?.toString());
    final tob = senderData['time_of_birth']?.toString() ?? 'N/A';
    final pob = senderData['place_of_birth']?.toString() ?? 'N/A';
    final languages = _formatLanguages(senderData['languages']);
    final sessionId = sessionData['id'];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_rounded, color: _orange, size: 22),
                const SizedBox(width: 8),
                Text(
                  'INCOMING CHAT REQUEST',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _orange,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Glowing Avatar ──
            SizedBox(
              height: 130,
              width: 130,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow ring
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _orange.withOpacity(0.25),
                          _orange.withOpacity(0.05),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                  // Orange border ring
                  Container(
                    height: 98,
                    width: 98,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _orange, width: 3),
                    ),
                  ),
                  // Avatar
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.orange.shade50,
                    backgroundImage:
                        profilePhoto != null ? NetworkImage(profilePhoto) : null,
                    child: profilePhoto == null
                        ? Icon(Icons.person, size: 44, color: _orange)
                        : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Name ──
            Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _darkText,
              ),
            ),
            const SizedBox(height: 10),

            // ── Rate Badge (coin style) ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _orange.withOpacity(0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _orange,
                    ),
                    child: const Center(
                      child: Text('₹',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '₹$ratePerMin / min',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _orange,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Divider(thickness: 0.8, color: Color(0xFFE0E0E0)),
            const SizedBox(height: 12),

            // ── User Details ──
            _buildDetailRow(Icons.person_outline, 'Gender:', gender),
            _buildDetailRow(Icons.cake_outlined, 'DOB:', dob),
            _buildDetailRow(Icons.access_time_outlined, 'TOB:', tob),
            _buildDetailRow(Icons.location_on_outlined, 'POB:', pob),
            _buildDetailRow(Icons.translate_outlined, 'Languages:', languages),

            const SizedBox(height: 28),

            // ── Buttons ──
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      try {
                        await Get.find<ApiClient>()
                            .post(AppUrls.rejectChatSession(sessionId));
                      } catch (e) {
                        debugPrint('Reject error: $e');
                      }
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Reject',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final response = await Get.find<ApiClient>()
                            .post(AppUrls.acceptChatSession(sessionId));
                        if (response.isSuccess) {
                          Get.back();
                          Get.to(
                            () => ChatScreen(
                              userName: name,
                              userImage: profilePhoto ?? '',
                              sessionId: sessionId,
                              initialStatus: 'ongoing',
                              startedAtString: response.body?['data']
                                  ?['session']?['started_at']
                                  ?.toString(),
                            ),
                            binding: ChatBinding(),
                          );
                        } else {
                          Get.back();
                          Get.snackbar('Error', response.message);
                        }
                      } catch (e) {
                        debugPrint('Accept error: $e');
                        Get.back();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2DB84B),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Accept',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _darkText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
