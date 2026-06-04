import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

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
}
