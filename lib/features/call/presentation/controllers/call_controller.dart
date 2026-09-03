import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:astro_astrologer/core/services/callkit_service.dart';

import 'dart:async';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/constants/app_constants.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/services/network/websocket_service.dart';
import 'package:astro_astrologer/core/services/webrtc/webrtc_service.dart';
import 'package:astro_astrologer/core/services/local_notification_service.dart';
import 'package:astro_astrologer/core/services/sound_vibration_service.dart';
import 'package:astro_astrologer/core/utils/logger.dart';
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';
import 'package:astro_astrologer/core/services/foreground_task_service.dart';
import 'package:astro_astrologer/core/services/storage/token_manger.dart';

import 'package:astro_astrologer/core/enums/session_status_enums.dart';
import 'package:flutter/material.dart';
import 'package:astro_astrologer/features/call/presentation/widgets/floating_call_bubble.dart';
import 'package:astro_astrologer/features/call/presentation/pages/call_screen.dart';
import 'package:astro_astrologer/features/chat/presentation/pages/chat_screen.dart';

class CallController extends GetxController with WidgetsBindingObserver {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final WebRTCService webrtcService = WebRTCService();

  final Rx<CallStatus> status =
      CallStatus
          .idle
          .obs; // idle, ringing, ongoing, completed, rejected, cancelled, missed
  final RxInt durationSeconds = 0.obs;
  DateTime? callStartedAt; // Canonical start time for all 3 timer sources
  final RxBool isMuted = false.obs;
  final RxBool isSpeakerOn = false.obs;
  bool isCallScreenVisible = false;

  // Prepaid Package session info
  bool isPackageCall = false;
  int? subSessionId;
  bool isChatAlsoActive = false;
  int? activeChatSessionId;

  /// Expose master package countdown countdown to CallScreen
  int get packageMasterSeconds =>
      WebSocketService.packageRemainingSeconds.value;

