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
import 'package:astro_astrologer/core/services/storage/shared_prefs.dart';

class CallSessionController extends GetxController with WidgetsBindingObserver {
  final Rx<CallStatus> status = CallStatus.idle.obs;
  final RxInt durationSeconds = 0.obs;
  DateTime? callStartedAt;

  bool isMuted = false;
  bool isSpeakerOn = false;
  bool isCallScreenVisible = false;
  bool isPackageCall = false;
  bool isLiveCall = false;
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
          isLiveCall = session['session_type'] == 'live';
          subSessionId = int.tryParse(session['sub_session_id']?.toString() ?? '');
          final offerSdp = callerData['offer']?.toString();
          if (offerSdp != null) {
            handleIncomingCall(offerSdp, isLiveCall: isLiveCall);
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

  void handleIncomingCall(String offerSdp, {bool isLiveCall = false}) {
    incomingOfferSdp = offerSdp;
    isSummaryShown = false;
    status.value = CallStatus.ringing;
    startRingtone(isIncoming: true);
    startRingingTimeout();

    if (isLiveCall) {
      _showLiveCallIncomingDialog();
      return;
    }

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

  void _showLiveCallIncomingDialog() {
    if (Get.isDialogOpen ?? false) return;
    Get.dialog(
      Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.only(top: 50, left: 16, right: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.pink.shade900,
                  backgroundImage: consumerImage != null && consumerImage!.isNotEmpty && consumerImage != 'null'
                      ? NetworkImage(consumerImage!.startsWith('http') ? consumerImage! : '${AppUrls.baseImageUrl}$consumerImage')
                      : null,
                  child: consumerImage == null || consumerImage!.isEmpty || consumerImage == 'null' ? const Icon(Icons.person, color: Colors.white) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Incoming Live Call',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${consumerName ?? 'User'} is calling you...',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                    _orchestrator.rejectCall();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: const Icon(Icons.call_end, color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Get.back();
                    _orchestrator.acceptCallDirect();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    child: const Icon(Icons.call, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
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
    final wasVisible = isCallScreenVisible;
    cleanUp();

    if (wasVisible || Get.currentRoute == '/CallScreen' || Get.currentRoute == '/call-screen' || Get.currentRoute == AppRoutes.callScreen) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      Get.back(); // Pop the call screen
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

  StreamSubscription? _globalTimerSub;

  void startCallTimer({int? startedAtMillis}) {
    callTimer?.cancel();
    _globalTimerSub?.cancel();
    _globalTimerSub = ForegroundTaskService.globalElapsedSeconds.listen((val) {
      if (val > 0) durationSeconds.value = val;
    });

    final sid = sessionId;
    if (sid == null) return;
    
    int? effectiveStartedAtMillis = startedAtMillis;
    if (effectiveStartedAtMillis != null) {
      SharedPrefs.setInt('active_call_started_at_$sid', effectiveStartedAtMillis);
    } else {
      effectiveStartedAtMillis = SharedPrefs.getInt('active_call_started_at_$sid');
      if (effectiveStartedAtMillis == null) {
        effectiveStartedAtMillis = DateTime.now().millisecondsSinceEpoch;
        SharedPrefs.setInt('active_call_started_at_$sid', effectiveStartedAtMillis);
      }
    }
    
    final startedAt = DateTime.fromMillisecondsSinceEpoch(effectiveStartedAtMillis);
    callStartedAt = startedAt;
    
    callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (ForegroundTaskService.globalElapsedSeconds.value == 0) {
        final diff = DateTime.now().difference(startedAt).inSeconds;
        durationSeconds.value = diff >= 0 ? diff : 0;
      }
    });
  }

  void showOngoingNotification() {
    if (sessionId != null) {
      try {
        ForegroundTaskService.startActiveSessionNotification(
          title: 'Active Call'.tr,
          type: 'Call',
          startedAt: callStartedAt ?? DateTime.now(),
        );
      } catch (e) {
        debugPrint('Failed to show ongoing notification: $e');
      }
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
    _globalTimerSub?.cancel();
    callTimer = null;
    ringingTimer?.cancel();
    ringingTimer = null;
    ForegroundTaskService.stopService();
    if (sessionId != null) {
      SharedPrefs.remove('active_call_started_at_$sessionId');
    }
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
