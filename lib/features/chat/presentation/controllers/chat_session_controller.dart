import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/services/websocket/websocket_service.dart';
import 'package:astro_astrologer/core/enums/session_status_enums.dart';
import 'package:astro_astrologer/core/services/sound_vibration_service.dart';
import 'package:astro_astrologer/core/services/foreground_task_service.dart';
import 'package:astro_astrologer/core/utils/logger.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';
import 'package:astro_astrologer/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_astrologer/core/services/callkit_service.dart';
import 'package:astro_astrologer/features/chat/domain/usecases/end_chat_session_usecase.dart';
import 'package:astro_astrologer/features/chat/domain/usecases/accept_chat_session_usecase.dart';
import 'package:astro_astrologer/features/auth/presentation/controllers/auth_controller.dart';
import 'package:astro_astrologer/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_astrologer/features/chat/presentation/bindings/chat_binding.dart';
import 'package:astro_astrologer/core/services/storage/shared_prefs.dart';
import 'package:astro_astrologer/core/constants/app_constants.dart';
import 'package:astro_astrologer/features/auth/data/models/user_model.dart';
import 'chat_controller.dart';
import 'package:astro_astrologer/routes/app_routes.dart';

class ChatSessionController extends GetxController with WidgetsBindingObserver {
  final EndChatSessionUseCase _endChatSessionUseCase;
  final AcceptChatSessionUseCase _acceptChatSessionUseCase;

  ChatSessionController({
    required EndChatSessionUseCase endChatSessionUseCase,
    required AcceptChatSessionUseCase acceptChatSessionUseCase,
  })  : _endChatSessionUseCase = endChatSessionUseCase,
        _acceptChatSessionUseCase = acceptChatSessionUseCase;

  final Rx<ChatStatus> status = ChatStatus.pending.obs;
  final RxInt elapsedSeconds = 0.obs;
  final RxBool isLoading = false.obs;

  bool isPackageChat = false;
  bool isCallAlsoActive = false;
  int? subSessionId;

  Timer? timer;
  String? startedAt;
  StreamSubscription? _endSub;
  StreamSubscription? _statusSub;
  StreamSubscription? _dismissSub;

  ChatController get _orchestrator => Get.find<ChatController>();

  void startRingtone() {
    SoundVibrationService().startRingtone(
      'audio/astrolger_app_sound.mp3',
      loop: true,
      vibrate: true,
    );
  }

  void stopRingtone() {
    SoundVibrationService().stopRingtone();
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    ForegroundTaskService.listenTaskData((data) {
      if (data is Map && data['action'] == 'hangup') {
        if (_orchestrator.sessionId != null) {
          endChatSession();
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      final ctx = Get.context;
      if (ctx == null) return;
      if ((status.value == ChatStatus.ongoing || status.value == ChatStatus.initiated) &&
          _orchestrator.sessionId != null &&
          _orchestrator.userName != null) {
        minimizeToBubble(ctx, _orchestrator.userName!, "", shouldPop: false);
      }
    } else if (state == AppLifecycleState.resumed) {
      checkPendingChatSession();
    }
  }

  Future<void> checkPendingChatSession() async {
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.get(AppUrls.getCurrentSession, handleError: false, showErrorScreen: false);
      if (!response.isSuccess || response.body == null) return;

      final body = response.body;
      final sessionData = body is Map ? (body['session'] ?? body['data']?['session'] ?? body['data']) : null;
      if (sessionData == null) return;

      final String sessionStatus = sessionData['status']?.toString() ?? '';
      if (sessionStatus != 'initiated' && sessionStatus != 'ongoing') return;

      final int incomingId = int.tryParse(sessionData['id']?.toString() ?? '') ?? 0;
      if (incomingId == 0) return;

      final senderData = sessionData['consumer'] ?? sessionData['user'] ?? {};
      final String userName = senderData['name']?.toString() ?? 'User';
      final String userAvatarRaw = senderData['profile_photo_url']?.toString() ?? senderData['profile_photo']?.toString() ?? '';
      final String userAvatar = userAvatarRaw.isNotEmpty && userAvatarRaw != 'null' ? userAvatarRaw : 'assets/images/app_logo.png';

      if (sessionStatus == 'initiated') {
        if (status.value == ChatStatus.initiated && _orchestrator.sessionId == incomingId) return;
        CallkitService.showCallkitNotification(sessionId: incomingId.toString(), callerName: userName, avatar: userAvatar, type: 'chat');
      } else if (sessionStatus == 'ongoing') {
        if (_orchestrator.sessionId == incomingId) return;
        SoundVibrationService().stopRingtone();
        final startTime = sessionData['updated_at']?.toString() != null ? parseSmartDate(sessionData['updated_at']?.toString() ?? '') : DateTime.now();
        final consumerName = sessionData['callerData']?['name']?.toString() ?? 'User';
        await ForegroundTaskService.startActiveSessionNotification(title: 'Active Chat with $consumerName', type: 'Chat', startedAt: startTime);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.toNamed(AppRoutes.chatScreen, arguments: {'sessionId': incomingId, 'initialStatus': 'ongoing', 'userName': userName, 'userImage': userAvatar, 'startedAtString': sessionData['updated_at']?.toString() ?? DateTime.now().toUtc().toIso8601String(), 'isPackageChat': false});
        });
      }
    } catch (_) {}
  }

