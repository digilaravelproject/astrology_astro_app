import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/services/websocket/websocket_service.dart';
import 'package:astro_astrologer/core/services/foreground_task_service.dart';
import 'package:astro_astrologer/core/services/callkit_service.dart';
import 'package:astro_astrologer/core/services/sound_vibration_service.dart';
import 'package:astro_astrologer/core/utils/logger.dart';
import 'package:astro_astrologer/core/enums/session_status_enums.dart';
import 'package:astro_astrologer/core/services/storage/token_manger.dart';
import 'package:astro_astrologer/features/call/presentation/widgets/floating_call_bubble.dart';
import 'package:astro_astrologer/features/call/presentation/pages/call_screen.dart';
import 'call_controller.dart';
import 'package:astro_astrologer/routes/app_routes.dart';

class CallSessionController extends GetxController with WidgetsBindingObserver {
  final Rx<CallStatus> status = CallStatus.idle.obs;
  final RxInt durationSeconds = 0.obs;
  DateTime? callStartedAt;

  bool isMuted = false;
  bool isSpeakerOn = false;
  bool isCallScreenVisible = false;
  bool isPackageCall = false;
  int? subSessionId;
  bool isChatAlsoActive = false;
  int? activeChatSessionId;

  int? sessionId;
  int? consumerId;
  String? consumerName;
  String? consumerImage;
  String? incomingOfferSdp;

  Timer? callTimer;
  Timer? ringingTimer;
  bool isSummaryShown = false;

  StreamSubscription? _initiatedSubscription;
  StreamSubscription? _dismissedSubscription;
  StreamSubscription? _iceSubscription;
  StreamSubscription? _endedSubscription;

