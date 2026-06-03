import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../res/default_res.dart';
import '../../../../core/services/network/api_client.dart';
import '../../pages/chat_screen.dart';
import '../../bindings/chat_binding.dart';
import 'dart:convert';

import '../bindings/chat_binding.dart';
import '../pages/chat_screen.dart';

class IncomingChatDialog extends StatelessWidget {
  final Map<String, dynamic> sessionData;
  final Map<String, dynamic> senderData;

  const IncomingChatDialog({
    super.key,
    required this.sessionData,
    required this.senderData,
  });

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, color: const Color(0xFF2E1A47), size: 20),
                const SizedBox(width: 8),
                AppText(
                  'INCOMING CHAT REQUEST',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E1A47),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Animation Profile
            SizedBox(
              height: 120,
              width: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Lottie.asset(
                    'assets/lottie/calling.json', 
                    height: 120, 
                    width: 120, 
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF2E1A47).withOpacity(0.1),
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: profilePhoto != null ? NetworkImage(profilePhoto) : null,
                    child: profilePhoto == null ? const Icon(Icons.person, size: 40, color: Colors.grey) : null,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            AppText(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E1A47),
              ),
            ),
            const SizedBox(height: 8),
            
            // Rate Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2E1A47).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2E1A47).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.currency_rupee, size: 14, color: const Color(0xFF2E1A47)),
                  AppText(
                    '$ratePerMin / min',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E1A47),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            const Divider(color: Colors.grey),
            const SizedBox(height: 16),
            
            // User Details
            _buildDetailRow(Icons.person_outline, 'Gender:', gender),
            _buildDetailRow(Icons.cake_outlined, 'DOB:', dob),
            _buildDetailRow(Icons.access_time, 'TOB:', tob),
            _buildDetailRow(Icons.location_on_outlined, 'POB:', pob),
            _buildDetailRow(Icons.translate, 'Languages:', languages),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      try {
                        await ApiClient.post(AppUrls.rejectChatSession(sessionId));
                      } catch (e) {
                        debugPrint('Reject error: $e');
                      }
                      Get.back(); // close dialog
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const AppText(
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
                        final response = await ApiClient.post(AppUrls.acceptChatSession(sessionId));
                        if (response.isSuccess) {
                          Get.back(); // close dialog
                          Get.to(
                            () => ChatScreen(
                              userName: name,
                              userImage: profilePhoto ?? '',
                              sessionId: sessionId,
                              initialStatus: 'ongoing',
                              startedAtString: response.body?['data']?['session']?['started_at']?.toString(),
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
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const AppText(
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
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          AppText(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppText(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E1A47),
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
