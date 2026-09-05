import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:astro_astrologer/core/utils/logger.dart';
import 'dart:io';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(CallForegroundTaskHandler());
}

class CallForegroundTaskHandler extends TaskHandler {
  int? _startedAtMillis;
  String _sessionType = 'Chat';
  String _title = 'Active Session';
  int _elapsedCounter = 0;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    Logger.d('Foreground Task Started');
    _startedAtMillis = await FlutterForegroundTask.getData<int>(
      key: 'startedAt',
    );
    final type = await FlutterForegroundTask.getData<String>(
      key: 'sessionType',
    );
    if (type != null) _sessionType = type;
    final title = await FlutterForegroundTask.getData<String>(
      key: 'title',
    );
    if (title != null) _title = title;
  }

  @override
  void onReceiveData(Object data) {
    if (data is Map) {
      if (data['startedAt'] != null) {
        _startedAtMillis = data['startedAt'] as int;
        _elapsedCounter = 0; // Reset counter on new session data
      }
      if (data['sessionType'] != null) {
        _sessionType = data['sessionType'] as String;
      }
      if (data['title'] != null) {
        _title = data['title'] as String;
      }
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    if (_startedAtMillis == null) {
      _startedAtMillis = await FlutterForegroundTask.getData<int>(key: 'startedAt');
    }
    if (_title == 'Active Session') {
      final savedTitle = await FlutterForegroundTask.getData<String>(key: 'title');
      if (savedTitle != null) _title = savedTitle;
    }

    if (_startedAtMillis != null) {
      final startedAt = DateTime.fromMillisecondsSinceEpoch(_startedAtMillis!);
      final diff = DateTime.now().difference(startedAt).inSeconds;
      
      if (diff >= 0) {
        _elapsedCounter = diff;
      } else {
        _elapsedCounter++;
      }

      final String timeString = _formatDuration(_elapsedCounter);
      FlutterForegroundTask.updateService(
        notificationTitle: _title,
        notificationText: 'Ongoing session • $timeString',
      );
    }
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

  @override
  void onNotificationPressed() {
    // This is called when the notification itself is tapped.
    FlutterForegroundTask.sendDataToMain({'action': 'tap'});
    FlutterForegroundTask.launchApp();
  }

  String _formatDuration(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class ForegroundTaskService {
  static Future<void> init() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'active_session_silent_channel_v1',
        channelName: 'Active Consultation Service',
        channelDescription: 'Ongoing active call and chat consultation status',
        channelImportance: NotificationChannelImportance.LOW, // Silent
        priority: NotificationPriority.LOW,
        enableVibration: false,
        playSound: false,
        visibility: NotificationVisibility.VISIBILITY_PUBLIC,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(
          1000,
        ), // Fire onRepeatEvent every 1s
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
        stopWithTask: false,
      ),
    );
  }

  static Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final NotificationPermission notificationPermissionStatus =
          await FlutterForegroundTask.checkNotificationPermission();
      if (notificationPermissionStatus != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }
    }
  }

  /// Start a unified, persistent, and silent notification with a live timer
  static Future<void> startActiveSessionNotification({
    required String title,
    required String type, // 'Chat' or 'Call'
    DateTime? startedAt,
  }) async {
    await requestPermissions();

    // Default to now if not provided
    final startTimeMillis =
        (startedAt ?? DateTime.now()).millisecondsSinceEpoch;

    await FlutterForegroundTask.saveData(
      key: 'startedAt',
      value: startTimeMillis,
    );
    await FlutterForegroundTask.saveData(key: 'sessionType', value: type);
    await FlutterForegroundTask.saveData(key: 'title', value: title);

    try {
      if (await FlutterForegroundTask.isRunningService) {
        FlutterForegroundTask.sendDataToTask({
          'startedAt': startTimeMillis,
          'sessionType': type,
          'title': title,
        });
        FlutterForegroundTask.updateService(
          notificationTitle: title,
          notificationText: 'Ongoing session • 00:00',
        );
      } else {
        // Add a 1.5s delay to avoid OOM crash on low-RAM devices during WebRTC init
        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (await FlutterForegroundTask.isRunningService) {
          FlutterForegroundTask.sendDataToTask({
            'startedAt': startTimeMillis,
            'sessionType': type,
            'title': title,
          });
          FlutterForegroundTask.updateService(
            notificationTitle: title,
            notificationText: 'Ongoing session • 00:00',
          );
        } else {
          await FlutterForegroundTask.startService(
            notificationTitle: title,
            notificationText: 'Ongoing session • 00:00',
            callback: startCallback,
          );
        }
      }
    } catch (e) {
      Logger.d("ForegroundTaskService startService failed: $e");
    }

  }

  static void listenTaskData(Function(dynamic) callback) {
    FlutterForegroundTask.addTaskDataCallback(callback);
  }

  static Future<void> stopService() async {
    try {
      await FlutterForegroundTask.stopService();
    } catch (e) {
      Logger.d("ForegroundTaskService stopService failed: $e");
    }
  }

  static void launchApp() {
    FlutterForegroundTask.launchApp();
  }
}
