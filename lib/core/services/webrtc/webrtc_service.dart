import 'dart:async';
import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' hide navigator;
import 'package:livekit_client/livekit_client.dart';
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

  final RxInt currentPingMs = 0.obs;
  Timer? _pingTimer;
  final List<RTCIceCandidate> _remoteCandidateQueue = [];

  final Map<String, dynamic> _iceConfig = {
    'iceServers': [
      {'urls': AppConstants.webrtcStunServer},
      {
        'urls': [
          AppConstants.liveKitTurnServerUrl,
          '${AppConstants.liveKitTurnServerUrl}?transport=udp',
          '${AppConstants.liveKitTurnServerUrl}?transport=tcp',
        ],
        'username': AppConstants.liveKitTurnUsername,
        'credential': AppConstants.liveKitTurnCredential,
      },
    ],
    'sdpSemantics': 'unified-plan',
  };

  final Map<String, dynamic> _constraints = {
    'mandatory': {'OfferToReceiveAudio': true, 'OfferToReceiveVideo': false},
    'optional': [],
  };

  Future<void> initLocalStream() async {
    try {
      final Map<String, dynamic> mediaConstraints = {
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
          'mandatory': {
            'googEchoCancellation': true, // Speaker ka echo khatam karega
            'googAutoGainControl': true, // Awaz fatne nahi dega (clipping rokega)
            'googNoiseSuppression': true, // Background shor/noise cut karega
            'googHighpassFilter': true, // Low rumble/fan noise hatayega
            'googTypingNoiseDetection': true,
          },
          'optional': [],
        },
        'video': false,
      };
      localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      Logger.d('WebRTCService: Local audio stream initialized successfully.');

      // Configure audio session for two-way communication
      await initAudioSession();

      // Apply current mute and speaker routing (earpiece default if false)
      toggleMute(currentMuteState);
      toggleSpeaker(currentSpeakerState); 
    } catch (e) {
      Logger.e('WebRTCService: Error initializing local stream -> $e');
      rethrow;
    }
  }

  int? _activeSessionId;
  final List<RTCIceCandidate> _queuedIceCandidates = [];

  int? get activeSessionId => _activeSessionId;
  set activeSessionId(int? id) {
    _activeSessionId = id;
    if (id != null && id > 0 && _queuedIceCandidates.isNotEmpty) {
      Logger.d(
        'WebRTCService: Flushing ${_queuedIceCandidates.length} queued ICE candidates for session $id.',
      );
      for (var candidate in _queuedIceCandidates) {
        _sendIceCandidate(id, candidate);
      }
      _queuedIceCandidates.clear();
    }
  }

  Future<RTCSessionDescription> createOffer(int sessionId) async {
    try {
      _isRemoteDescriptionSet = false;
      _remoteCandidateQueue.clear();
      activeSessionId = sessionId;
      await initLocalStream();
      peerConnection = await createPeerConnection(_iceConfig, _constraints);

      // Listeners
      peerConnection!.onIceCandidate = (candidate) {
        _sendIceCandidate(sessionId, candidate);
      };

      peerConnection!.onIceConnectionState = (state) {
        Logger.d('WebRTCService: ICE Connection state changed -> $state');
        if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
          _startPingTimer();
          toggleSpeaker(currentSpeakerState);
        } else if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected || 
                   state == RTCIceConnectionState.RTCIceConnectionStateFailed ||
                   state == RTCIceConnectionState.RTCIceConnectionStateClosed) {
          _stopPingTimer();
        }
        if (onConnectionStateChanged != null) {
          onConnectionStateChanged!(state);
        }
      };

      peerConnection!.onConnectionState = (state) {
        Logger.d('WebRTCService: Peer connection state changed -> $state');
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          _startPingTimer();
          toggleSpeaker(currentSpeakerState);
        }
      };

      peerConnection!.onAddStream = (stream) {
        Logger.d('WebRTCService: Remote stream added via onAddStream.');
        remoteStream = stream;
        remoteStream!.getAudioTracks().forEach((track) => track.enabled = true);
        toggleSpeaker(currentSpeakerState);
        if (onRemoteStreamAdded != null) {
          onRemoteStreamAdded!(stream);
        }
      };

      peerConnection!.onTrack = (event) async {
        Logger.d('WebRTCService: Remote track added via onTrack: ${event.track.kind}');
        if (event.track.kind == 'audio') {
          event.track.enabled = true;
        }
        if (event.streams.isNotEmpty) {
          remoteStream = event.streams[0];
        } else if (remoteStream == null) {
          try {
            remoteStream = await createLocalMediaStream('remote_stream_${event.track.id}');
          } catch (e) {
            Logger.e('WebRTCService: Error creating fallback remote stream -> $e');
          }
        }
        if (remoteStream != null) {
          try {
            if (!remoteStream!.getTracks().any((t) => t.id == event.track.id)) {
              remoteStream!.addTrack(event.track);
            }
          } catch (_) {}
          remoteStream!.getAudioTracks().forEach((track) => track.enabled = true);
          toggleSpeaker(currentSpeakerState);
          if (onRemoteStreamAdded != null) {
            onRemoteStreamAdded!(remoteStream!);
          }
        }
      };

      // Add local tracks
      localStream!.getTracks().forEach((track) {
        peerConnection!.addTrack(track, localStream!);
      });

      RTCSessionDescription offer = await peerConnection!.createOffer(
        _constraints,
      );
      final optimizedSdp = optimizeSdpForAudio(offer.sdp ?? '');
      final modifiedOffer = RTCSessionDescription(optimizedSdp, offer.type);
      await peerConnection!.setLocalDescription(modifiedOffer);
      Logger.d('WebRTCService: SDP Offer created & optimized for Opus FEC.');
      return modifiedOffer;
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
    return lines
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .join('\r\n') +
        '\r\n';
  }

  String fixAudioCodec(String sdp) {
    if (sdp.isEmpty) return sdp;

    // Avoid duplicate modifications if already injected
    if (sdp.contains('usedtx=1') && sdp.contains('maxaveragebitrate=24000')) {
      return sdp;
    }

    if (sdp.contains('maxaveragebitrate=24000')) {
      return sdp.replaceAll(
        'maxaveragebitrate=24000',
        'usedtx=1; cbr=0; maxaveragebitrate=24000',
      );
    }

    const opusParams = 'useinbandfec=1; usedtx=1; cbr=0; stereo=0; maxaveragebitrate=24000';

    // Low network par packet loss recover karne ke liye Opus FEC + DTX enable karein
    if (sdp.contains('useinbandfec=1')) {
      sdp = sdp.replaceAll(
        'useinbandfec=1',
        opusParams,
      );
    } else if (sdp.contains('minptime=10')) {
      sdp = sdp.replaceAll(
        'minptime=10',
        'minptime=10; $opusParams',
      );
    } else {
      final opusMatch = RegExp(r'a=rtpmap:(\d+)\s+opus/48000', caseSensitive: false).firstMatch(sdp);
      if (opusMatch != null) {
        final pt = opusMatch.group(1);
        final fmtpRegex = RegExp('a=fmtp:$pt([^\r\n]*)');
        if (fmtpRegex.hasMatch(sdp)) {
          sdp = sdp.replaceAllMapped(
            fmtpRegex,
            (match) => 'a=fmtp:$pt${match.group(1)}; $opusParams',
          );
        } else {
          sdp = sdp.replaceFirst(
            'a=rtpmap:$pt opus/48000/2',
            'a=rtpmap:$pt opus/48000/2\r\na=fmtp:$pt minptime=10; $opusParams',
          );
        }
      }
    }
    return sdp;
  }

  String optimizeSdpForAudio(String sdp) => fixAudioCodec(sdp);

  Future<void> setRemoteAnswer(String answerSdp) async {
    try {
      if (peerConnection == null) {
        Logger.e(
          'WebRTCService: peerConnection is null. Cannot set remote answer.',
        );
        return;
      }
      final normalized = _normalizeSdp(answerSdp);
      final optimizedAnswerSdp = optimizeSdpForAudio(normalized);
      RTCSessionDescription answer = RTCSessionDescription(
        optimizedAnswerSdp,
        'answer',
      );
      await peerConnection!.setRemoteDescription(answer);
      _isRemoteDescriptionSet = true;
      Logger.d('WebRTCService: Remote Answer SDP set successfully (FEC optimized).');
      _flushRemoteCandidates();
    } catch (e) {
      Logger.e('WebRTCService: Error setting remote answer -> $e');
      rethrow;
    }
  }

  Future<RTCSessionDescription> acceptOffer(
    int sessionId,
    String offerSdp,
  ) async {
    try {
      _isRemoteDescriptionSet = false;
      _remoteCandidateQueue.clear();
      activeSessionId = sessionId;
      await initLocalStream();
      peerConnection = await createPeerConnection(_iceConfig, _constraints);

      // Listeners
      peerConnection!.onIceCandidate = (candidate) {
        _sendIceCandidate(sessionId, candidate);
      };

      peerConnection!.onIceConnectionState = (state) {
        Logger.d('WebRTCService: ICE Connection state changed -> $state');
        if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
          _startPingTimer();
          toggleSpeaker(currentSpeakerState);
        } else if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected || 
                   state == RTCIceConnectionState.RTCIceConnectionStateFailed ||
                   state == RTCIceConnectionState.RTCIceConnectionStateClosed) {
          _stopPingTimer();
        }
        if (onConnectionStateChanged != null) {
          onConnectionStateChanged!(state);
        }
      };

      peerConnection!.onConnectionState = (state) {
        Logger.d('WebRTCService: Peer connection state changed -> $state');
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          _startPingTimer();
          toggleSpeaker(currentSpeakerState);
        }
      };

      peerConnection!.onAddStream = (stream) {
        Logger.d('WebRTCService: Remote stream added via onAddStream.');
        remoteStream = stream;
        remoteStream!.getAudioTracks().forEach((track) => track.enabled = true);
        toggleSpeaker(currentSpeakerState);
        if (onRemoteStreamAdded != null) {
          onRemoteStreamAdded!(stream);
        }
      };

      peerConnection!.onTrack = (event) async {
        Logger.d('WebRTCService: Remote track added via onTrack: ${event.track.kind}');
        if (event.track.kind == 'audio') {
          event.track.enabled = true;
        }
        if (event.streams.isNotEmpty) {
          remoteStream = event.streams[0];
        } else if (remoteStream == null) {
          try {
            remoteStream = await createLocalMediaStream('remote_stream_${event.track.id}');
          } catch (e) {
            Logger.e('WebRTCService: Error creating fallback remote stream -> $e');
          }
        }
        if (remoteStream != null) {
          try {
            if (!remoteStream!.getTracks().any((t) => t.id == event.track.id)) {
              remoteStream!.addTrack(event.track);
            }
          } catch (_) {}
          remoteStream!.getAudioTracks().forEach((track) => track.enabled = true);
          toggleSpeaker(currentSpeakerState);
          if (onRemoteStreamAdded != null) {
            onRemoteStreamAdded!(remoteStream!);
          }
        }
      };

      // Add local tracks
      localStream!.getTracks().forEach((track) {
        peerConnection!.addTrack(track, localStream!);
      });

      Logger.d('WebRTCService: offerSdp (raw) length: ${offerSdp.length}');
      Logger.d('WebRTCService: offerSdp value: $offerSdp');
      final normalized = _normalizeSdp(offerSdp);
      final optimizedOfferSdp = fixAudioCodec(normalized);
      Logger.d('WebRTCService: normalized SDP length: ${normalized.length}');
      Logger.d('WebRTCService: normalized SDP value: $normalized');
      RTCSessionDescription offer = RTCSessionDescription(optimizedOfferSdp, 'offer');
      await peerConnection!.setRemoteDescription(offer);
      _isRemoteDescriptionSet = true;
      _flushRemoteCandidates();

      RTCSessionDescription answer = await peerConnection!.createAnswer(
        _constraints,
      );
      final optimizedAnswerSdp = fixAudioCodec(answer.sdp ?? '');
      final modifiedAnswer = RTCSessionDescription(optimizedAnswerSdp, answer.type);
      await peerConnection!.setLocalDescription(modifiedAnswer);

      Logger.d('WebRTCService: SDP Answer created & set as local (FEC optimized).');
      return modifiedAnswer;
    } catch (e) {
      Logger.e('WebRTCService: Error accepting offer -> $e');
      rethrow;
    }
  }

  Future<void> addRemoteCandidate(dynamic candidateData) async {
    try {
      if (candidateData == null) return;
      Map<String, dynamic> candidateMap;
      if (candidateData is Map) {
        candidateMap = Map<String, dynamic>.from(candidateData);
      } else {
        try {
          candidateMap = jsonDecode(candidateData.toString());
        } catch (e) {
          // If it's a plain string, wrap it
          candidateMap = {'candidate': candidateData.toString(), 'sdpMid': '0', 'sdpMLineIndex': 0};
        }
      }

      final candidateStr = candidateMap['candidate']?.toString() ??
          candidateMap['iceCandidate']?.toString() ??
          '';

      if (candidateStr.trim().isEmpty) {
        Logger.d('WebRTCService: Candidate string is empty, skipping.');
        return;
      }
      
      RTCIceCandidate candidate = RTCIceCandidate(
        candidateStr,
        candidateMap['sdpMid']?.toString() ?? '0',
        candidateMap['sdpMLineIndex'] is int
            ? candidateMap['sdpMLineIndex']
            : int.tryParse(candidateMap['sdpMLineIndex']?.toString() ?? '') ?? 0,
      );

      // Make sure karein ki peerConnection.addCandidate(candidate) tabhi call ho
      // jab setRemoteDescription complete ho chuka ho.
      if (peerConnection != null && _isRemoteDescriptionSet) {
        await peerConnection!.addCandidate(candidate);
        Logger.d('WebRTCService: Ice Candidate added successfully.');
      } else {
        _remoteCandidateQueue.add(candidate);
        Logger.d(
          'WebRTCService: Queued remote ICE candidate (setRemoteDescription not ready). Total queued: ${_remoteCandidateQueue.length}',
        );
      }
    } catch (e) {
      Logger.e('WebRTCService: Error adding remote candidate -> $e');
    }
  }

  void _flushRemoteCandidates() {
    if (_remoteCandidateQueue.isNotEmpty) {
      Logger.d(
        'WebRTCService: Flushing ${_remoteCandidateQueue.length} queued remote candidates.',
      );
      for (var candidate in _remoteCandidateQueue) {
        peerConnection?.addCandidate(candidate).catchError((e) {
          Logger.e(
            'WebRTCService: Error adding flushed remote candidate -> $e',
          );
        });
      }
      _remoteCandidateQueue.clear();
    }
  }

  bool currentMuteState = false;
  bool currentSpeakerState = false;

  void toggleMute(bool isMuted) {
    currentMuteState = isMuted;
    if (localStream != null) {
      localStream!.getAudioTracks().forEach((track) {
        track.enabled = !isMuted;
      });
      Logger.d('WebRTCService: Microphones enabled = ${!isMuted}');
    }
  }

  Future<void> initAudioSession() async {
    try {
      // ignore: experimental_member_use
      await AudioManager.instance.setAudioSessionOptions(
        // ignore: experimental_member_use
        const AudioSessionOptions.communication(),
      );
      Logger.d('WebRTCService: LiveKit AudioManager configured for communication.');
    } catch (e) {
      Logger.e('WebRTCService: Error configuring audio session -> $e');
    }
  }

  void toggleSpeaker(bool isSpeakerOn) {
    currentSpeakerState = isSpeakerOn;
    try {
      AudioManager.instance.setSpeakerOutputPreferred(isSpeakerOn, force: isSpeakerOn);
      Logger.d('WebRTCService: AudioManager.setSpeakerOutputPreferred($isSpeakerOn, force: $isSpeakerOn) called');
    } catch (e) {
      Logger.e('WebRTCService: AudioManager.setSpeakerOutputPreferred error -> $e');
    }

    try {
      Helper.setSpeakerphoneOn(isSpeakerOn);
      Logger.d('WebRTCService: Helper.setSpeakerphoneOn($isSpeakerOn) called');
    } catch (e) {
      Logger.e('WebRTCService: Helper.setSpeakerphoneOn error -> $e');
    }

    if (localStream != null) {
      localStream!.getAudioTracks().forEach((track) {
        // ignore: deprecated_member_use
        track.enableSpeakerphone(isSpeakerOn);
      });
      Logger.d('WebRTCService: Track Speakerphone enabled = $isSpeakerOn');
    }
  }


  void _startPingTimer() {
    _stopPingTimer();
    _pingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final pc = peerConnection;
      if (pc == null) {
        _stopPingTimer();
        return;
      }
      try {
        final stats = await pc.getStats();
        for (var report in stats) {
          if (report.type == 'candidate-pair' && report.values['state'] == 'succeeded') {
            final double? rtt = report.values['currentRoundTripTime'];
            if (rtt != null) {
              currentPingMs.value = (rtt * 1000).toInt();
            }
            break;
          }
        }
      } catch (e) {
        // PeerConnection may have closed concurrently
        if (peerConnection == null) {
          _stopPingTimer();
        } else {
          Logger.e('WebRTCService: Error getting stats for ping -> $e');
        }
      }
    });
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
    currentPingMs.value = 0;
  }

  Future<void> _sendIceCandidate(
    int sessionId,
    RTCIceCandidate candidate,
  ) async {
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
      _stopPingTimer();
      try {
        // ignore: experimental_member_use
        AudioManager.instance.deactivateAudioSession();
        Logger.d('WebRTCService: AudioManager session deactivated');
      } catch (e) {
        Logger.e('WebRTCService: Error deactivating audio session -> $e');
      }
      currentMuteState = false;
      currentSpeakerState = false;
      toggleSpeaker(false);
      toggleMute(false);
      localStream?.getTracks().forEach((track) => track.stop());
      localStream?.dispose();
      localStream = null;
      remoteStream?.dispose();
      remoteStream = null;
      peerConnection?.close();
      peerConnection?.dispose();
      peerConnection = null;
      _isRemoteDescriptionSet = false;
      _remoteCandidateQueue.clear();
      _queuedIceCandidates.clear();
      _activeSessionId = null;
      Logger.d('WebRTCService: Disposed peer connection & streams.');
    } catch (e) {
      Logger.e('WebRTCService: Error disposing WebRTC resources -> $e');
    }
  }
}
