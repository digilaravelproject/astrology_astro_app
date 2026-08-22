import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/websocket_service.dart';
import '../pages/chat_screen.dart';
import '../bindings/chat_binding.dart';
import '../../../../core/constants/app_constants.dart';
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';
import 'package:astro_astrologer/core/services/local_notification_service.dart';

class IncomingChatDialog extends StatefulWidget {
  final Map<String, dynamic> sessionData;
  final Map<String, dynamic> senderData;

  const IncomingChatDialog({
    super.key,
    required this.sessionData,
    required this.senderData,
  });

  @override
  State<IncomingChatDialog> createState() => _IncomingChatDialogState();
}

class _IncomingChatDialogState extends State<IncomingChatDialog>
    with TickerProviderStateMixin {
  static const Color _orange = Color(0xFFE07B2D);
  static const Color _darkText = Color(0xFF1A1A2E);

  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _pulse2Anim;
  late Animation<double> _pulse3Anim;
  late Animation<double> _opacityAnim;
  late Animation<double> _opacity2Anim;
  late Animation<double> _opacity3Anim;
  StreamSubscription? _dismissSub;
  Worker? _dismissWorker;

  @override
  void initState() {
    super.initState();

    // Dialog scale-in from top
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _scaleAnim = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    );
    _scaleController.forward();

    // Listen for ChatDismissed — auto-close dialog if session matches
    final sessionId = widget.sessionData['id'];
    
    // Check if already dismissed before bottom sheet rendered
    if (WebSocketService.chatDismissedSessionId.value == sessionId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
      });
    }

    _dismissWorker = ever(
      WebSocketService.chatDismissedSessionId,
      (int dismissedId) {
        if (dismissedId == sessionId) {
          Get.back();
        }
      },
    );

    // Ripple pulse around avatar
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );
    _opacityAnim = Tween<double>(begin: 0.55, end: 0.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _pulse2Anim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.25, 1.0, curve: Curves.easeOut),
      ),
    );
    _opacity2Anim = Tween<double>(begin: 0.4, end: 0.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.25, 1.0, curve: Curves.easeOut),
      ),
    );

    _pulse3Anim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
    _opacity3Anim = Tween<double>(begin: 0.25, end: 0.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
    // Ringtone and vibration for incoming ringing request
    _startRingtone();
  }

  void _startRingtone() {
    // Sound play disabled
  }

  void _stopRingtone() {
    // Sound stop disabled
  }

  @override
  void dispose() {
    _stopRingtone();
    _dismissSub?.cancel();
    _dismissWorker?.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'N/A';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(isoString));
    } catch (_) {
      return isoString;
    }
  }

  String _formatLanguages(dynamic languages) {
    if (languages is List) return languages.join(', ');
    if (languages is String) {
      try {
        return (jsonDecode(languages) as List).join(', ');
      } catch (_) {
        return languages;
      }
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.senderData['name'] ?? 'User';
    final profilePhoto = widget.senderData['profile_photo'] != null
        ? '${AppUrls.baseImageUrl}${widget.senderData['profile_photo']}'
        : null;
    final ratePerMin = widget.sessionData['rate_per_minute']?.toString() ?? '0';
    final gender = widget.senderData['gender'] ?? 'N/A';
    final dob = _formatDate(widget.senderData['date_of_birth']?.toString());
    final tob = widget.senderData['time_of_birth']?.toString() ?? 'N/A';
    final pob = widget.senderData['place_of_birth']?.toString() ?? 'N/A';
    final languages = _formatLanguages(widget.senderData['languages']);
    final sessionId = widget.sessionData['id'];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Bottom Sheet Drag Handle ──
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              // ── Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_rounded, color: _orange, size: 22),
                  const SizedBox(width: 8),
                  const Text(
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

              // ── Pulsing Avatar ──
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return SizedBox(
                    height: 150,
                    width: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ring 3 (outermost)
                        Transform.scale(
                          scale: 0.65 + _pulse3Anim.value * 0.35,
                          child: Container(
                            height: 148,
                            width: 148,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _orange.withOpacity(_opacity3Anim.value),
                            ),
                          ),
                        ),
                        // Ring 2
                        Transform.scale(
                          scale: 0.65 + _pulse2Anim.value * 0.25,
                          child: Container(
                            height: 130,
                            width: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _orange.withOpacity(_opacity2Anim.value),
                            ),
                          ),
                        ),
                        // Ring 1 (inner)
                        Transform.scale(
                          scale: 0.7 + _pulseAnim.value * 0.18,
                          child: Container(
                            height: 115,
                            width: 115,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _orange.withOpacity(_opacityAnim.value),
                            ),
                          ),
                        ),
                        // Orange border ring (static)
                        Container(
                          height: 96,
                          width: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _orange, width: 3),
                            color: Colors.orange.shade50,
                          ),
                        ),
                        // Avatar
                        // Avatar
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.orange.shade100,
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: profilePhoto != null && profilePhoto.isNotEmpty
                              ? Image.network(
                                  profilePhoto,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Text(
                                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                        style: TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: _orange,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: _orange,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  );
                },
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

              // ── Rate Badge ──
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: _orange,
                      ),
                      child: const Center(
                        child: Text('₹',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '₹$ratePerMin / min',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _orange,
                      ),
                    ),
                  ],
                ),
              ),

              // ── User Details Card ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(Icons.person_outline, 'Gender:', gender),
                    _buildDetailRow(Icons.cake_outlined, 'DOB:', dob),
                    _buildDetailRow(Icons.access_time_outlined, 'TOB:', tob),
                    _buildDetailRow(Icons.location_on_outlined, 'POB:', pob),
                    _buildDetailRow(Icons.translate_outlined, 'Languages:', languages, isLast: true),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Buttons ──
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        _stopRingtone();
                        try {
                          await Get.find<ApiClient>()
                              .post(AppUrls.rejectChatSession(sessionId));
                        } catch (e) {
                          debugPrint('Reject error: $e');
                        }
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.red.shade400, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Reject',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        _stopRingtone();
                        LocalNotificationService.cancelIncomingCallNotification(sessionId);
                        try {
                          final response = await Get.find<ApiClient>()
                              .post(AppUrls.acceptChatSession(sessionId));
                          if (response.isSuccess) {
                            Get.back();
                            
                            // Ensure we have a valid start time to start the timer immediately
                            final startedAt = response.body?['data']?['session']?['started_at']?.toString() 
                                           ?? DateTime.now().toUtc().toIso8601String();

                            // Add start time to WebSocketService so it persists
                            WebSocketService.sessionStartTimes[sessionId] = startedAt;

                            Get.to(
                              () => ChatScreen(
                                userName: name,
                                userImage: profilePhoto ?? '',
                                sessionId: sessionId,
                                initialStatus: 'ongoing',
                                startedAtString: startedAt,
                              ),
                              binding: ChatBinding(),
                            );
                          } else {
                            Get.back();
                            CustomSnackBar.disabledSnackbar('Error', response.message);
                          }
                        } catch (e) {
                          debugPrint('Accept error: $e');
                          Get.back();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2DB84B),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                      child: const Text('Accept',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFE07B2D)),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _darkText),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
