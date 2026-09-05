import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/utils/logger.dart';
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';
import 'package:astro_astrologer/core/services/callkit_service.dart';
import 'package:astro_astrologer/core/enums/session_status_enums.dart';
import 'package:astro_astrologer/features/chat/presentation/pages/chat_screen.dart';
import 'call_controller.dart';
import 'package:astro_astrologer/routes/app_routes.dart';

class CallWebRTCController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  CallController get _orchestrator => Get.find<CallController>();

  bool isEndingCall = false;
  bool isAccepting = false;

  Future<bool> acceptCall(String offerSdp) async {
    if (_orchestrator.sessionId == null) return false;
    if (isAccepting) return false;
    isAccepting = true;
    try {
      _orchestrator.session.isSummaryShown = false;
      _orchestrator.session.stopRingtone();
      _orchestrator.session.ringingTimer?.cancel();
      _orchestrator.status.value = CallStatus.ongoing;
      _orchestrator.durationSeconds.value = 0;

      final sdpToUse = (offerSdp.isNotEmpty) ? offerSdp : (_orchestrator.session.incomingOfferSdp ?? '');

      if (sdpToUse.isEmpty) {
        return await acceptCallDirect();
      }

      final answerDescription = await _orchestrator.webrtcService.acceptOffer(_orchestrator.sessionId!, sdpToUse);
      
      final response = await _apiClient.post(
        AppUrls.acceptCall(_orchestrator.sessionId!),
        data: {'answer': answerDescription.sdp},
        handleError: true,
        showErrorScreen: false,
      );

      if (response.isSuccess) {
        CallkitService.endAllCalls();
        _orchestrator.session.callStartedAt = DateTime.now();
        _orchestrator.durationSeconds.value = 0;
        _orchestrator.session.startCallTimer();
        _orchestrator.session.showOngoingNotification();
        return true;
      } else {
        _orchestrator.session.cleanUp();
        CustomSnackBar.showError('Failed to accept call: ${response.message}');
        return false;
      }
    } catch (e) {
      _orchestrator.session.cleanUp();
      return false;
    } finally {
      isAccepting = false;
    }
  }

  Future<bool> acceptCallDirect() async {
    if (_orchestrator.sessionId == null) return false;
    try {
      _orchestrator.session.isSummaryShown = false;
      _orchestrator.session.stopRingtone();
      _orchestrator.session.ringingTimer?.cancel();
      _orchestrator.status.value = CallStatus.ongoing;
      _orchestrator.durationSeconds.value = 0;

      final offerDescription = await _orchestrator.webrtcService.createOffer(_orchestrator.sessionId!);
      
      final response = await _apiClient.post(
        AppUrls.acceptCall(_orchestrator.sessionId!),
        data: {'answer': offerDescription.sdp},
        handleError: true,
        showErrorScreen: false,
      );

      if (response.isSuccess) {
        CallkitService.endAllCalls();
        _orchestrator.session.startCallTimer();
        _orchestrator.session.showOngoingNotification();
        return true;
      } else {
        _orchestrator.session.cleanUp();
        Future.delayed(const Duration(seconds: 1), () {
          CustomSnackBar.showError('Failed to accept call: ${response.message}');
        });
        return false;
      }
    } catch (e) {
      _orchestrator.session.cleanUp();
      return false;
    }
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
    if (_orchestrator.sessionId == null) return;
    isEndingCall = true;
    try {
      final response = await _apiClient.post(
        AppUrls.endCallSession(_orchestrator.sessionId!),
        handleError: true,
        showErrorScreen: false,
      );
      if (response.isSuccess) {
        if (_orchestrator.session.isSummaryShown) return;
        _orchestrator.session.isSummaryShown = true;
        _orchestrator.status.value = CallStatus.completed;
        
        final wasVisible = _orchestrator.isCallScreenVisible;
        _orchestrator.session.cleanUp();
        if (wasVisible || Get.currentRoute == '/CallScreen' || Get.currentRoute == '/call-screen' || Get.currentRoute == AppRoutes.callScreen) {
          if (Get.isDialogOpen ?? false) Get.back();
          Get.back();
        }
      } else {
        final wasVisible = _orchestrator.isCallScreenVisible;
        _orchestrator.session.cleanUp();
        if (wasVisible || Get.currentRoute == '/CallScreen' || Get.currentRoute == '/call-screen' || Get.currentRoute == AppRoutes.callScreen) {
          if (Get.isDialogOpen ?? false) Get.back();
          Get.back();
        }
      }
    } catch (e) {
      _orchestrator.session.cleanUp();
    } finally {
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

          if (_orchestrator.status.value == CallStatus.ringing && _orchestrator.sessionId == newSessionId) return true;

          _orchestrator.session.sessionId = newSessionId;
          _orchestrator.session.consumerId = int.tryParse(caller?['id']?.toString() ?? '') ?? 0;
          _orchestrator.session.consumerName = caller?['name']?.toString() ?? 'User';
          _orchestrator.session.consumerImage = caller?['profile_photo']?.toString();
          _orchestrator.session.isSummaryShown = false;
          _orchestrator.status.value = CallStatus.ringing;
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

          if (_orchestrator.status.value == CallStatus.completed || _orchestrator.status.value == CallStatus.cancelled || _orchestrator.status.value == CallStatus.rejected) return;

          _orchestrator.session.isSummaryShown = false;
          _orchestrator.session.sessionId = int.tryParse(session['id']?.toString() ?? '');
          _orchestrator.webrtcService.activeSessionId = _orchestrator.sessionId;
          
          _orchestrator.status.value = CallStatus.values.firstWhere(
            (e) => e.name == (sessionStatus == 'initiated' ? 'ringing' : sessionStatus),
            orElse: () => CallStatus.ongoing,
          );

          if (sessionStatus == 'initiated') {
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
              if (startedAt != null) _orchestrator.durationSeconds.value = DateTime.now().difference(startedAt).inSeconds;
            }
            _orchestrator.session.startCallTimer();
            
            if (_orchestrator.webrtcService.peerConnection == null) {
              final offerSdp = session['offer']?.toString() ?? session['offer_sdp']?.toString() ?? session['consumer_sdp']?.toString();
              if (offerSdp != null && offerSdp.isNotEmpty) {
                await _orchestrator.webrtcService.acceptOffer(_orchestrator.sessionId!, offerSdp);
              } else {
                try {
                  final newOffer = await _orchestrator.webrtcService.createOffer(_orchestrator.sessionId!);
                  await _apiClient.post(AppUrls.acceptCall(_orchestrator.sessionId!), data: {'answer': newOffer.sdp}, handleError: false, showErrorScreen: false);
                } catch (e) {}
              }
            }

            if (!_orchestrator.isCallScreenVisible && _orchestrator.status.value == CallStatus.ongoing) {
              if (Get.currentRoute != AppRoutes.callScreen) {
                Get.toNamed(AppRoutes.callScreen);
              }
            }
          } else {
            if (_orchestrator.isCallScreenVisible || Get.isDialogOpen == true) Get.back();
            _orchestrator.session.cleanUp();
          }
        }
      }
    } catch (e) {
      debugPrint('checkCurrentActiveCallSession Error: $e');
    }
  }
}