  int? sessionId;
  int? consumerId;
  String? consumerName;
  String? consumerImage;
  String? incomingOfferSdp;

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
    _initiatedSubscription = WebSocketService.callInitiatedEvent.stream.listen((
      data,
    ) {
      if (status.value == CallStatus.idle) {
        final session = data['session'];
        final callerData = data['callerData'];

        if (session != null && callerData != null) {
          sessionId = int.tryParse(session['id']?.toString() ?? '') ?? 0;
          consumerId = int.tryParse(callerData['id']?.toString() ?? '') ?? 0;
          consumerName = callerData['name']?.toString() ?? 'User';
          consumerImage = callerData['profile_photo']?.toString();

          isPackageCall =
              session['is_package'] == true ||
              int.tryParse(session['sub_session_id']?.toString() ?? '') != null;
          subSessionId = int.tryParse(
            session['sub_session_id']?.toString() ?? '',
          );

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
        if (session != null) {
          final incomingId = int.tryParse(session['id']?.toString() ?? '');
          if (incomingId == sessionId) {
            final reason = data['reason']?.toString() ?? 'dismissed';
            _handleCallDismissed(reason);
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
            // Only add candidate if it is meant for us (receiverId matches current user ID)
            if (candidate != null &&
                receiverId == WebSocketService.currentUserId) {
              webrtcService.addRemoteCandidate(candidate);
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
          // Only handle if incomingId matches our current session
          if (incomingId != null &&
              (sessionId == null || incomingId == sessionId)) {
            Logger.d('CallController: WebSocket callEndedData received: $data');
            _handleCallEnded(data);
          }
        }
      }
    });
  }

  void _handleIncomingCall(String offerSdp) {
    incomingOfferSdp = offerSdp;
    _isSummaryShown = false;
    status.value = CallStatus.ringing;
    _startRingtone(isIncoming: true);
    _startRingingTimeout();

    if (sessionId != null) {}

    // Get.dialog(
    //   IncomingCallDialog(offerSdp: offerSdp),
    //   barrierDismissible: false,
    // );

    final String name =
        (consumerName != null && consumerName!.isNotEmpty)
            ? consumerName!
            : 'User';
    final String userAvatar =
        (consumerImage != null &&
                consumerImage!.isNotEmpty &&
                consumerImage != 'null')
            ? consumerImage!
            : 'assets/images/app_logo.png';

    CallkitService.showCallkitNotification(
      sessionId: sessionId.toString(),
      callerName: name,
      avatar: userAvatar,
      type: 'call',
    );
  }

  Future<bool> acceptCall(String offerSdp) async {
    if (sessionId == null) {
      Logger.e('CallController: Cannot accept call because sessionId is null.');
      return false;
    }
    Logger.d('CallController: acceptCall started for sessionId: $sessionId');
    if (_isAccepting) {
      Logger.d(
        'CallController: acceptCall already in progress, skipping duplicate.',
      );
      return false;
    }
    _isAccepting = true;
    try {
      _isSummaryShown = false;
      _stopRingtone();
      _ringingTimer?.cancel();
      status.value = CallStatus.ongoing;
      durationSeconds.value = 0;

      // 1. Create SDP Answer
      Logger.d('CallController: Creating SDP Answer...');
      final sdpToUse =
          (offerSdp.isNotEmpty) ? offerSdp : (incomingOfferSdp ?? '');

      if (sdpToUse.isEmpty) {
        // If still empty, use direct accept
        return await acceptCallDirect();
      }

      final answerDescription = await webrtcService.acceptOffer(
        sessionId!,
        sdpToUse,
      );
      Logger.d('CallController: SDP Answer created.');

      // 2. Post to Accept API
      Logger.d('CallController: Posting answer to Accept Call API...');
      final response = await _apiClient.post(
        AppUrls.acceptCall(sessionId!),
        data: {'answer': answerDescription.sdp},
        handleError: true,
        showErrorScreen: false,
      );

      Logger.d(
        'CallController: Accept Call API response isSuccess: ${response.isSuccess}',
      );
      if (response.isSuccess) {
        CallkitService.endAllCalls();
        callStartedAt = DateTime.now();
        durationSeconds.value = 0;
        _startCallTimer();
        _showOngoingNotification();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.currentRoute != '/CallScreen') {
            Get.to(() => const CallScreen());
          }
        });
        return true;
      } else {
        Logger.e('CallController: Accept Call API failed: ${response.message}');
        cleanUp();
        CustomSnackBar.showError('Failed to accept call: ${response.message}');
        return false;
      }
    } catch (e) {
      Logger.e('CallController: Error in acceptCall -> $e');
      cleanUp();
      return false;
    } finally {
      _isAccepting = false;
    }
  }

  /// Accept a call directly WITHOUT a consumer SDP offer.
  /// Used when the call is in 'initiated' status and consumer_sdp is null
  /// (SDP exchange happens only via WebSocket, not stored in DB).
  /// Creates a WebRTC offer from the astrologer side and sends it as 'answer'.
  Future<bool> acceptCallDirect() async {
    if (sessionId == null) {
      Logger.e(
        'CallController: Cannot acceptCallDirect because sessionId is null.',
      );
      return false;
    }
    Logger.d(
      'CallController: acceptCallDirect started for sessionId: $sessionId',
    );
    try {
      _isSummaryShown = false;
      _stopRingtone();
      _ringingTimer?.cancel();
      status.value = CallStatus.ongoing;
      durationSeconds.value = 0;

      // Since consumer_sdp is null (SDP exchange is WebSocket-only),
      // create a WebRTC offer from the astrologer side to satisfy the backend.
      Logger.d('CallController: Creating WebRTC offer (astrologer side)...');
      final offerDescription = await webrtcService.createOffer(sessionId!);
      Logger.d(
        'CallController: WebRTC offer created. Sending to Accept API as answer...',
      );

      final response = await _apiClient.post(
        AppUrls.acceptCall(sessionId!),
        data: {'answer': offerDescription.sdp},
        handleError: true,
        showErrorScreen: false,
      );

      Logger.d(
        'CallController: acceptCallDirect API response isSuccess: ${response.isSuccess}',
      );
      if (response.isSuccess) {
        CallkitService.endAllCalls();
        _startCallTimer();
        _showOngoingNotification();
        return true;
      } else {
        Logger.e(
          'CallController: acceptCallDirect failed: ${response.message}',
        );
        cleanUp();
        CustomSnackBar.showError('Failed to accept call: ${response.message}');
        return false;
      }
    } catch (e) {
      Logger.e('CallController: Error in acceptCallDirect -> $e');
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
      Logger.d(
        'CallController: Reject Call API response isSuccess: ${response.isSuccess}',
      );
      if (response.isSuccess) {
        status.value = CallStatus.rejected;
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
      Logger.d(
        'CallController: Cancel Call API response isSuccess: ${response.isSuccess}',
      );
      if (response.isSuccess) {
        status.value = CallStatus.cancelled;
      }
    } catch (e) {
      Logger.e('CallController: Error cancelling call -> $e');
    } finally {
      cleanUp();
    }
  }

  // ─── Hybrid Package: Granular Channel Termination (Astrologer) ───────────

  /// End Call Only — keeps chat alive, navigates back to chat screen
  Future<void> terminateChannelOnly() async {
    final subId = subSessionId;
    if (subId == null) {
      Logger.e(
        'CallController: terminateChannelOnly — no active subSessionId found',
      );
      return;
    }
    try {
      await _apiClient.post(
        AppUrls.packageTerminateChannel,
        data: {
          'sub_session_id': subId,
          'channel_type': 'call',
          'action': 'channel_only',
        },
      );
      Logger.d(
        'CallController: terminateChannelOnly success. Returning to chat...',
      );

      final chatSessId = activeChatSessionId ?? 0;
      final cName = consumerName ?? 'User';
      final cImage = consumerImage ?? '';

      // Reset call without ending the package sub-session
      final wasVisible = isCallScreenVisible;
      cleanUp();

      if (wasVisible) {
        Get.back();
      }

      // Navigate back to chat screen
      if (chatSessId > 0) {
        Get.to(
          () => ChatScreen(
            userName: cName,
            userImage: cImage,
            sessionId: chatSessId,
            initialStatus: 'ongoing',
          ),
        );
      }
    } catch (e) {
      Logger.e('CallController: Error in terminateChannelOnly -> $e');
      CustomSnackBar.showError('Failed to end call. Please try again.');
    }
  }

  /// End Entire Session — terminates both call and chat, closes consultation
  Future<void> terminateEntireSession() async {
    final subId = subSessionId;
    if (subId == null) {
      // Fallback
      await endCall();
      return;
    }
    try {
      await _apiClient.post(
        AppUrls.packageTerminateChannel,
        data: {
          'sub_session_id': subId,
          'channel_type': 'call',
          'action': 'complete_session',
        },
      );
      Logger.d('CallController: terminateEntireSession success.');
      status.value = CallStatus.completed;
      final wasVisible = isCallScreenVisible;
      cleanUp();
      if (wasVisible) {
        Get.back();
      }
    } catch (e) {
      Logger.e('CallController: Error in terminateEntireSession -> $e');
      await endCall();
    }
  }

  // ──────────────────────────────────────────────────────────────────────────

  bool _isEndingCall = false;
  bool _isAccepting =
      false; // Guard to prevent checkPendingCall from re-ringing during acceptCall

  Future<void> endCall() async {
    if (sessionId == null) return;
    _isEndingCall = true;
    try {
      final response = await _apiClient.post(
        AppUrls.endCallSession(sessionId!),
        handleError: true,
        showErrorScreen: false,
      );
      if (response.isSuccess) {
        if (_isSummaryShown) return;
        _isSummaryShown = true;

        status.value = CallStatus.completed;

        final bodyMap = response.body;
        final sessionData =
            bodyMap is Map
                ? (bodyMap['session'] ??
                    bodyMap['data']?['session'] ??
                    bodyMap['data'])
                : null;
        int duration = 0;
        double cost = 0.0;
        if (sessionData != null && sessionData is Map) {
          duration =
              int.tryParse(sessionData['duration_seconds']?.toString() ?? '') ??
              0;
          cost =
              double.tryParse(sessionData['total_cost']?.toString() ?? '') ??
              0.0;
        }

        final sId = sessionId ?? 0;
        final wasVisible = isCallScreenVisible;
        cleanUp();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (wasVisible) {
            Get.back(); // Pop CallScreen
          }
        });
      } else {
        final wasVisible = isCallScreenVisible;
        cleanUp();
        if (wasVisible) {
          Get.back();
        }
      }
    } catch (e) {
      Logger.e('CallController: Error ending call -> $e');
      cleanUp();
    } finally {
      _isEndingCall = false;
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
    status.value = CallStatus.values.firstWhere(
      (e) => e.name == reason,
      orElse: () => CallStatus.cancelled,
    ); // rejected, cancelled, timeout
    if (isCallScreenVisible || (Get.isDialogOpen ?? false)) {
      Get.back();
    }
    cleanUp();
  }

  void _handleCallEnded(Map<String, dynamic> data) {
    if (_isSummaryShown) return;
    _isSummaryShown = true;

    status.value = CallStatus.completed;

    final session = data['session'];
    int sId = sessionId ?? 0;
    int duration = 0;
    double cost = 0.0;

    if (session != null) {
      sId = int.tryParse(session['id']?.toString() ?? '') ?? sId;
      duration =
          int.tryParse(session['duration_seconds']?.toString() ?? '') ?? 0;
      cost = double.tryParse(session['total_cost']?.toString() ?? '') ?? 0.0;
    }

    final wasVisible = isCallScreenVisible;
    final sIdBeforeCleanup = sessionId ?? sId;
    cleanUp();

    final resolvedId = sIdBeforeCleanup > 0 ? sIdBeforeCleanup : sId;

    // Pop CallScreen safely to home screen
    if (isCallScreenVisible || Get.currentRoute == '/CallScreen') {
      Get.until((route) => route.isFirst);
    }
  }

  void _startRingingTimeout() {
    _ringingTimer?.cancel();
    _ringingTimer = Timer(const Duration(seconds: 60), () {
      if (status.value == CallStatus.ringing) {
        status.value = CallStatus.missed;
        cleanUp();
      }
    });
  }

  void _startCallTimer() {
    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      durationSeconds.value++;
    });
  }

  void _showOngoingNotification() {
    if (sessionId != null) {
      // Pass callStartedAt so the foreground notification timer stays in sync
      // with controller.durationSeconds (both count from the same moment).
      ForegroundTaskService.startActiveSessionNotification(
        title: 'Active Call',
        type: 'Call',
        startedAt: callStartedAt ?? DateTime.now(),
      );
    }
  }

  void _startRingtone({required bool isIncoming}) {
    // Astrologer hears astrolger_app_sound.mp3 when user calls/chats
    final sound = 'audio/astrolger_app_sound.mp3';
    SoundVibrationService().startRingtone(sound, loop: true, vibrate: true);
    Logger.d('[CallController] Astrologer ringtone started → $sound');
  }

  void _stopRingtone() {
    SoundVibrationService().stopRingtone();
    Logger.d('[CallController] Astrologer ringtone stopped');
  }

  void cleanUp() {
    if (status.value == CallStatus.idle && sessionId == null) return;
    _stopRingtone();
    CallkitService.endAllCalls();
    _callTimer?.cancel();
    _callTimer = null;
    _ringingTimer?.cancel();
    _ringingTimer = null;
    if (sessionId != null) {}
    ForegroundTaskService.stopService();
    FloatingCallBubble.dismiss();
    webrtcService.dispose();
    status.value = CallStatus.idle;
    isMuted.value = false;
    isSpeakerOn.value = false;
    sessionId = null;
    consumerId = null;
    consumerName = null;
    consumerImage = null;
    incomingOfferSdp = null;
    isPackageCall = false;
    subSessionId = null;
    isChatAlsoActive = false;
    activeChatSessionId = null;

    if (isCallScreenVisible) {
      isCallScreenVisible = false;
    }
    callStartedAt = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if ((status.value == CallStatus.ongoing ||
              status.value == CallStatus.ringing ||
              status.value == CallStatus.dialing) &&
          sessionId != null &&
          consumerName != null) {
        minimizeToBubble(
          Get.context!,
          consumerName!,
          consumerImage ?? "",
          shouldPop: false,
        );
      }
    } else if (state == AppLifecycleState.resumed) {
      // First check pending calls (incoming not yet accepted), then fall back to current session
      TokenManager.getToken().then((token) {
        if (token != null && token.isNotEmpty) {
          checkPendingCall();
        }
      });
    }
  }

  void minimizeToBubble(
    BuildContext context,
    String name,
    String image, {
    bool shouldPop = true,
  }) {
    if (_isEndingCall) return;
    if (sessionId == null ||
        (status.value != CallStatus.ongoing &&
            status.value != CallStatus.ringing &&
            status.value != CallStatus.dialing))
      return;
    // Use callStartedAt as canonical start — keeps bubble timer in sync with CallScreen
    final startStr =
        callStartedAt?.toIso8601String() ??
        WebSocketService.sessionStartTimes[sessionId!] ??
        DateTime.now()
            .subtract(Duration(seconds: durationSeconds.value))
            .toIso8601String();
    WebSocketService.sessionStartTimes[sessionId!] = startStr;

    FloatingCallBubble.show(
      context: context,
      sessionId: sessionId!,
      name: name,
      imageUrl: image,
      startedAt: status.value == CallStatus.ongoing ? startStr : null,
      status: status.value.name,
      onTap: () {
        final currentStatus = status.value;
        FloatingCallBubble.dismiss(stopForegroundService: false);

        if (currentStatus == 'ringing') {
          // Incoming call still ringing — show IncomingCallDialog with Accept/Decline
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Get.isDialogOpen == true) return;
            final sdp = incomingOfferSdp ?? '';
            /*
            Get.dialog(
              IncomingCallDialog(offerSdp: sdp),
              barrierDismissible: false,
            );
            */
          });
        } else {
          // Ongoing call — go back to CallScreen
          Get.to(() => const CallScreen());
        }
      },
    );
    if (shouldPop) {
      Get.back();
    }
  }

  /// Fetches the offer SDP from /call/current-session for cases when the
  /// astrologer taps Accept but SDP was not available at dialog open time.
  Future<String?> fetchOfferSdpFromCurrentSession() async {
    try {
      final response = await _apiClient.get(
        AppUrls.currentCallSession,
        handleError: false,
        showErrorScreen: false,
      );
      if (response.isSuccess && response.body != null) {
        final bodyMap = response.body;
        final session =
            bodyMap is Map
                ? (bodyMap['session'] ?? bodyMap['data']?['session'])
                : null;
        if (session != null) {
          final sdp =
              session['offer']?.toString() ??
              session['offer_sdp']?.toString() ??
              session['consumer_sdp']?.toString();
          Logger.d(
            'CallController: fetchOfferSdpFromCurrentSession sdp length: ${sdp?.length}',
          );
          return sdp;
        }
      }
    } catch (e) {
      Logger.e('CallController: Error fetching offer SDP -> $e');
    }
    return null;
  }

  /// Checks /call/pending for any pending (initiated) calls and shows IncomingCallDialog.
  /// Returns true if a pending call was found and handled.
  Future<bool> checkPendingCall() async {
    // Skip if we are in the middle of accepting a call to avoid re-ringing
    if (_isAccepting || status.value == CallStatus.ongoing) {
      Logger.d(
        'CallController: checkPendingCall skipped — currently accepting or ongoing.',
      );
      return false;
    }
    Logger.d('CallController: checkPendingCall started');
    try {
      final response = await _apiClient.get(
        AppUrls.pendingCallSessions,
        handleError: false,
        showErrorScreen: false,
      );
      Logger.d(
        'CallController: pendingCall API response success: ${response.isSuccess}',
      );
      if (response.isSuccess && response.body != null) {
        final bodyMap = response.body;
        final pendingCalls =
            bodyMap is Map
                ? (bodyMap['pending_calls'] ??
                    bodyMap['data']?['pending_calls'])
                : null;
        if (pendingCalls is List && pendingCalls.isNotEmpty) {
          final call = pendingCalls.first;
          final int newSessionId =
              int.tryParse(call['id']?.toString() ?? '') ?? 0;
          final caller = call['caller'];
          final String callerName = caller?['name']?.toString() ?? 'User';
          final String? callerImage = caller?['profile_photo']?.toString();

          Logger.d(
            'CallController: Pending call found, sessionId=$newSessionId, caller=$callerName',
          );

          // Skip if we're already handling this call
          if (status.value == CallStatus.ringing && sessionId == newSessionId) {
            Logger.d(
              'CallController: Already handling this pending call, skipping.',
            );
            return true;
          }

          // Set up call data without SDP (will wait for WebSocket or accept with null SDP)
          sessionId = newSessionId;
          consumerId = int.tryParse(caller?['id']?.toString() ?? '') ?? 0;
          consumerName = callerName;
          consumerImage = callerImage;
          _isSummaryShown = false;
          status.value = CallStatus.ringing;
          _startRingtone(isIncoming: true);
          _startRingingTimeout();

          // Show IncomingCallDialog — pass empty string as offerSdp since we may not have it yet
          // The accept flow will fetch the SDP when the astrologer taps Accept
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // CallSummaryDialog.dismissIfOpen();
            if (Get.isDialogOpen != true) {
              /*
              Get.dialog(
                IncomingCallDialog(offerSdp: ''),
                barrierDismissible: false,
              );
              */
            }
          });
          return true;
        }
      }
    } catch (e, stack) {
      Logger.e('CallController: Error checking pending call -> $e');
      Logger.e('CallController: Stack -> $stack');
    }
    // No pending call found; fall back to checking current active session
    await checkCurrentActiveCallSession();
    return false;
  }

  Future<void> checkCurrentActiveCallSession() async {
    Logger.d('CallController: checkCurrentActiveCallSession started');
    try {
      final response = await _apiClient.get(
        AppUrls.currentCallSession,
        handleError: false,
        showErrorScreen: false,
      );
      Logger.d(
        'CallController: currentCallSession API response success: ${response.isSuccess}',
      );
      if (response.isSuccess && response.body != null) {
        final bodyMap = response.body;
        final session =
            bodyMap is Map
                ? (bodyMap['session'] ?? bodyMap['data']?['session'])
                : null;
        Logger.d('CallController: currentCallSession session: $session');
        if (session != null) {
          final sessionStatus = session['status']?.toString();
          Logger.d(
            'CallController: currentCallSession sessionStatus: $sessionStatus',
          );
          if (sessionStatus == 'ongoing' ||
              sessionStatus == 'ringing' ||
              sessionStatus == 'dialing' ||
              sessionStatus == 'initiated') {
            // Prevent race condition: if call is already ended locally, ignore stale API response
            if (status.value == CallStatus.completed ||
                status.value == CallStatus.cancelled ||
                status.value == CallStatus.rejected) {
              return;
            }

            _isSummaryShown = false;
            sessionId = int.tryParse(session['id']?.toString() ?? '');
            webrtcService.activeSessionId = sessionId;
            status.value = CallStatus.values.firstWhere(
              (e) =>
                  e.name ==
                  (sessionStatus == 'initiated' ? 'ringing' : sessionStatus),
              orElse: () => CallStatus.ongoing,
            );

            consumerId = int.tryParse(session['consumer_id']?.toString() ?? '');
            final consumer = session['consumer'];
            consumerName = consumer?['name']?.toString() ?? 'User';
            consumerImage =
                consumer?['image']?.toString() ??
                consumer?['profile_image']?.toString() ??
                consumer?['profile_photo']?.toString() ??
                '';
            Logger.d(
              'CallController: currentCallSession consumerName: $consumerName, status: $status',
            );

            if (sessionStatus == 'ongoing') {
              final startedAtStr = session['started_at']?.toString();
              if (startedAtStr != null) {
                final startedAt = DateTime.tryParse(startedAtStr)?.toLocal();
                if (startedAt != null) {
                  // Calculate elapsed time from server's started_at
                  durationSeconds.value =
                      DateTime.now().difference(startedAt).inSeconds;
                }
              }
              // Start/restart timer (cancels old timer first)
              _startCallTimer();

              final offerSdp =
                  session['offer']?.toString() ??
                  session['offer_sdp']?.toString() ??
                  session['consumer_sdp']?.toString();
              Logger.d(
                'CallController: currentCallSession offerSdp length: ${offerSdp?.length}',
              );

              if (offerSdp != null && offerSdp.isNotEmpty) {
                // Normal path: use consumer's SDP to create WebRTC answer
                await webrtcService.acceptOffer(sessionId!, offerSdp);
              } else {
                // App was killed — SDP not in DB, re-initiate WebRTC from our side
                // so audio can be re-established.
                Logger.d(
                  'CallController: App restarted during call — re-initiating WebRTC...',
                );
                try {
                  final newOffer = await webrtcService.createOffer(sessionId!);
                  Logger.d(
                    'CallController: Re-initiate offer created, re-posting to accept API...',
                  );
                  await _apiClient.post(
                    AppUrls.acceptCall(sessionId!),
                    data: {'answer': newOffer.sdp},
                    handleError: false,
                    showErrorScreen: false,
                  );
                  Logger.d('CallController: WebRTC re-initiation complete.');
                } catch (e) {
                  Logger.e(
                    'CallController: Failed to re-initiate WebRTC -> $e',
                  );
                }
              }
            } else if (sessionStatus == 'ringing' ||
                sessionStatus == 'dialing' ||
                sessionStatus == 'initiated') {
              final offerSdp =
                  session['offer']?.toString() ??
                  session['offer_sdp']?.toString() ??
                  session['consumer_sdp']?.toString();
              incomingOfferSdp = offerSdp ?? '';
              // CallKit notification is already shown by the WebSocket event.
              // Do NOT call _handleIncomingCall here — it would re-show the
              // full-screen CallKit activity every time the app resumes.
              // _handleIncomingCall(incomingOfferSdp!);
            }

            // Show Notification if the call is ongoing
            if (sessionStatus == 'ongoing') {
              // Double check before showing notification in case status changed during async operations
              if (status.value == CallStatus.completed ||
                  status.value == CallStatus.cancelled ||
                  status.value == CallStatus.completed ||
                  status.value == CallStatus.idle ||
                  _isEndingCall) {
                return;
              }

              final minutes = (durationSeconds.value ~/ 60).toString().padLeft(
                2,
                '0',
              );
              final seconds = (durationSeconds.value % 60).toString().padLeft(
                2,
                '0',
              );
              Logger.d('CallController: Showing ongoing call notification...');
              // Removed Notification call
              // Navigate to CallScreen if not already visible
              // CallkitService handles navigation to CallScreen on Accept.
              // Only navigate here if already registered via Accept button.
              if (!isCallScreenVisible && status.value == CallStatus.ongoing) {
                Logger.d(
                  'CallController: Navigating to CallScreen for resumed ongoing call.',
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (Get.currentRoute != '/CallScreen') {
                    Get.to(() => const CallScreen());
                  }
                });
              }
            }

            // Show Floating Bubble
            // if (!isCallScreenVisible) {
            //   Logger.d('CallController: Showing floating call bubble overlay...');
            //   FloatingCallBubble.show(
            //     context: Get.context!,
            //     sessionId: sessionId!,
            //     name: consumerName!,
            //     imageUrl: consumerImage ?? "",
            //     startedAt: session['started_at']?.toString(),
            //     status: status.value.name,
            //     onTap: () {
            //       final currentStatus = FloatingCallBubble.callStatus.value;
            //       FloatingCallBubble.dismiss();
            //       Get.to(() => const CallScreen());
            //     },
            //   );
            // }
            Logger.d(
              'CallController: checkCurrentActiveCallSession setup complete',
            );
          } else {
            if (isCallScreenVisible || Get.isDialogOpen == true) {
              Get.back();
            }
            cleanUp();
          }
        } else {
          if (isCallScreenVisible || Get.isDialogOpen == true) {
            Get.back();
          }
          cleanUp();
        }
      } else {
        if (isCallScreenVisible || Get.isDialogOpen == true) {
          Get.back();
        }
        cleanUp();
      }
    } catch (e, stack) {
      Logger.e(
        'CallController: Error checking current active call session -> $e',
      );
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
