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

  bool _isRemoteDescriptionSet = false;
  final List<RTCIceCandidate> _remoteCandidateQueue = [];

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

  String _normalizeSdp(String sdp) {
    String cleanSdp = sdp.trim();
    if (cleanSdp.startsWith('"') && cleanSdp.endsWith('"')) {
      cleanSdp = cleanSdp.substring(1, cleanSdp.length - 1);
    }
    
    // Convert all escaped newlines to standard LF
    cleanSdp = cleanSdp
        .replaceAll('\\r\\n', '\n')
        .replaceAll('\\n', '\n')
        .replaceAll('\\r', '\n')
        .replaceAll(r'\r\n', '\n')
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\r', '\n');

    // Split by LF and join using CRLF to ensure every line ends with \r\n
    List<String> lines = cleanSdp.split('\n');
    return lines.map((line) => line.trim()).where((line) => line.isNotEmpty).join('\r\n') + '\r\n';
  }

  Future<void> setRemoteAnswer(String answerSdp) async {
    try {
      if (peerConnection == null) {
        Logger.e('WebRTCService: peerConnection is null. Cannot set remote answer.');
        return;
      }
      final normalized = _normalizeSdp(answerSdp);
      RTCSessionDescription answer = RTCSessionDescription(normalized, 'answer');
      await peerConnection!.setRemoteDescription(answer);
      _isRemoteDescriptionSet = true;
      Logger.d('WebRTCService: Remote Answer SDP set successfully.');
      _flushRemoteCandidates();
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

      Logger.d('WebRTCService: offerSdp (raw) length: ${offerSdp.length}');
      Logger.d('WebRTCService: offerSdp value: $offerSdp');
      final normalized = _normalizeSdp(offerSdp);
      Logger.d('WebRTCService: normalized SDP length: ${normalized.length}');
      Logger.d('WebRTCService: normalized SDP value: $normalized');
      RTCSessionDescription offer = RTCSessionDescription(normalized, 'offer');
      await peerConnection!.setRemoteDescription(offer);
      _isRemoteDescriptionSet = true;
      _flushRemoteCandidates();

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
      Map<String, dynamic> candidateMap = jsonDecode(candidateJson);
      RTCIceCandidate candidate = RTCIceCandidate(
        candidateMap['candidate']?.toString() ?? candidateMap['iceCandidate']?.toString() ?? '',
        candidateMap['sdpMid']?.toString() ?? '',
        candidateMap['sdpMLineIndex'] is int ? candidateMap['sdpMLineIndex'] : int.tryParse(candidateMap['sdpMLineIndex']?.toString() ?? '') ?? 0,
      );

      if (peerConnection != null && _isRemoteDescriptionSet) {
        await peerConnection!.addCandidate(candidate);
        Logger.d('WebRTCService: Ice Candidate added successfully.');
      } else {
        _remoteCandidateQueue.add(candidate);
        Logger.d('WebRTCService: Queued remote ICE candidate. Total queued: ${_remoteCandidateQueue.length}');
      }
    } catch (e) {
      Logger.e('WebRTCService: Error adding remote candidate -> $e');
    }
  }

  void _flushRemoteCandidates() {
    if (_remoteCandidateQueue.isNotEmpty) {
      Logger.d('WebRTCService: Flushing ${_remoteCandidateQueue.length} queued remote candidates.');
      for (var candidate in _remoteCandidateQueue) {
        peerConnection?.addCandidate(candidate).catchError((e) {
          Logger.e('WebRTCService: Error adding flushed remote candidate -> $e');
        });
      }
      _remoteCandidateQueue.clear();
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
      _isRemoteDescriptionSet = false;
      _remoteCandidateQueue.clear();
      Logger.d('WebRTCService: Disposed peer connection & streams.');
    } catch (e) {
      Logger.e('WebRTCService: Error disposing WebRTC resources -> $e');
    }
  }
}
