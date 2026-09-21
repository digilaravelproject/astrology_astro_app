import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/constants/app_constants.dart';
import 'package:astro_astrologer/core/services/storage/shared_prefs.dart';
import 'package:astro_astrologer/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_astrologer/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_astrologer/features/chat/presentation/bindings/chat_binding.dart';
import 'package:astro_astrologer/features/call/presentation/controllers/call_controller.dart';

import 'package:astro_astrologer/core/services/local_notification_service.dart';
import 'package:astro_astrologer/core/services/websocket/websocket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astro_astrologer/features/chat/presentation/controllers/chat_controller.dart';

class DashboardController extends GetxController with WidgetsBindingObserver {
  var selectedIndex = 0.obs;

  // Ensures we only auto-navigate to ChatScreen once on cold boot
  static bool _coldBootChecked = false;

  void changeIndex(int index) {
    debugPrint('DashboardController: changeIndex to $index');
    selectedIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    final isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;
    if (isLoggedIn) {
      checkCurrentActiveSession();
    }
  }

  @override
  void onReady() {
    super.onReady();
    final isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;
    if (isLoggedIn) {
      // On cold boot (killed state), check server for ongoing session and navigate directly
      // Use flag so this only fires ONCE per app lifecycle
      final shouldNavigate = !_coldBootChecked;
      _coldBootChecked = true;
      checkCurrentActiveSession(navigateDirectly: shouldNavigate);
      Get.find<CallController>().checkCurrentActiveCallSession();
    }
  }

  Future<void> _checkAndNavigatePendingChat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final pendingChatId = prefs.getString('pending_chat_navigation');
      print('[DASHBOARD] Checking pending chat: $pendingChatId');
      if (pendingChatId != null) {
        final name = prefs.getString('pending_chat_name') ?? 'User';
        final startedAt = prefs.getString('pending_chat_started_at');
        await prefs.remove('pending_chat_navigation');
        await prefs.remove('pending_chat_name');
        await prefs.remove('pending_chat_started_at');
        Future.delayed(const Duration(milliseconds: 800), () {
          print('[DASHBOARD] Navigating to ChatScreen for pending session $pendingChatId');
          Get.to(
            () => ChatScreen(
              sessionId: int.parse(pendingChatId),
              initialStatus: 'ongoing',
              userName: name,
              userImage: '',
              startedAtString: startedAt,
            ),
            binding: ChatBinding(),
          );
        });
      }
    } catch (e) {
      debugPrint('[DASHBOARD] Error checking pending chat: $e');
    }
  }

  Future<void> checkCurrentActiveSession({bool navigateDirectly = false}) async {
    try {
      final response = await Get.find<ApiClient>().get(
        AppUrls.getCurrentSession,
      );
      if (response.isSuccess && response.body != null) {
        final data = response.body;
        final session =
            (data is Map)
                ? (data['session'] ??
                    data['data']?['session'] ??
                    data['data'] ??
                    data)
                : null;
        if (session != null && session is Map) {
          final sessionId = session['id'];
          final status = session['status'];
          final startedAt =
              session['started_at'] ??
              session['accepted_at'] ??
              session['created_at'];
          final name =
              session['consumer']?['name'] ??
              session['user']?['name'] ??
              'User';
          final imageUrl =
              session['consumer']?['image'] ??
              session['user']?['image'] ??
              session['consumer']?['avatar'] ??
              '';

          if (sessionId != null && startedAt != null) {
            WebSocketService.sessionStartTimes[sessionId] =
                startedAt.toString();
          }

          DateTime? parsedStart;
          if (startedAt != null) {
            String isoUtc = startedAt.toString().trim().replaceAll(' ', 'T');
            bool hasTimezone = isoUtc.endsWith('Z') || isoUtc.contains(RegExp(r'[+-]\d{2}(:?\d{2})?$'));
            
            if (!hasTimezone) {
              isoUtc += 'Z';
            }
            
            DateTime? parsed = DateTime.tryParse(isoUtc)?.toLocal();
            if (parsed != null) {
              final now = DateTime.now();
              if (!parsed.isAfter(now)) {
                parsedStart = parsed;
              }
            }
            
            if (parsedStart == null) {
               DateTime? fallbackParsed = DateTime.tryParse(startedAt.toString().trim().replaceAll(' ', 'T')) ?? DateTime.tryParse(startedAt.toString().trim());
               parsedStart = fallbackParsed?.toLocal();
            }
          }
          final int? startedAtMillis = parsedStart?.millisecondsSinceEpoch;

          if (sessionId != null &&
              (status == 'ongoing' ||
                  status == 'initiated' ||
                  status == 'accepted')) {
            final sessionType =
                session['session_type']?.toString().toLowerCase() ??
                session['type']?.toString().toLowerCase() ??
                session['mode']?.toString().toLowerCase() ??
                '';
            final isCall =
                sessionType == 'call' ||
                sessionType == 'audio_call' ||
                sessionType == 'video_call';

            if (!isCall) {
              print('[DASHBOARD] Ongoing chat session found: $sessionId, navigateDirectly=$navigateDirectly');
              if (navigateDirectly) {
                // Cold boot / killed state: auto-navigate to ChatScreen directly
                Future.delayed(const Duration(milliseconds: 500), () {
                  print('[DASHBOARD] Auto-navigating to ChatScreen for session $sessionId');
                  Get.to(
                    () => ChatScreen(
                      userName: name,
                      userImage: imageUrl,
                      sessionId: sessionId,
                      initialStatus: 'ongoing',
                      startedAtString: startedAt?.toString(),
                    ),
                    binding: ChatBinding(),
                  );
                });
              } else {
                FloatingChatBubble.show(
                  sessionId: sessionId,
                  name: name,
                  imageUrl: imageUrl,
                  status: status,
                  startedAt: startedAt?.toString(),
                  onTap: () {
                    final currentStatus = FloatingChatBubble.chatStatus.value;
                    Get.to(
                      () => ChatScreen(
                        userName: name,
                        userImage: imageUrl,
                        sessionId: sessionId,
                        initialStatus: currentStatus,
                        startedAtString: startedAt?.toString(),
                      ),
                      binding: ChatBinding(),
                    );
                  },
                );
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error checking active session: $e");
    }
  }
}