  CallController get _orchestrator => Get.find<CallController>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    setupWebSocketListeners();
  }

  void setupWebSocketListeners() {
    _initiatedSubscription = WebSocketService.callInitiatedEvent.stream.listen((data) {
      if (status.value == CallStatus.idle) {
        final session = data['session'];
        final callerData = data['callerData'];
        if (session != null && callerData != null) {
          sessionId = int.tryParse(session['id']?.toString() ?? '') ?? 0;
          consumerId = int.tryParse(callerData['id']?.toString() ?? '') ?? 0;
          consumerName = callerData['name']?.toString() ?? 'User';
          consumerImage = callerData['profile_photo']?.toString();
          isPackageCall = session['is_package'] == true || int.tryParse(session['sub_session_id']?.toString() ?? '') != null;
          subSessionId = int.tryParse(session['sub_session_id']?.toString() ?? '');
          final offerSdp = callerData['offer']?.toString();
          if (offerSdp != null) {
            handleIncomingCall(offerSdp);
          }
        }
      }
    });

    _dismissedSubscription = WebSocketService.callDismissedData.listen((data) {
      if (data.isNotEmpty) {
        final session = data['session'];
        if (session != null) {
          final incomingId = int.tryParse(session['id']?.toString() ?? '');
          if (incomingId == sessionId) {
            final reason = data['reason']?.toString() ?? 'dismissed';
            handleCallDismissed(reason);
          }
        }
      }
    });

    _iceSubscription = WebSocketService.iceCandidateData.listen((data) {
      if (data.isNotEmpty) {
        final session = data['session'];
        if (session != null) {
          final incomingId = int.tryParse(session['id']?.toString() ?? '');
          if (incomingId == sessionId) {
            final candidate = data['candidate']?.toString();
            final receiverId = data['receiverId'];
            if (candidate != null && receiverId == WebSocketService.currentUserId) {
              _orchestrator.webrtcService.addRemoteCandidate(candidate);
            }
          }
        }
      }
    });

    _endedSubscription = WebSocketService.callEndedData.listen((data) {
      if (data.isNotEmpty) {
        final session = data['session'];
        if (session != null) {
          final incomingId = int.tryParse(session['id']?.toString() ?? '');
          if (incomingId != null && (sessionId == null || incomingId == sessionId)) {
            handleCallEnded(data);
          }
        }
      }
    });
  }

  void handleIncomingCall(String offerSdp) {
    incomingOfferSdp = offerSdp;
    isSummaryShown = false;
    status.value = CallStatus.ringing;
    startRingtone(isIncoming: true);
    startRingingTimeout();

    final String name = (consumerName != null && consumerName!.isNotEmpty) ? consumerName! : 'User';
    final String userAvatar = (consumerImage != null && consumerImage!.isNotEmpty && consumerImage != 'null') ? consumerImage! : 'assets/images/app_logo.png';

    if (CallkitService.lastAcceptedSessionId == sessionId?.toString()) {
      return;
    }

    CallkitService.showCallkitNotification(
      sessionId: sessionId.toString(),
      callerName: name,
      avatar: userAvatar,
      type: 'call',
    );
  }

  void handleCallDismissed(String reason) {
    status.value = CallStatus.values.firstWhere((e) => e.name == reason, orElse: () => CallStatus.cancelled);
    if (isCallScreenVisible || (Get.isDialogOpen ?? false)) {
      Get.back();
    }
    cleanUp();
  }

  void handleCallEnded(Map<String, dynamic> data) {
    if (isSummaryShown) return;
    isSummaryShown = true;
    status.value = CallStatus.completed;

    final session = data['session'];
    int sId = sessionId ?? 0;
    if (session != null) {
      sId = int.tryParse(session['id']?.toString() ?? '') ?? sId;
    }
    final sIdBeforeCleanup = sessionId ?? sId;
    cleanUp();

    if (isCallScreenVisible || Get.currentRoute == '/CallScreen') {
      Get.until((route) => route.isFirst);
    }
  }

  void startRingingTimeout() {
    ringingTimer?.cancel();
    ringingTimer = Timer(const Duration(seconds: 60), () {
      if (status.value == CallStatus.ringing) {
        status.value = CallStatus.missed;
        cleanUp();
      }
    });
  }

  void startCallTimer() {
    callTimer?.cancel();
    callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      durationSeconds.value++;
    });
  }

  void showOngoingNotification() {
    if (sessionId != null) {
      ForegroundTaskService.startActiveSessionNotification(
        title: 'Active Call'.tr,
        type: 'Call',
        startedAt: callStartedAt ?? DateTime.now(),
      );
    }
  }

  void startRingtone({required bool isIncoming}) {
    SoundVibrationService().startRingtone('audio/astrolger_app_sound.mp3', loop: true, vibrate: true);
  }

  void stopRingtone() {
    SoundVibrationService().stopRingtone();
  }

  void cleanUp() {
    if (status.value == CallStatus.idle && sessionId == null) return;
    stopRingtone();
    CallkitService.endAllCalls();
    callTimer?.cancel();
    callTimer = null;
    ringingTimer?.cancel();
    ringingTimer = null;
    ForegroundTaskService.stopService();
    FloatingCallBubble.dismiss();
    _orchestrator.webrtcService.dispose();
    status.value = CallStatus.idle;
    _orchestrator.isMuted.value = false;
    _orchestrator.isSpeakerOn.value = false;
    sessionId = null;
    consumerId = null;
    consumerName = null;
    consumerImage = null;
    incomingOfferSdp = null;
    isPackageCall = false;
    subSessionId = null;
    isChatAlsoActive = false;
    activeChatSessionId = null;
    if (isCallScreenVisible) isCallScreenVisible = false;
    callStartedAt = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      final ctx = Get.context;
      if (ctx == null) return;
      if ((status.value == CallStatus.ongoing || status.value == CallStatus.ringing || status.value == CallStatus.dialing) && sessionId != null && consumerName != null) {
        minimizeToBubble(ctx, consumerName!, consumerImage ?? "", shouldPop: false);
      }
    } else if (state == AppLifecycleState.resumed) {
      TokenManager.getToken().then((token) {
        if (token != null && token.isNotEmpty) {
          _orchestrator.checkPendingCall();
        }
      });
    }
  }

  void minimizeToBubble(BuildContext context, String name, String image, {bool shouldPop = true}) {
    if (_orchestrator.isEndingCall) return;
    if (sessionId == null || (status.value != CallStatus.ongoing && status.value != CallStatus.ringing && status.value != CallStatus.dialing)) return;
    
    final startStr = callStartedAt?.toIso8601String() ?? WebSocketService.sessionStartTimes[sessionId!] ?? DateTime.now().subtract(Duration(seconds: durationSeconds.value)).toIso8601String();
    WebSocketService.sessionStartTimes[sessionId!] = startStr;

    FloatingCallBubble.show(
      context: context,
      sessionId: sessionId!,
      name: name,
      imageUrl: image,
      startedAt: status.value == CallStatus.ongoing ? startStr : null,
      status: status.value.name,
      onTap: () {
        FloatingCallBubble.dismiss(stopForegroundService: false);
        if (status.value != CallStatus.ringing) {
          Get.toNamed(AppRoutes.callScreen);
        }
      },
    );
    if (shouldPop) Get.back();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _initiatedSubscription?.cancel();
    _dismissedSubscription?.cancel();
    _iceSubscription?.cancel();
    _endedSubscription?.cancel();
    cleanUp();
    super.onClose();
  }
}
