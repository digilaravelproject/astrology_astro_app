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

class DashboardController extends GetxController {
  var selectedIndex = 0.obs;

  void changeIndex(int index) {
    debugPrint('DashboardController: changeIndex to $index');
    selectedIndex.value = index;
  }

  @override
  void onReady() {
    super.onReady();
    final isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;
    if (isLoggedIn) {
      _checkCurrentActiveSession();
      Get.find<CallController>().checkCurrentActiveCallSession();
    }
  }

  Future<void> _checkCurrentActiveSession() async {
    try {
      final response = await Get.find<ApiClient>().get(AppUrls.getCurrentSession);
      if (response.isSuccess && response.body != null && response.body['data'] != null) {
        final session = response.body['data'];
        final sessionId = session['id'];
        final status = session['status'];
        final startedAt = session['started_at'] ?? session['accepted_at'] ?? session['created_at'];
        // For astrologer app, other person is consumer
        final name = session['consumer']?['name'] ?? 'User';
        
        if (status == 'ongoing' || status == 'initiated' || status == 'accepted') {
          FloatingChatBubble.show(
             context: Get.context!,
             sessionId: sessionId,
             name: name,
             imageUrl: '', // We don't have the image in this payload
             status: status,
             startedAt: startedAt,
             onTap: () {
               final currentStatus = FloatingChatBubble.chatStatus.value;
               FloatingChatBubble.dismiss();
               Get.to(
                 () => ChatScreen(
                   userName: name,
                   userImage: '',
                   sessionId: sessionId,
                   initialStatus: currentStatus,
                   startedAtString: startedAt,
                 ),
                 binding: ChatBinding(),
               );
             }
          );
        }
      }
    } catch (e) {
      debugPrint("Error checking active session: $e");
    }
  }
}
