import 'dart:async';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:astro_astrologer/core/constants/app_constants.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/services/network/websocket_service.dart';
import 'package:astro_astrologer/core/services/webrtc/webrtc_service.dart';
import 'package:astro_astrologer/core/services/local_notification_service.dart';
import 'package:astro_astrologer/core/utils/logger.dart';
import 'package:astro_astrologer/features/call/presentation/widgets/incoming_call_dialog.dart';
import 'package:astro_astrologer/features/call/presentation/widgets/call_summary_dialog.dart';
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';

import 'package:flutter/material.dart';
import 'package:astro_astrologer/features/call/presentation/widgets/floating_call_bubble.dart';
import 'package:astro_astrologer/features/call/presentation/pages/call_screen.dart';

class CallController extends GetxController with WidgetsBindingObserver {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final WebRTCService webrtcService = WebRTCService();

  final RxString status = 'idle'.obs; // idle, ringing, ongoing, completed, rejected, cancelled, missed
  final RxInt durationSeconds = 0.obs;
  final RxBool isMuted = false.obs;
  final RxBool isSpeakerOn = false.obs;
  bool isCallScreenVisible = false;

  int? sessionId;
  int? consumerId;
  String? consumerName;
  String? consumerImage;

  AudioPlayer? _audioPlayer;
  Timer? _callTimer;
  Timer? _ringingTimer;
  bool _isSummaryShown = false;
  StreamSubscription? _initiatedSubscription;
  StreamSubscription? _dismissedSubscription;
  StreamSubscription? _iceSubscription;
  StreamSubscription? _endedSubscription;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _setupWebSocketListeners();
  }

  void _setupWebSocketListeners() {
    _initiatedSubscription = WebSocketService.callInitiatedEvent.stream.listen((data) {
      if (status.value == 'idle') {
        final session = data['session'];
        final callerData = data['callerData'];

        if (session != null && callerData != null) {
          sessionId = int.tryParse(session['id']?.toString() ?? '') ?? 0;
          consumerId = int.tryParse(callerData['id']?.toString() ?? '') ?? 0;
          consumerName = callerData['name']?.toString() ?? 'User';
          consumerImage = callerData['profile_photo']?.toString();
          
          final offerSdp = callerData['offer']?.toString();
          if (offerSdp != null) {
            _handleIncomingCall(offerSdp);
          }
        }
      }
    });

    _dismissedSubscription = WebSocketService.callDismissedData.listen((data) {
      if (data.isNotEmpty) {
        final session = data['session'];
        if (session != null && session['id'] == sessionId) {
          final reason = data['reason']?.toString() ?? 'dismissed';
          _handleCallDismissed(reason);
        }
      }
    });

    _iceSubscription = WebSocketService.iceCandidateData.listen((data) {
      if (data.isNotEmpty) {
        final session = data['session'];
        if (session != null && session['id'] == sessionId) {
          final candidate = data['candidate']?.toString();
          final receiverId = data['receiverId'];
          // Only add candidate if it is meant for us (receiverId matches current user ID)
          if (candidate != null && receiverId == WebSocketService.currentUserId) {
            webrtcService.addRemoteCandidate(candidate);
          }
        }
      }
    });

    _endedSubscription = WebSocketService.callEndedData.listen((data) {
      if (data.isNotEmpty) {
        final session = data['session'];
        if (session != null && session['id'] == sessionId) {
          _handleCallEnded(data);
        }
      }
    });
  }

  void _handleIncomingCall(String offerSdp) {
    _isSummaryShown = false;
    status.value = 'ringing';
    _startRingtone(isIncoming: true);
    _startRingingTimeout();

    if (sessionId != null) {
      LocalNotificationService.showIncomingCallNotification(
        sessionId: sessionId!,
        title: 'Incoming Call',
        body: 'Call from $consumerName',
      );
    }

    // Trigger Incoming Call screen/dialog
    Get.dialog(
      IncomingCallDialog(offerSdp: offerSdp),
      barrierDismissible: false,
    );
  }

  Future<bool> acceptCall(String offerSdp) async {
    if (sessionId == null) {
      Logger.e('CallController: Cannot accept call because sessionId is null.');
      return false;
    }
    Logger.d('CallController: acceptCall started for sessionId: $sessionId');
    try {
      _isSummaryShown = false;
      _stopRingtone();
      _ringingTimer?.cancel();
      status.value = 'ongoing';
      durationSeconds.value = 0;

      // 1. Create SDP Answer
      Logger.d('CallController: Creating SDP Answer...');
      final answerDescription = await webrtcService.acceptOffer(sessionId!, offerSdp);
      Logger.d('CallController: SDP Answer created.');

      // 2. Post to Accept API
      Logger.d('CallController: Posting answer to Accept Call API...');
      final response = await _apiClient.post(
        AppUrls.acceptCall(sessionId!),
        data: {
          'answer': answerDescription.sdp,
        },
        handleError: true,
        showErrorScreen: false,
      );

      Logger.d('CallController: Accept Call API response isSuccess: ${response.isSuccess}');
      if (response.isSuccess) {
        _startCallTimer();
        _showOngoingNotification();
        return true;
      } else {
        cleanUp();
        CustomSnackBar.showError('Failed to accept call.');
        return false;
      }
    } catch (e) {
      Logger.e('CallController: Error accepting call -> $e');
      cleanUp();
      return false;
    }
  }

  Future<void> rejectCall() async {
    if (sessionId == null) {
      Logger.e('CallController: Cannot reject call because sessionId is null.');
      return;
    }
    Logger.d('CallController: rejectCall started for sessionId: $sessionId');
    try {
      final response = await _apiClient.post(
        AppUrls.rejectCall(sessionId!),
        handleError: true,
        showErrorScreen: false,
      );
      Logger.d('CallController: Reject Call API response isSuccess: ${response.isSuccess}');
      if (response.isSuccess) {
        status.value = 'rejected';
      }
    } catch (e) {
      Logger.e('CallController: Error rejecting call -> $e');
    } finally {
      cleanUp();
    }
  }

  Future<void> cancelCall() async {
    if (sessionId == null) {
      Logger.e('CallController: Cannot cancel call because sessionId is null.');
      return;
    }
    Logger.d('CallController: cancelCall started for sessionId: $sessionId');
    try {
      final response = await _apiClient.post(
        AppUrls.cancelCall(sessionId!),
        handleError: true,
        showErrorScreen: false,
      );
      Logger.d('CallController: Cancel Call API response isSuccess: ${response.isSuccess}');
      if (response.isSuccess) {
        status.value = 'cancelled';
      }
    } catch (e) {
      Logger.e('CallController: Error cancelling call -> $e');
    } finally {
      cleanUp();
    }
  }

  Future<void> endCall() async {
    if (sessionId == null) return;
    try {
      final response = await _apiClient.post(
        AppUrls.endCallSession(sessionId!),
        handleError: true,
        showErrorScreen: false,
      );
      if (response.isSuccess) {
        if (_isSummaryShown) return;
        _isSummaryShown = true;
        
        status.value = 'completed';
        CustomSnackBar.showInfo('Call ended successfully.');
        
        final bodyMap = response.body;
        final sessionData = bodyMap is Map ? (bodyMap['session'] ?? bodyMap['data']?['session'] ?? bodyMap['data']) : null;
        int duration = 0;
        double cost = 0.0;
        if (sessionData != null && sessionData is Map) {
          duration = int.tryParse(sessionData['duration_seconds']?.toString() ?? '') ?? 0;
          cost = double.tryParse(sessionData['total_cost']?.toString() ?? '') ?? 0.0;
        }
        
        final sId = sessionId ?? 0;
        cleanUp();
        
        Future.delayed(const Duration(milliseconds: 300), () {
          CallSummaryDialog.show(
            sessionId: sId,
            durationSeconds: duration,
            totalCost: cost,
          );
        });
      } else {
        cleanUp();
      }
    } catch (e) {
      Logger.e('CallController: Error ending call -> $e');
      cleanUp();
    }
  }

  void toggleMute() {
    isMuted.value = !isMuted.value;
    webrtcService.toggleMute(isMuted.value);
  }

  void toggleSpeaker() {
    isSpeakerOn.value = !isSpeakerOn.value;
    webrtcService.toggleSpeaker(isSpeakerOn.value);
  }

  void _handleCallDismissed(String reason) {
    status.value = reason; // rejected, cancelled, timeout
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    cleanUp();
  }

  void _handleCallEnded(Map<String, dynamic> data) {
    if (_isSummaryShown) return;
    _isSummaryShown = true;
    
    status.value = 'completed';
    CustomSnackBar.showInfo('Call ended.');
    
    final session = data['session'];
    int sId = sessionId ?? 0;
    int duration = 0;
    double cost = 0.0;
    
    if (session != null) {
      sId = int.tryParse(session['id']?.toString() ?? '') ?? sId;
      duration = int.tryParse(session['duration_seconds']?.toString() ?? '') ?? 0;
      cost = double.tryParse(session['total_cost']?.toString() ?? '') ?? 0.0;
    }
    
    cleanUp();
    
    // Close CallScreen
    if (Get.currentRoute == '/CallScreen' || Get.isDialogOpen == true) {
      Get.back();
    }
    
    Future.delayed(const Duration(milliseconds: 300), () {
      CallSummaryDialog.show(
        sessionId: sId,
        durationSeconds: duration,
        totalCost: cost,
      );
    });
  }

  void _startRingingTimeout() {
    _ringingTimer?.cancel();
    _ringingTimer = Timer(const Duration(seconds: 60), () {
      if (status.value == 'ringing') {
        status.value = 'missed';
        cleanUp();
      }
    });
  }

  void _startCallTimer() {
    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      durationSeconds.value++;
      _showOngoingNotification();
    });
  }

  void _showOngoingNotification() {
    if (sessionId != null) {
      final minutes = (durationSeconds.value ~/ 60).toString().padLeft(2, '0');
      final seconds = (durationSeconds.value % 60).toString().padLeft(2, '0');
      LocalNotificationService.showOngoingCallNotification(
        sessionId: sessionId!,
        title: 'Active Call in Progress',
        body: 'Talking with $consumerName - $minutes:$seconds',
      );
    }
  }

  Future<void> _startRingtone({required bool isIncoming}) async {
    try {
      _audioPlayer = AudioPlayer();
      final path = isIncoming ? AppConstants.incomingRingPath : AppConstants.outgoingRingPath;
      await _audioPlayer?.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer?.play(AssetSource(path));

      if (isIncoming && (await Vibration.hasVibrator() ?? false)) {
        Vibration.vibrate(pattern: [500, 1000, 500, 1000], repeat: 0);
      }
    } catch (e) {
      Logger.e('CallController: Error playing ringtone -> $e');
    }
  }

  void _stopRingtone() {
    _audioPlayer?.stop();
    _audioPlayer?.dispose();
    _audioPlayer = null;
    Vibration.cancel();
  }

  void cleanUp() {
    _stopRingtone();
    _callTimer?.cancel();
    _ringingTimer?.cancel();
    if (sessionId != null) {
      LocalNotificationService.cancelOngoingCallNotification(sessionId!);
      LocalNotificationService.cancelIncomingCallNotification(sessionId!);
    }
    FloatingCallBubble.dismiss();
    webrtcService.dispose();
    status.value = 'idle';
    isMuted.value = false;
    isSpeakerOn.value = false;
    sessionId = null;
    consumerId = null;
    consumerName = null;
    consumerImage = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if ((status.value == 'ongoing' || status.value == 'ringing' || status.value == 'dialing') && sessionId != null && consumerName != null) {
        minimizeToBubble(Get.context!, consumerName!, consumerImage ?? "", shouldPop: false);
      }
    } else if (state == AppLifecycleState.resumed) {
      checkCurrentActiveCallSession();
    }
  }

  void minimizeToBubble(BuildContext context, String name, String image, {bool shouldPop = true}) {
    if (sessionId == null || (status.value != 'ongoing' && status.value != 'ringing' && status.value != 'dialing')) return;
    // FloatingCallBubble.show(
    //   context: context,
    //   sessionId: sessionId!,
    //   name: name,
    //   imageUrl: image,
    //   startedAt: status.value == 'ongoing' ? DateTime.now().subtract(Duration(seconds: durationSeconds.value)).toUtc().toIso8601String() : null,
    //   status: status.value,
    //   onTap: () {
    //     final currentStatus = FloatingCallBubble.callStatus.value;
    //     FloatingCallBubble.dismiss();
    //     Get.to(() => const CallScreen());
    //   },
    // );
    if (shouldPop) {
      Navigator.of(context).pop();
    }
  }

  Future<void> checkCurrentActiveCallSession() async {
    Logger.d('CallController: checkCurrentActiveCallSession started');
    try {
      final response = await _apiClient.get(AppUrls.currentCallSession, handleError: false, showErrorScreen: false);
      Logger.d('CallController: currentCallSession API response success: ${response.isSuccess}');
      if (response.isSuccess && response.body != null) {
        final bodyMap = response.body;
        final session = bodyMap is Map 
            ? (bodyMap['session'] ?? bodyMap['data']?['session'])
            : null;
        Logger.d('CallController: currentCallSession session: $session');
        if (session != null) {
          final sessionStatus = session['status']?.toString();
          Logger.d('CallController: currentCallSession sessionStatus: $sessionStatus');
          if (sessionStatus == 'ongoing' || sessionStatus == 'ringing' || sessionStatus == 'dialing') {
            _isSummaryShown = false;
            sessionId = int.tryParse(session['id']?.toString() ?? '');
            webrtcService.activeSessionId = sessionId;
            status.value = sessionStatus!;
            
            consumerId = int.tryParse(session['consumer_id']?.toString() ?? '');
            final consumer = session['consumer'];
            consumerName = consumer?['name']?.toString() ?? 'User';
            consumerImage = consumer?['image']?.toString() ?? consumer?['profile_image']?.toString() ?? consumer?['profile_photo']?.toString() ?? '';
            Logger.d('CallController: currentCallSession consumerName: $consumerName, status: $status');
            
            if (sessionStatus == 'ongoing') {
              final startedAtStr = session['started_at']?.toString();
              if (startedAtStr != null) {
                final startedAt = DateTime.tryParse(startedAtStr)?.toLocal();
                if (startedAt != null) {
                  durationSeconds.value = DateTime.now().difference(startedAt).inSeconds;
                  _startCallTimer();
                }
              }
              
              final offerSdp = session['offer']?.toString() ?? session['offer_sdp']?.toString();
              Logger.d('CallController: currentCallSession offerSdp length: ${offerSdp?.length}');
              if (offerSdp != null && offerSdp.isNotEmpty) {
                await webrtcService.acceptOffer(sessionId!, offerSdp);
              }
            } else if (sessionStatus == 'ringing' || sessionStatus == 'dialing') {
              _startRingtone(isIncoming: true);
              _startRingingTimeout();
            }
            
            // Show Notification
            final minutes = (durationSeconds.value ~/ 60).toString().padLeft(2, '0');
            final seconds = (durationSeconds.value % 60).toString().padLeft(2, '0');
            Logger.d('CallController: Showing ongoing call notification...');
            LocalNotificationService.showOngoingCallNotification(
              sessionId: sessionId!,
              title: 'Active Call in Progress',
              body: 'Talking with $consumerName - $minutes:$seconds',
              startedAtMillis: sessionStatus == 'ongoing' && session['started_at'] != null 
                  ? DateTime.tryParse(session['started_at'].toString())?.millisecondsSinceEpoch
                  : null,
            );

            // Show Floating Bubble
            // if (!isCallScreenVisible) {
            //   Logger.d('CallController: Showing floating call bubble overlay...');
            //   FloatingCallBubble.show(
            //     context: Get.context!,
            //     sessionId: sessionId!,
            //     name: consumerName!,
            //     imageUrl: consumerImage ?? "",
            //     startedAt: session['started_at']?.toString(),
            //     status: status.value,
            //     onTap: () {
            //       final currentStatus = FloatingCallBubble.callStatus.value;
            //       FloatingCallBubble.dismiss();
            //       Get.to(() => const CallScreen());
            //     },
            //   );
            // }
            Logger.d('CallController: checkCurrentActiveCallSession setup complete');
          } else {
            cleanUp();
          }
        } else {
          cleanUp();
        }
      } else {
        cleanUp();
      }
    } catch (e, stack) {
      Logger.e('CallController: Error checking current active call session -> $e');
      Logger.e('CallController: Error stack -> $stack');
    }
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
