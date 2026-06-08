import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' hide navigator;
import 'package:astro_astrologer/core/constants/app_constants.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/utils/logger.dart';

class WebRTCService {
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;
  Function(MediaStream)? onRemoteStreamAdded;
  Function(RTCIceConnectionState)? onConnectionStateChanged;

  final Map<String, dynamic> _iceConfig = {
    'iceServers': [
      {'urls': AppConstants.webrtcStunServer},
    ],
    'sdpSemantics': 'unified-plan',
  };

  final Map<String, dynamic> _constraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': false,
    },
    'optional': [],
  };

  Future<void> initLocalStream() async {
    try {
      final Map<String, dynamic> mediaConstraints = {
        'audio': true,
        'video': false,
      };
      localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      Logger.d('WebRTCService: Local audio stream initialized successfully.');
    } catch (e) {
      Logger.e('WebRTCService: Error initializing local stream -> $e');
      rethrow;
    }
  }

  Future<RTCSessionDescription> createOffer(int sessionId) async {
    try {
      await initLocalStream();
      peerConnection = await createPeerConnection(_iceConfig, _constraints);

      // Listeners
      peerConnection!.onIceCandidate = (candidate) {
        _sendIceCandidate(sessionId, candidate);
      };

      peerConnection!.onIceConnectionState = (state) {
        Logger.d('WebRTCService: Connection state changed -> $state');
        if (onConnectionStateChanged != null) {
          onConnectionStateChanged!(state);
        }
      };

      peerConnection!.onAddStream = (stream) {
        Logger.d('WebRTCService: Remote stream added.');
        remoteStream = stream;
        if (onRemoteStreamAdded != null) {
          onRemoteStreamAdded!(stream);
        }
      };

      // Add local tracks
      localStream!.getTracks().forEach((track) {
        peerConnection!.addTrack(track, localStream!);
      });

      RTCSessionDescription offer = await peerConnection!.createOffer(_constraints);
      await peerConnection!.setLocalDescription(offer);
      Logger.d('WebRTCService: SDP Offer created.');
      return offer;
    } catch (e) {
      Logger.e('WebRTCService: Error creating offer -> $e');
      rethrow;
    }
  }

  Future<void> setRemoteAnswer(String answerSdp) async {
    try {
      if (peerConnection == null) {
        Logger.e('WebRTCService: peerConnection is null. Cannot set remote answer.');
        return;
      }
      RTCSessionDescription answer = RTCSessionDescription(answerSdp, 'answer');
      await peerConnection!.setRemoteDescription(answer);
      Logger.d('WebRTCService: Remote Answer SDP set successfully.');
    } catch (e) {
      Logger.e('WebRTCService: Error setting remote answer -> $e');
      rethrow;
    }
  }

  Future<RTCSessionDescription> acceptOffer(int sessionId, String offerSdp) async {
    try {
      await initLocalStream();
      peerConnection = await createPeerConnection(_iceConfig, _constraints);

      // Listeners
      peerConnection!.onIceCandidate = (candidate) {
        _sendIceCandidate(sessionId, candidate);
      };

      peerConnection!.onIceConnectionState = (state) {
        Logger.d('WebRTCService: Connection state changed -> $state');
        if (onConnectionStateChanged != null) {
          onConnectionStateChanged!(state);
        }
      };

      peerConnection!.onAddStream = (stream) {
        Logger.d('WebRTCService: Remote stream added.');
        remoteStream = stream;
        if (onRemoteStreamAdded != null) {
          onRemoteStreamAdded!(stream);
        }
      };

      // Add local tracks
      localStream!.getTracks().forEach((track) {
        peerConnection!.addTrack(track, localStream!);
      });

      RTCSessionDescription offer = RTCSessionDescription(offerSdp, 'offer');
      await peerConnection!.setRemoteDescription(offer);

      RTCSessionDescription answer = await peerConnection!.createAnswer(_constraints);
      await peerConnection!.setLocalDescription(answer);
      
      Logger.d('WebRTCService: SDP Answer created & set as local.');
      return answer;
    } catch (e) {
      Logger.e('WebRTCService: Error accepting offer -> $e');
      rethrow;
    }
  }

  Future<void> addRemoteCandidate(String candidateJson) async {
    try {
      if (peerConnection == null) {
        Logger.e('WebRTCService: PeerConnection is null. Cannot add remote candidate.');
        return;
      }
      Map<String, dynamic> candidateMap = jsonDecode(candidateJson);
      RTCIceCandidate candidate = RTCIceCandidate(
        candidateMap['candidate']?.toString() ?? candidateMap['iceCandidate']?.toString() ?? '',
        candidateMap['sdpMid']?.toString() ?? '',
        candidateMap['sdpMLineIndex'] is int ? candidateMap['sdpMLineIndex'] : int.tryParse(candidateMap['sdpMLineIndex']?.toString() ?? '') ?? 0,
      );
      await peerConnection!.addCandidate(candidate);
      Logger.d('WebRTCService: Ice Candidate added successfully.');
    } catch (e) {
      Logger.e('WebRTCService: Error adding remote candidate -> $e');
    }
  }

  void toggleMute(bool isMuted) {
    if (localStream != null) {
      localStream!.getAudioTracks().forEach((track) {
        track.enabled = !isMuted;
      });
      Logger.d('WebRTCService: Microphones enabled = ${!isMuted}');
    }
  }

  void toggleSpeaker(bool isSpeakerOn) {
    if (localStream != null) {
      localStream!.getAudioTracks().forEach((track) {
        track.enableSpeakerphone(isSpeakerOn);
      });
      Logger.d('WebRTCService: Speakerphone enabled = $isSpeakerOn');
    }
  }

  Future<void> _sendIceCandidate(int sessionId, RTCIceCandidate candidate) async {
    try {
      final apiClient = Get.find<ApiClient>();
      final candidateStr = jsonEncode({
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });

      await apiClient.post(
        AppUrls.sendIceCandidate(sessionId),
        data: {'candidate': candidateStr},
        handleError: false,
        showErrorScreen: false,
      );
      Logger.d('WebRTCService: Ice Candidate sent successfully.');
    } catch (e) {
      Logger.e('WebRTCService: Error sending ice candidate -> $e');
    }
  }

  void dispose() {
    try {
      localStream?.getTracks().forEach((track) => track.stop());
      localStream?.dispose();
      remoteStream?.dispose();
      peerConnection?.close();
      peerConnection?.dispose();
      Logger.d('WebRTCService: Disposed peer connection & streams.');
    } catch (e) {
      Logger.e('WebRTCService: Error disposing WebRTC resources -> $e');
    }
  }
}