  void setupSessionListeners() {
    _endSub?.cancel();
    _endSub = WebSocketService.chatEndedSessionId.listen((endedSessionId) {
      if (endedSessionId == _orchestrator.sessionId) {
        status.value = ChatStatus.completed;
        stopRingtone();
        timer?.cancel();
        if (Get.isRegistered<AuthController>()) Get.find<AuthController>().checkLoginStatus();
        Future.delayed(const Duration(milliseconds: 400), () {
          if (Get.currentRoute.isNotEmpty && Get.isRegistered<ChatController>()) Get.back();
        });
      }
    });

    _dismissSub?.cancel();
    _dismissSub = WebSocketService.chatDismissedSessionId.listen((dismissedSessionId) {
      if (dismissedSessionId == _orchestrator.sessionId) {
        status.value = ChatStatus.completed;
        stopRingtone();
        timer?.cancel();
        Get.back();
      }
    });

    _statusSub?.cancel();
    _statusSub = WebSocketService.sessionStatusUpdates.listen((updates) {
      final sid = _orchestrator.sessionId;
      if (sid != null && updates.containsKey(sid)) {
        final newStatus = updates[sid];
        if (newStatus != null && status.value.name != newStatus) {
          if (status.value == ChatStatus.completed || status.value == ChatStatus.cancelled || status.value == ChatStatus.rejected) return;
          status.value = ChatStatus.ongoing;
          if (newStatus == 'ongoing' || newStatus == 'accepted') {
            stopRingtone();
            final startedAtStr = WebSocketService.sessionStartTimes[sid];
            DateTime? serverStartTime;
            if (startedAtStr != null && startedAtStr.isNotEmpty) {
              String isoUtc = startedAtStr.trim().replaceAll(' ', 'T');
              if (!isoUtc.endsWith('Z') && !isoUtc.contains('+') && !isoUtc.contains('-')) isoUtc += 'Z';
              serverStartTime = DateTime.tryParse(isoUtc)?.toLocal();
            }
            final effectiveStart = serverStartTime ?? DateTime.now();
            startedAt = effectiveStart.toUtc().toIso8601String();
            WebSocketService.sessionStartTimes[sid] = startedAt!;
            final diff = DateTime.now().difference(effectiveStart).inSeconds;
            elapsedSeconds.value = diff >= 0 ? diff : 0;
            setupTimer(startedAt);
            ForegroundTaskService.startActiveSessionNotification(title: 'Chat in progress', type: 'Chat', startedAt: effectiveStart);
          }
        }
      }
    });
  }

