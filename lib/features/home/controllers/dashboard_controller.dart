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
import 'package:astro_astrologer/core/services/network/websocket_service.dart';

class DashboardController extends GetxController {
  var selectedIndex = 0.obs;

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
      checkCurrentActiveSession();
      Get.find<CallController>().checkCurrentActiveCallSession();
    }
  }

  Future<void> checkCurrentActiveSession() async {
    try {
      final response = await Get.find<ApiClient>().get(AppUrls.getCurrentSession);
      if (response.isSuccess && response.body != null) {
        final data = response.body;
        final session = (data is Map)
            ? (data['session'] ?? data['data']?['session'] ?? data['data'] ?? data)
            : null;
        if (session != null && session is Map) {
          final sessionId = session['id'];
          final status = session['status'];
          final startedAt = session['started_at'] ?? session['accepted_at'] ?? session['created_at'];
          final name = session['consumer']?['name'] ?? session['user']?['name'] ?? 'User';
          final imageUrl = session['consumer']?['image'] ?? session['user']?['image'] ?? session['consumer']?['avatar'] ?? '';

          if (sessionId != null && startedAt != null) {
            WebSocketService.sessionStartTimes[sessionId] = startedAt.toString();
          }

          DateTime? parsedStart;
          if (startedAt != null) {
            String isoUtc = startedAt.toString().replaceAll(' ', 'T');
            if (!isoUtc.endsWith('Z') && !isoUtc.contains('+') && !isoUtc.contains('-')) {
              isoUtc += 'Z';
            }
            parsedStart = DateTime.tryParse(isoUtc)?.toLocal();
          }
          final int? startedAtMillis = parsedStart?.millisecondsSinceEpoch;

          if (sessionId != null && (status == 'ongoing' || status == 'initiated' || status == 'accepted')) {
            final sessionType = session['session_type']?.toString().toLowerCase() ?? 
                                session['type']?.toString().toLowerCase() ?? 
                                session['mode']?.toString().toLowerCase() ?? '';
            final isCall = sessionType == 'call' || sessionType == 'audio_call' || sessionType == 'video_call';

            if (!isCall) {
              LocalNotificationService.showOngoingChatNotification(
                sessionId: sessionId,
                title: '$name • Chat',
                body: 'Ongoing chat session',
                startedAtMillis: startedAtMillis,
              );
              FloatingChatBubble.show(
                context: Get.context!,
                sessionId: sessionId,
                name: name,
                imageUrl: imageUrl,
                status: status,
                startedAt: startedAt,
                onTap: () {
                  final currentStatus = FloatingChatBubble.chatStatus.value;
                  Get.to(
                    () => ChatScreen(
                      userName: name,
                      userImage: imageUrl,
                      sessionId: sessionId,
                      initialStatus: currentStatus,
                      startedAtString: startedAt,
                    ),
                    binding: ChatBinding(),
                  );
                },
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error checking active session: $e");
    }
  }
}
