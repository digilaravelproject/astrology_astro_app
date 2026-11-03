import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/utils/logger.dart';
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';
import 'package:astro_astrologer/core/services/callkit_service.dart';
import 'package:astro_astrologer/core/services/local_notification_service.dart';
import 'package:astro_astrologer/core/enums/session_status_enums.dart';
import 'package:astro_astrologer/features/chat/presentation/pages/chat_screen.dart';
import 'call_controller.dart';
import 'package:astro_astrologer/routes/app_routes.dart';
import 'package:astro_astrologer/routes/route_helper.dart';
import 'package:astro_astrologer/core/services/websocket/websocket_service.dart';

class CallWebRTCController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  CallController get _orchestrator => Get.find<CallController>();

  bool isEndingCall = false;
  bool isAccepting = false;

  Future<bool> acceptCall(String offerSdp) async {
    if (_orchestrator.sessionId == null) return false;
    if (isAccepting) return false;
    if (_orchestrator.status.value == CallStatus.ongoing && _orchestrator.webrtcService.peerConnection != null) {
      debugPrint('[CallWebRTCController] Call is already ongoing and WebRTC active. Skipping redundant acceptCall.');
      return true;
    }
    isAccepting = true;
    try {
      _orchestrator.session.isSummaryShown = false;
      _orchestrator.session.stopRingtone();
      _orchestrator.session.ringingTimer?.cancel();
      _orchestrator.isAcceptedLocally = true;
      _orchestrator.status.value = CallStatus.ongoing;
      if (_orchestrator.durationSeconds.value == 0) {
        _orchestrator.session.startCallTimer();
      }

      String sdpToUse = (offerSdp.isNotEmpty) ? offerSdp : (_orchestrator.session.incomingOfferSdp ?? '');

      if (sdpToUse.isEmpty) {
        sdpToUse = await fetchOfferSdpFromCurrentSession() ?? '';
      }

      if (sdpToUse.isEmpty) {
        Logger.e('acceptCall failed: No offer SDP found locally or via current-session API.');
        _orchestrator.session.cleanUp();
        isAccepting = false;
        CustomSnackBar.showError('Could not connect: User offer missing.');
        return false;
      }

      // Start the foreground service BEFORE accessing the microphone,
      // so Android allows microphone access even if the app is in the background.
      await _orchestrator.session.showOngoingNotification();

      // Give LiveRoomScreen time to stop the LiveKit mic hardware ONLY if live call.
      // Normal incoming calls connect immediately without any delay.
      if (_orchestrator.session.isLiveCall) {
        await Future.delayed(const Duration(milliseconds: 800));
      }

      final answerDescription = await _orchestrator.webrtcService.acceptOffer(_orchestrator.sessionId!, sdpToUse);
      
      // Connect WebSocket in background without blocking acceptCall HTTP request
      if (Get.isRegistered<WebSocketService>()) {
        final ws = Get.find<WebSocketService>();
        if (!ws.isConnected) {
          ws.connect();
        }
      }

      final response = await _apiClient.post(
        AppUrls.acceptCall(_orchestrator.sessionId!),
        data: {'answer': answerDescription.sdp},
        handleError: true,
        showErrorScreen: false,
      );

      if (response.isSuccess) {
        // CallkitService.endAllCalls();
        _orchestrator.session.callStartedAt = DateTime.now();
        final acceptedMillis = DateTime.now().millisecondsSinceEpoch;
        _orchestrator.session.startCallTimer(startedAtMillis: acceptedMillis);
        _orchestrator.session.showOngoingNotification();
        _orchestrator.webrtcService.toggleSpeaker(_orchestrator.isSpeakerOn.value);

        // Process missed ICE candidates from API response
        final bodyMap = response.body;
        final sessionData = bodyMap is Map ? (bodyMap['session'] ?? bodyMap['data']?['session']) : null;
        if (sessionData != null && sessionData['ice_candidates'] is List) {
           final candidatesList = sessionData['ice_candidates'] as List;
           for (var ice in candidatesList) {
             final candidateStr = ice['candidate'];
             if (candidateStr != null) {
               _orchestrator.webrtcService.addRemoteCandidate(candidateStr.toString());
             }
           }
        }

        return true;
      } else {
        final msg = response.message?.toLowerCase() ?? '';
        if (msg.contains('already accepted') ||
            msg.contains('ongoing') ||
            msg.contains('in_progress') ||
            (msg.contains('no longer valid') && _orchestrator.status.value == CallStatus.ongoing)) {
          debugPrint('[CallWebRTCController] Server reports call accepted/active ($msg). Preserving session.');
          _orchestrator.status.value = CallStatus.ongoing;
          if (_orchestrator.durationSeconds.value == 0) {
            _orchestrator.session.startCallTimer();
          }
          return true;
        }
        _orchestrator.session.cleanUp();
        CustomSnackBar.showError('Failed to accept call: ${response.message}');
        return false;
      }
    } catch (e) {
      Logger.e('CallWebRTCController: Exception in acceptCall -> $e');
      _orchestrator.session.cleanUp();
      return false;
    } finally {
      isAccepting = false;
    }
  }

  Future<bool> acceptCallDirect() async {
    String sdp = _orchestrator.session.incomingOfferSdp ?? '';
    if (sdp.isEmpty && _orchestrator.sessionId != null) {
      sdp = await fetchOfferSdpFromCurrentSession() ?? '';
    }
    if (sdp.isNotEmpty) {
      return await acceptCall(sdp);
    }
    if (_orchestrator.status.value == CallStatus.ongoing && _orchestrator.webrtcService.peerConnection != null) {
      debugPrint('[CallWebRTCController] acceptCallDirect: WebRTC already active.');
      return true;
    }
    Logger.e('acceptCallDirect failed: No offer SDP available.');
    _orchestrator.session.cleanUp();
    return false;
  }

  Future<void> rejectCall() async {
    if (_orchestrator.sessionId == null) return;
    try {
      final response = await _apiClient.post(
        AppUrls.rejectCall(_orchestrator.sessionId!),
        handleError: true,
        showErrorScreen: false,
      );
      if (response.isSuccess) {
        _orchestrator.status.value = CallStatus.rejected;
      }
    } catch (e) {
      Logger.e('CallController: Error rejecting call -> $e');
    } finally {
      _orchestrator.session.cleanUp();
    }
  }

  Future<void> cancelCall() async {
    if (_orchestrator.sessionId == null) return;
    try {
      final response = await _apiClient.post(
        AppUrls.cancelCall(_orchestrator.sessionId!),
        handleError: true,
        showErrorScreen: false,
      );
      if (response.isSuccess) {
        _orchestrator.status.value = CallStatus.cancelled;
      }
    } catch (e) {
      Logger.e('CallController: Error cancelling call -> $e');
    } finally {
      _orchestrator.session.cleanUp();
    }
  }

  Future<void> terminateChannelOnly() async {
    // Unified endpoint: /call/{id}/end handles session_type automatically
    await endCall();
  }

  Future<void> terminateEntireSession() async {
    // Unified endpoint: /call/{id}/end handles both normal & prepaid session_type
    await endCall();
  }


  Future<void> endCall() async {
    final sId = _orchestrator.sessionId;
    if (sId == null || sId == 0) {
      if (_orchestrator.isCallScreenVisible || Get.currentRoute == '/CallScreen' || Get.currentRoute == '/call-screen' || Get.currentRoute == AppRoutes.callScreen) {
        if (Get.isDialogOpen ?? false) Get.back();
        if (Get.previousRoute.isNotEmpty && Get.previousRoute != '/' && Get.previousRoute != AppRoutes.splash) {
          Get.back();
        } else {
          Get.offAllNamed(RouteHelper.getDashboardRoute());
        }
      }
      return;
    }
    isEndingCall = true;
    SharedPrefs.setBool('session_ended_$sId', true);
    try {
      final response = await _apiClient.post(
        AppUrls.endCallSession(sId),
        handleError: true,
        showErrorScreen: false,
      );
      if (response.isSuccess) {
        if (_orchestrator.session.isSummaryShown) return;
        _orchestrator.session.isSummaryShown = true;
        _orchestrator.status.value = CallStatus.completed;
      }
    } catch (e) {
      Logger.e('CallController: Error ending call -> $e');
    } finally {
      final wasVisible = _orchestrator.isCallScreenVisible;
      CallkitService.resetAcceptedFlags();
      _orchestrator.session.cleanUp();
      if (wasVisible || Get.currentRoute == '/CallScreen' || Get.currentRoute == '/call-screen' || Get.currentRoute == AppRoutes.callScreen) {
        if (Get.isDialogOpen ?? false) Get.back();
        if (Get.previousRoute.isNotEmpty && Get.previousRoute != '/' && Get.previousRoute != AppRoutes.splash) {
          Get.back();
        } else {
          Get.offAllNamed(RouteHelper.getDashboardRoute());
        }
      }
      isEndingCall = false;
    }
  }

  Future<String?> fetchOfferSdpFromCurrentSession() async {
    try {
      final response = await _apiClient.get(
        AppUrls.currentCallSession,
        handleError: false,
        showErrorScreen: false,
      );
      if (response.isSuccess && response.body != null) {
        final bodyMap = response.body;
        final session = bodyMap is Map ? (bodyMap['session'] ?? bodyMap['data']?['session']) : null;
        if (session != null) {
          return session['offer']?.toString() ?? session['offer_sdp']?.toString() ?? session['consumer_sdp']?.toString();
        }
      }
    } catch (e) {}
    return null;
  }

  Future<bool> checkPendingCall() async {
    if (isAccepting || _orchestrator.status.value == CallStatus.ongoing) return false;
    try {
      final response = await _apiClient.get(
        AppUrls.pendingCallSessions,
        handleError: false,
        showErrorScreen: false,
      );
      if (response.isSuccess && response.body != null) {
        final bodyMap = response.body;
        final pendingCalls = bodyMap is Map ? (bodyMap['pending_calls'] ?? bodyMap['data']?['pending_calls']) : null;
        if (pendingCalls is List && pendingCalls.isNotEmpty) {
          final call = pendingCalls.first;
          final int newSessionId = int.tryParse(call['id']?.toString() ?? '') ?? 0;
          final caller = call['caller'];

          if ((_orchestrator.status.value == CallStatus.ringing || _orchestrator.status.value == CallStatus.ongoing) && _orchestrator.sessionId == newSessionId) return true;

          _orchestrator.session.sessionId = newSessionId;
          _orchestrator.session.consumerId = int.tryParse(caller?['id']?.toString() ?? '') ?? 0;
          _orchestrator.session.consumerName = caller?['name']?.toString() ?? 'User';
          _orchestrator.session.consumerImage = caller?['profile_photo']?.toString();
          _orchestrator.session.isSummaryShown = false;
          _orchestrator.status.value = CallStatus.ringing;

          LocalNotificationService.showOngoingCallNotification(
            sessionId: _orchestrator.sessionId!,
            title: '${_orchestrator.session.consumerName} • Incoming Call',
            body: 'Incoming Audio Call...',
          );

          _orchestrator.session.startRingtone(isIncoming: true);
          _orchestrator.session.startRingingTimeout();
          return true;
        }
      }
    } catch (e) {}
    await checkCurrentActiveCallSession();
    return false;
  }

  Future<void> checkCurrentActiveCallSession({int retries = 0}) async {
    try {
      final response = await _apiClient.get(
        AppUrls.currentCallSession,
        handleError: false,
        showErrorScreen: false,
      );
      if (response.isSuccess && response.body != null) {
        final bodyMap = response.body;
        final session = bodyMap is Map ? (bodyMap['session'] ?? bodyMap['data']?['session']) : null;
        if (session != null) {
          final sessionStatus = session['status']?.toString().toLowerCase() ?? 'idle';

          // If session is completed or cancelled, clean up immediately
          if (sessionStatus == 'completed' || sessionStatus == 'cancelled' || sessionStatus == 'rejected' || sessionStatus == 'ended') {
            final sid = int.tryParse(session['id']?.toString() ?? '') ?? _orchestrator.sessionId;
            if (sid != null && sid > 0) {
              SharedPrefs.setBool('session_ended_$sid', true);
            }
            final wasVisible = _orchestrator.isCallScreenVisible;
            _orchestrator.session.cleanUp();
            if (wasVisible || Get.currentRoute == '/CallScreen' || Get.currentRoute == '/call-screen' || Get.currentRoute == AppRoutes.callScreen) {
              if (Get.isDialogOpen ?? false) Get.back();
              if (Get.previousRoute.isNotEmpty && Get.previousRoute != '/' && Get.previousRoute != AppRoutes.splash) {
                Get.back();
              } else {
                Get.offAllNamed(RouteHelper.getDashboardRoute());
              }
            }
            return;
          }

          if (_orchestrator.status.value == CallStatus.completed || _orchestrator.status.value == CallStatus.cancelled || _orchestrator.status.value == CallStatus.rejected) return;

          _orchestrator.session.isSummaryShown = false;
          _orchestrator.session.sessionId = int.tryParse(session['id']?.toString() ?? '');
          _orchestrator.webrtcService.activeSessionId = _orchestrator.sessionId;
          
          final consumerData = session['consumer'] ?? session['caller'];
          if (consumerData != null) {
            _orchestrator.session.consumerName = consumerData['name']?.toString() ?? 'User';
            _orchestrator.session.consumerImage = consumerData['profile_photo']?.toString();
          }
          
          if (_orchestrator.isAcceptedLocally && (sessionStatus == 'initiated' || sessionStatus == 'ringing')) {
            debugPrint('[CallWebRTCController] Call already accepted locally. Enforcing status=ongoing');
            _orchestrator.status.value = CallStatus.ongoing;
            if (_orchestrator.durationSeconds.value == 0) {
              _orchestrator.session.startCallTimer();
            }
          } else {
            _orchestrator.status.value = CallStatus.values.firstWhere(
              (e) => e.name == (sessionStatus == 'initiated' ? 'ringing' : sessionStatus),
              orElse: () => CallStatus.ongoing,
            );
          }

          if (sessionStatus == 'initiated' && !_orchestrator.isAcceptedLocally) {
            final offerSdp = session['offer']?.toString() ?? session['offer_sdp']?.toString() ?? session['consumer_sdp']?.toString();
            _orchestrator.session.incomingOfferSdp = offerSdp ?? '';
            
            if (retries < 5) {
              await Future.delayed(const Duration(seconds: 2));
              return checkCurrentActiveCallSession(retries: retries + 1);
            }
          } else if (sessionStatus == 'ongoing') {
            final startedAtStr = session['started_at']?.toString();
            if (startedAtStr != null) {
              final startedAt = DateTime.tryParse(startedAtStr)?.toLocal();
              if (startedAt != null) {
                _orchestrator.durationSeconds.value = DateTime.now().difference(startedAt).inSeconds;
                _orchestrator.session.startCallTimer(startedAtMillis: startedAt.millisecondsSinceEpoch);
              } else {
                _orchestrator.session.startCallTimer();
              }
            } else {
              _orchestrator.session.startCallTimer();
            }
            
            if (_orchestrator.webrtcService.peerConnection == null) {
              final offerSdp = session['offer']?.toString() ?? session['offer_sdp']?.toString() ?? session['consumer_sdp']?.toString();
              if (offerSdp != null && offerSdp.isNotEmpty) {
                await _orchestrator.webrtcService.acceptOffer(_orchestrator.sessionId!, offerSdp);
                _orchestrator.webrtcService.toggleSpeaker(_orchestrator.isSpeakerOn.value);
              } else {
                try {
                  final newOffer = await _orchestrator.webrtcService.createOffer(_orchestrator.sessionId!);
                  await _apiClient.post(AppUrls.acceptCall(_orchestrator.sessionId!), data: {'answer': newOffer.sdp}, handleError: false, showErrorScreen: false);
                  _orchestrator.webrtcService.toggleSpeaker(_orchestrator.isSpeakerOn.value);
                } catch (e) {}
              }
            }

            // Process missed ICE candidates from API response
            if (session['ice_candidates'] is List) {
               final candidatesList = session['ice_candidates'] as List;
               for (var ice in candidatesList) {
                 final candidateStr = ice['candidate'];
                 if (candidateStr != null) {
                   _orchestrator.webrtcService.addRemoteCandidate(candidateStr.toString());
                 }
               }
            }

            // Check if it's a live call session
            final sType = session['session_type']?.toString();
            _orchestrator.session.isLiveCall = sType == 'live';

            if (!_orchestrator.session.isLiveCall && !_orchestrator.isCallScreenVisible && _orchestrator.status.value == CallStatus.ongoing) {
              if (Get.currentRoute != AppRoutes.callScreen) {
                Get.toNamed(AppRoutes.callScreen);
              }
            }

            LocalNotificationService.showOngoingCallNotification(
              sessionId: _orchestrator.sessionId!,
              title: '${_orchestrator.session.consumerName} • Active Call',
              body: 'Tap to return to call session',
              startedAtMillis: () {
                if (startedAtStr != null) {
                  String isoUtc = startedAtStr.trim().replaceAll(' ', 'T');
                  if (!isoUtc.endsWith('Z') && !isoUtc.contains('+') && !isoUtc.contains('-')) isoUtc += 'Z';
                  return DateTime.tryParse(isoUtc)?.toLocal().millisecondsSinceEpoch;
                }
                return null;
              }(),
            );
          } else {
            final wasVisible = _orchestrator.isCallScreenVisible;
            _orchestrator.session.cleanUp();
            if (wasVisible || Get.currentRoute == '/CallScreen' || Get.currentRoute == '/call-screen' || Get.currentRoute == AppRoutes.callScreen) {
              if (Get.isDialogOpen ?? false) Get.back();
              if (Get.previousRoute.isNotEmpty && Get.previousRoute != '/' && Get.previousRoute != AppRoutes.splash) {
                Get.back();
              } else {
                Get.offAllNamed(RouteHelper.getDashboardRoute());
              }
            }
          }
        } else {
          // No active session on server
          if (_orchestrator.status.value == CallStatus.ongoing || _orchestrator.status.value == CallStatus.ringing || _orchestrator.isCallScreenVisible) {
            final wasVisible = _orchestrator.isCallScreenVisible;
            _orchestrator.session.cleanUp();
            if (wasVisible || Get.currentRoute == '/CallScreen' || Get.currentRoute == '/call-screen' || Get.currentRoute == AppRoutes.callScreen) {
              if (Get.isDialogOpen ?? false) Get.back();
              if (Get.previousRoute.isNotEmpty && Get.previousRoute != '/' && Get.previousRoute != AppRoutes.splash) {
                Get.back();
              } else {
                Get.offAllNamed(RouteHelper.getDashboardRoute());
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('checkCurrentActiveCallSession Error: $e');
    }
  }
}