  void setupTimer(String? startedAtString) {
    timer?.cancel();
    final currentSt = status.value.name.toLowerCase();
    if (currentSt == 'ended' || currentSt == 'completed' || currentSt == 'cancelled' || currentSt == 'rejected') return;

    final sid = _orchestrator.sessionId;
    if (startedAtString != null && sid != null) {
      startedAt = startedAtString;
      WebSocketService.sessionStartTimes[sid] = startedAtString;
    }

    final startedAtStr = startedAtString ?? startedAt ?? (sid != null ? WebSocketService.sessionStartTimes[sid] : null);
    final dt = parseSmartDate(startedAtStr);

    if (dt != null) {
      final st = status.value.name.toLowerCase();
      if (st == 'ongoing' || st == 'accepted') {
        final nowDiff = DateTime.now().difference(dt).inSeconds;
        if (FloatingChatBubble.isActive && FloatingChatBubble.sessionId == sid) {
          elapsedSeconds.value = FloatingChatBubble.currentElapsedSeconds;
        } else if (nowDiff >= 0) {
          elapsedSeconds.value = nowDiff;
        }
      }
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        final st = status.value.name.toLowerCase();
        if (st == 'ended' || st == 'completed' || st == 'cancelled' || st == 'rejected') {
          t.cancel();
          return;
        }
        if (st == 'ongoing' || st == 'accepted') {
          final nowDiff = DateTime.now().difference(dt).inSeconds;
          if (FloatingChatBubble.isActive && FloatingChatBubble.sessionId == sid) {
            elapsedSeconds.value++;
            FloatingChatBubble.updateStatus(status.value.name);
          } else if (nowDiff >= 0) {
            elapsedSeconds.value = nowDiff;
          } else {
            elapsedSeconds.value++;
          }
        }
      });
    } else {
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        final st = status.value.name.toLowerCase();
        if (st == 'ended' || st == 'completed' || st == 'cancelled' || st == 'rejected') {
          t.cancel();
          return;
        }
        if (st == 'ongoing' || st == 'accepted') {
          elapsedSeconds.value++;
          if (sid != null) {
            final genStart = DateTime.now().toUtc().subtract(Duration(seconds: elapsedSeconds.value)).toIso8601String();
            startedAt = genStart;
            WebSocketService.sessionStartTimes[sid] = genStart;
          }
        }
      });
    }
  }

  DateTime? parseSmartDate(dynamic input) {
    if (input == null) return null;
    if (input is DateTime) return input.toLocal();
    final dateStr = input.toString().trim();
    if (dateStr.isEmpty) return null;
    String isoUtc = dateStr.replaceAll(' ', 'T');
    bool hasTimezone = isoUtc.endsWith('Z') || isoUtc.contains(RegExp(r'[+-]\d{2}(:?\d{2})?$'));
    if (!hasTimezone) isoUtc += 'Z';
    DateTime? parsed = DateTime.tryParse(isoUtc)?.toLocal();
    if (parsed != null && !parsed.isAfter(DateTime.now())) return parsed;
    parsed = DateTime.tryParse(dateStr.replaceAll(' ', 'T')) ?? DateTime.tryParse(dateStr);
    return parsed?.toLocal();
  }

  Future<void> terminateChannelOnly() async {
    final subId = subSessionId;
    if (subId == null) return;
    try {
      isLoading.value = true;
      await Get.find<ApiClient>().post(AppUrls.packageTerminateChannel, data: {'sub_session_id': subId, 'channel_type': 'chat', 'action': 'channel_only'});
      status.value = ChatStatus.completed;
      timer?.cancel();
      FloatingChatBubble.dismiss();
      WebSocketService.activeSessionId = null;
      Get.back();
    } catch (_) {
      CustomSnackBar.showError('Failed to end chat.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> terminateEntireSession() async {
    final subId = subSessionId;
    if (subId == null) {
      await endChatSession();
      return;
    }
    try {
      isLoading.value = true;
      await Get.find<ApiClient>().post(AppUrls.packageTerminateChannel, data: {'sub_session_id': subId, 'channel_type': 'chat', 'action': 'complete_session'});
      status.value = ChatStatus.completed;
      timer?.cancel();
      FloatingChatBubble.dismiss();
      WebSocketService.activeSessionId = null;
      Get.back();
    } catch (_) {
      await endChatSession();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectChatSession() async {
    stopRingtone();
    if (_orchestrator.sessionId == null) {
      Get.back();
      return;
    }
    status.value = ChatStatus.completed;
    timer?.cancel();
    ForegroundTaskService.stopService();
    FloatingChatBubble.dismiss();
    CallkitService.endAllCalls();
    if (Get.isRegistered<ChatController>()) Get.back();
    try {
      await Get.find<ApiClient>().post(AppUrls.rejectChatSession(_orchestrator.sessionId!));
    } catch (_) {}
  }

  Future<void> endChatSession() async {
    if (_orchestrator.sessionId == null) return;
    isLoading.value = true;
    try {
      final session = await _endChatSessionUseCase.execute(_orchestrator.sessionId!);
      if (session != null) WebSocketService.activeSessionId = null;
    } catch (_) {} finally {
      isLoading.value = false;
      status.value = ChatStatus.completed;
      timer?.cancel();
      FloatingChatBubble.dismiss();
      CallkitService.endAllCalls();
    }
  }

  Future<void> acceptChat(int incomingSessionId) async {
    stopRingtone();
    try {
      await _acceptChatSessionUseCase.execute(incomingSessionId);
      CallkitService.endAllCalls();
    } catch (_) {}
  }

  Future<void> rejectChat(int incomingSessionId) async {
    try {
      FloatingChatBubble.dismiss(stopForegroundService: true);
      CallkitService.endAllCalls();
      await Get.find<ApiClient>().post(AppUrls.rejectChatSession(incomingSessionId));
    } catch (_) {}
  }

  void minimizeToBubble(BuildContext context, String name, String image, {bool shouldPop = true}) {
    final sid = _orchestrator.sessionId;
    if (sid == null || (status.value != ChatStatus.ongoing && status.value != ChatStatus.initiated)) return;
    WebSocketService.activeSessionId = null;
    final startStr = startedAt ?? WebSocketService.sessionStartTimes[sid] ?? DateTime.now().toUtc().subtract(Duration(seconds: elapsedSeconds.value)).toIso8601String();
    WebSocketService.sessionStartTimes[sid] = startStr;
    FloatingChatBubble.show(
      sessionId: sid,
      name: name,
      imageUrl: image,
      startedAt: startStr,
      status: status.value.name,
      onTap: () async {
        FloatingChatBubble.dismiss(stopForegroundService: false);
        String liveStatus = 'ongoing';
        Map<String, dynamic> liveSession = {};
        Map<String, dynamic> liveSender = {};
        try {
          final apiClient = Get.find<ApiClient>();
          final response = await apiClient.get(AppUrls.getCurrentSession, handleError: false, showErrorScreen: false);
          if (response.isSuccess && response.body != null) {
            final body = response.body;
            final raw = body is Map ? (body['session'] ?? body['data']?['session'] ?? body['data']) : null;
            if (raw != null) {
              liveSession = Map<String, dynamic>.from(raw);
              liveStatus = liveSession['status']?.toString() ?? 'ongoing';
              final sd = liveSession['consumer'] ?? liveSession['user'];
              if (sd != null) liveSender = Map<String, dynamic>.from(sd);
            }
          }
        } catch (_) {}

        if (liveStatus == 'initiated') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (liveSession.isEmpty && sid != null) liveSession = {'id': sid, 'status': 'initiated'};
            if (liveSender.isEmpty) liveSender = WebSocketService.lastChatSenderData ?? {'name': name, 'profile_photo': image};
            final String userName = liveSender['name']?.toString() ?? 'User';
            final String userAvatarRaw = liveSender['profile_photo_url']?.toString() ?? liveSender['profile_photo']?.toString() ?? '';
            final String userAvatar = userAvatarRaw.isNotEmpty && userAvatarRaw != 'null' ? userAvatarRaw : 'assets/images/app_logo.png';
            final incomingId = sid ?? (liveSession['id'] != null ? int.tryParse(liveSession['id'].toString()) : 0);
            CallkitService.showCallkitNotification(sessionId: incomingId.toString(), callerName: userName, avatar: userAvatar, type: 'chat');
          });
        } else {
          final sessionId = liveSession['id'] != null ? int.tryParse(liveSession['id'].toString()) ?? sid : sid;
          Get.toNamed(AppRoutes.chatScreen, arguments: {'userName': name, 'userImage': image, 'sessionId': sessionId, 'initialStatus': liveStatus, 'startedAtString': startStr, 'isPackageChat': false});
        }
      },
    );
    if (shouldPop) Get.back();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();
    _endSub?.cancel();
    _statusSub?.cancel();
    _dismissSub?.cancel();
    if (status.value == ChatStatus.completed || status.value == ChatStatus.cancelled || status.value == ChatStatus.rejected) {
      FloatingChatBubble.dismiss(stopForegroundService: true);
      if (WebSocketService.activeSessionId == _orchestrator.sessionId) WebSocketService.activeSessionId = null;
    }
    super.onClose();
  }
}
