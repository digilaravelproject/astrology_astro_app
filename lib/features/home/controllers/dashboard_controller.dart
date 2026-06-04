import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_astrologer/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_astrologer/features/chat/bindings/chat_binding.dart';

class DashboardController extends GetxController {
  var selectedIndex = 0.obs;

  void changeIndex(int index) {
    debugPrint('DashboardController: changeIndex to $index');
    selectedIndex.value = index;
  }

  @override
  void onReady() {
    super.onReady();
    _checkOverlayPermission();
    _checkCurrentActiveSession();
  }

  Future<void> _checkOverlayPermission() async {
    if (GetPlatform.isAndroid) {
      try {
        final bool isGranted = await FlutterOverlayWindow.isPermissionGranted();
        if (!isGranted) {
          Get.dialog(
            CupertinoAlertDialog(
              title: const Text('Overlay Permission'),
              content: const Text('To show the floating chat bubble when the app is in the background, please allow "Display over other apps" permission.'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('Cancel'),
                  onPressed: () => Get.back(),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text('Allow'),
                  onPressed: () {
                    Get.back();
                    FlutterOverlayWindow.requestPermission();
                  },
                ),
              ],
            ),
          );
        }
      } catch (e) {
        debugPrint('Error checking overlay permission: $e');
      }
    }
  }

  Future<void> _checkCurrentActiveSession() async {
    try {
      if (await FlutterOverlayWindow.isActive()) return;
      
      final response = await Get.find<ApiClient>().get(AppUrls.getCurrentSession);
      if (response.isSuccess && response.body['data'] != null) {
        final session = response.body['data'];
        final sessionId = session['id'];
        final status = session['status'];
        final startedAt = session['accepted_at'] ?? session['created_at'];
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
