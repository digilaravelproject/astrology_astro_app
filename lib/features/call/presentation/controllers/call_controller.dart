import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/enums/session_status_enums.dart';
import 'package:astro_astrologer/core/services/webrtc/webrtc_service.dart';
import 'package:astro_astrologer/core/services/websocket/websocket_service.dart';
import 'call_session_controller.dart';
import 'call_webrtc_controller.dart';

class CallController extends GetxController {
  final CallSessionController session;
  final CallWebRTCController webrtc;
  final WebRTCService webrtcService = WebRTCService();

  CallController({required this.session, required this.webrtc});

  // Delegate State
  Rx<CallStatus> get status => session.status;
  RxInt get durationSeconds => session.durationSeconds;
  
  bool get isCallScreenVisible => session.isCallScreenVisible;
  set isCallScreenVisible(bool val) => session.isCallScreenVisible = val;

  int? get sessionId => session.sessionId;
  set sessionId(int? val) => session.sessionId = val;
  
  String? get consumerName => session.consumerName;
  set consumerName(String? val) => session.consumerName = val;
  
  String? get consumerImage => session.consumerImage;
  set consumerImage(String? val) => session.consumerImage = val;

  int? get consumerId => session.consumerId;
  set consumerId(int? val) => session.consumerId = val;

  String? get incomingOfferSdp => session.incomingOfferSdp;
  bool get isPackageCall => session.isPackageCall;
  bool get isChatAlsoActive => session.isChatAlsoActive;
  int? get subSessionId => session.subSessionId;
  
  RxBool isMuted = false.obs;
  RxBool isSpeakerOn = false.obs;

  bool get isEndingCall => webrtc.isEndingCall;
  int get packageMasterSeconds => WebSocketService.packageRemainingSeconds.value;

  void toggleMute() {
    isMuted.value = !isMuted.value;
    webrtcService.toggleMute(isMuted.value);
  }

  void toggleSpeaker() {
    isSpeakerOn.value = !isSpeakerOn.value;
    webrtcService.toggleSpeaker(isSpeakerOn.value);
  }

  // Delegate Methods
  Future<bool> acceptCall(String offerSdp) => webrtc.acceptCall(offerSdp);
  Future<bool> acceptCallDirect() => webrtc.acceptCallDirect();
  Future<void> rejectCall() => webrtc.rejectCall();
  Future<void> cancelCall() => webrtc.cancelCall();
  Future<void> endCall() => webrtc.endCall();
  
  Future<void> terminateChannelOnly() => webrtc.terminateChannelOnly();
  Future<void> terminateEntireSession() => webrtc.terminateEntireSession();

  Future<bool> checkPendingCall() => webrtc.checkPendingCall();
  Future<String?> fetchOfferSdpFromCurrentSession() => webrtc.fetchOfferSdpFromCurrentSession();
  Future<void> checkCurrentActiveCallSession() => webrtc.checkCurrentActiveCallSession();

  void minimizeToBubble(BuildContext context, String name, String image, {bool shouldPop = true}) {
    session.minimizeToBubble(context, name, image, shouldPop: shouldPop);
  }

  void cleanUp() => session.cleanUp();
}
