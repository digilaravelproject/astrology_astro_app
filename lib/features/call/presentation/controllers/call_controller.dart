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
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';

class CallController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final WebRTCService webrtcService = WebRTCService();

  final RxString status = 'idle'.obs; // idle, ringing, ongoing, completed, rejected, cancelled, missed
  final RxInt durationSeconds = 0.obs;
  final RxBool isMuted = false.obs;
  final RxBool isSpeakerOn = false.obs;

  int? sessionId;
  int? consumerId;
  String? consumerName;
  String? consumerImage;

  AudioPlayer? _audioPlayer;
  Timer? _callTimer;
  Timer? _ringingTimer;
  StreamSubscription? _initiatedSubscription;
  StreamSubscription? _dismissedSubscription;
  StreamSubscription? _iceSubscription;

  @override
  void onInit() {
    super.onInit();
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
  }

  void _handleIncomingCall(String offerSdp) {
    status.value = 'ringing';
    _startRingtone(isIncoming: true);
    _startRingingTimeout();

    // Trigger Incoming Call screen/dialog
    Get.dialog(
      IncomingCallDialog(offerSdp: offerSdp),
      barrierDismissible: false,
    );
  }

  Future<void> acceptCall(String offerSdp) async {
    if (sessionId == null) return;
    try {
      _stopRingtone();
      _ringingTimer?.cancel();
      status.value = 'ongoing';
      durationSeconds.value = 0;

      // 1. Create SDP Answer
      final answerDescription = await webrtcService.acceptOffer(sessionId!, offerSdp);

      // 2. Post to Accept API
      final response = await _apiClient.post(
        AppUrls.acceptCall(sessionId!),
        data: {
          'answer': answerDescription.sdp,
        },
        handleError: true,
        showErrorScreen: false,
      );

      if (response.isSuccess && response.body?['success'] == true) {
        _startCallTimer();
        _showOngoingNotification();
      } else {
        cleanUp();
        CustomSnackBar.show('Failed to accept call.', isError: true);
      }
    } catch (e) {
      Logger.e('CallController: Error accepting call -> $e');
      cleanUp();
    }
  }

  Future<void> rejectCall() async {
    if (sessionId == null) return;
    try {
      final response = await _apiClient.post(
        AppUrls.rejectCall(sessionId!),
        handleError: true,
        showErrorScreen: false,
      );
      if (response.isSuccess) {
        status.value = 'rejected';
      }
    } catch (e) {
      Logger.e('CallController: Error rejecting call -> $e');
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
        status.value = 'completed';
      }
    } catch (e) {
      Logger.e('CallController: Error ending call -> $e');
    } finally {
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
    }
    webrtcService.dispose();
    status.value = 'idle';
  }

  @override
  void onClose() {
    _initiatedSubscription?.cancel();
    _dismissedSubscription?.cancel();
    _iceSubscription?.cancel();
    cleanUp();
    super.onClose();
  }
}
