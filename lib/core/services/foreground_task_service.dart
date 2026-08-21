import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:astro_astrologer/core/utils/logger.dart';
import 'dart:io';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(CallForegroundTaskHandler());
}

class CallForegroundTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    Logger.d('Foreground Task Started');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // No-op
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    Logger.d('Foreground Task Destroyed');
  }

  @override
  void onNotificationButtonPressed(String id) {
    if (id == 'hangup_btn') {
      FlutterForegroundTask.sendDataToMain({'action': 'hangup'});
    }
  }
}

class ForegroundTaskService {
  static Future<void> init() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'active_consultation_foreground_channel_v5',
        channelName: 'Active Consultation Service',
        channelDescription: 'Ongoing active call and chat consultation status',
        channelImportance: NotificationChannelImportance.MAX,
        priority: NotificationPriority.MAX,
        visibility: NotificationVisibility.VISIBILITY_PUBLIC,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
        stopWithTask: false,
      ),
    );
  }

  static Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
      final NotificationPermission notificationPermissionStatus = await FlutterForegroundTask.checkNotificationPermission();
      if (notificationPermissionStatus != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }
    }
  }

  static Future<void> startService({required String title, required String text}) async {
    await requestPermissions();
    const buttons = [
      NotificationButton(
        id: 'hangup_btn',
        text: 'Hang up',
      ),
    ];
    if (await FlutterForegroundTask.isRunningService) {
      FlutterForegroundTask.updateService(
        notificationTitle: title,
        notificationText: text,
      );
    } else {
      await FlutterForegroundTask.startService(
        notificationTitle: title,
        notificationText: text,
        callback: startCallback,
        notificationButtons: buttons,
      );
    }
  }

  static void listenTaskData(Function(dynamic) callback) {
    FlutterForegroundTask.addTaskDataCallback(callback);
  }

  static Future<void> stopService() async {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }
}
