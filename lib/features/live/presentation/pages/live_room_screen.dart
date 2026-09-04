import 'dart:async';
import 'package:flutter/material.dart';
import 'package:astro_astrologer/core/widgets/custom_image_widget.dart';
import 'package:get/get.dart' hide navigator;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/core/widgets/app_text.dart';
import 'package:astro_astrologer/features/live/data/models/live_session_model.dart';
import 'package:astro_astrologer/features/live/presentation/controllers/live_controller.dart';
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';
import 'package:astro_astrologer/core/services/websocket/websocket_service.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/constants/app_constants.dart';

class LiveRoomScreen extends StatefulWidget {
  final LiveSessionModel session;

  const LiveRoomScreen({super.key, required this.session});

  @override
  State<LiveRoomScreen> createState() => _LiveRoomScreenState();
}

class _LiveRoomScreenState extends State<LiveRoomScreen> {
  late LiveController _controller;
  bool _isCameraOn = true;
  bool _isMuted = false;
  bool _isTogglingCamera = false;
  bool _isTogglingMic = false;

  final List<LiveComment> _comments = [];
  final List<Widget> _giftAnimations = [];
  final ScrollController _scrollController = ScrollController();
  Timer? _simulatedCommentTimer;
  StreamSubscription? _commentsSubscription;
  StreamSubscription? _superChatSubscription;
  StreamSubscription? _userJoinedSubscription;
  StreamSubscription? _userLeftSubscription;
  StreamSubscription? _viewerCountSubscription;
  late int _viewerCount;

  Room? _room;
  LocalVideoTrack? _localVideoTrack;
  LocalAudioTrack? _localAudioTrack;
  bool _isLiveKitConnected = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<LiveController>();
    _viewerCount = widget.session.viewerCount;
    _isCameraOn = widget.session.isCameraOn;
    _isMuted = !widget.session.isAudioOn;

    // Subscribe to dynamic websocket channel
    try {
      final ws = Get.find<WebSocketService>();
      ws.subscribeToChannel('presence-live-session.${widget.session.id}');

      _commentsSubscription = WebSocketService.liveCommentsEvent.stream.listen((
        event,
      ) {
        if (mounted) {
          final String userName = event['user_name'] ?? 'User';
          final String message = event['message'] ?? '';
          final String? userAvatar = event['user_avatar'];
          setState(() {
            _comments.add(
              LiveComment(
                user: userName,
                message: message,
                userAvatar: userAvatar,
              ),
            );
          });
          _scrollToBottom();
        }
      });

      _superChatSubscription = WebSocketService.superChatEvent.stream.listen((
        event,
      ) {
        if (mounted) {
          final String userName = event['user_name'] ?? 'User';
          final String giftTitle =
              event['gift'] != null ? event['gift']['title'] ?? 'Gift' : 'Gift';
          final String? userAvatar = event['user_avatar'];
          final String? giftIcon =
              event['gift'] != null ? event['gift']['icon_url'] : null;

          setState(() {
            _comments.add(
              LiveComment(
                user: userName,
                message: 'Sent a $giftTitle',
                userAvatar: userAvatar,
                giftIconUrl: giftIcon,
              ),
            );
          });
          _scrollToBottom();

          if (giftIcon != null) {
            _showGiftAnimation(giftIcon, userName, giftTitle);
          }
        }
      });

      _userJoinedSubscription = WebSocketService.userJoinedEvent.stream.listen((
        event,
      ) {
        if (mounted) {
          final String userName = event['user_name'] ?? 'User';
          final String? userAvatar = event['user_avatar'];
          setState(() {
            _comments.add(
              LiveComment(
                user: userName,
                message: 'joined',
                userAvatar: userAvatar,
                isSystem: true,
              ),
            );
          });
          _scrollToBottom();
        }
      });

      _userLeftSubscription = WebSocketService.userLeftEvent.stream.listen((
        event,
      ) {
        if (mounted) {
          final String userName = event['user_name'] ?? 'User';
          final String? userAvatar = event['user_avatar'];
          setState(() {
            _comments.add(
              LiveComment(
                user: userName,
                message: 'left',
                userAvatar: userAvatar,
                isSystem: true,
              ),
            );
          });
          _scrollToBottom();
        }
      });

      _viewerCountSubscription = WebSocketService.liveViewerCounts.listen((
        map,
      ) {
        if (mounted && map.containsKey(widget.session.id)) {
          setState(() {
            _viewerCount = map[widget.session.id]!;
          });
        }
      });
    } catch (e) {
      debugPrint('[LIVE] WebSocket subscription error: $e');
    }

    // Fetch historical comments
    _controller.fetchComments(widget.session.id).then((_) {
      if (mounted) {
        setState(() {
          _comments.addAll(
            _controller.comments.map((json) {
              final String userName = json['user_name'] ?? 'User';
              final String message = json['message'] ?? '';
              final String? userAvatar = json['user_avatar'];
              return LiveComment(
                user: userName,
                message: message,
                userAvatar: userAvatar,
              );
            }),
          );
        });
        _scrollToBottom();
      }
    });

    // Initialize camera stream
    _initCamera();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showGiftAnimation(
    String giftIconUrl,
    String senderName,
    String giftName,
  ) {
    final key = UniqueKey();
    setState(() {
      _giftAnimations.add(
        _FloatingGiftAnimation(
          key: key,
          giftIconUrl: giftIconUrl,
          senderName: senderName,
          giftName: giftName,
          onComplete: () {
            if (mounted) {
              setState(() {
                _giftAnimations.removeWhere((element) => element.key == key);
              });
            }
          },
        ),
      );
    });
  }

  bool _isConnectingLiveKit = false;

  Future<void> _initCamera() async {
    if (_isConnectingLiveKit) return;
    _isConnectingLiveKit = true;

    try {
      if (_room != null) {
        try {
          await _room!.disconnect();
          await _room!.dispose();
        } catch (e) {
          debugPrint("Error disposing previous room: $e");
        }
        _room = null;
      }

      final cameraStatus = await Permission.camera.request();
      final micStatus = await Permission.microphone.request();

      if (!cameraStatus.isGranted) {
        debugPrint('[LIVE] Camera permission not granted');
        return;
      }

      // 1. Get LiveKit credentials from backend
      final broadcastData = await _controller.startBroadcast(widget.session.id);
      if (broadcastData == null) {
        debugPrint('[LIVE] Failed to get broadcast credentials');
        CustomSnackBar.showError('Failed to get broadcast credentials');
        return;
      }

      final String wsUrl = broadcastData['livekit_ws_url'] ?? '';
      final String token = broadcastData['token'] ?? '';

      if (wsUrl.isEmpty || token.isEmpty) {
        debugPrint('[LIVE] Empty wsUrl or token');
        CustomSnackBar.showError('Empty wsUrl or token from server');
        return;
      }

      // 2. Connect to LiveKit room
      final room = Room();

      final turnServer = RTCIceServer(
        urls: [AppConstants.liveKitTurnServerUrl],
        username: AppConstants.liveKitTurnUsername,
        credential: AppConstants.liveKitTurnCredential,
      );

      await room.connect(
        wsUrl,
        token,
        connectOptions: ConnectOptions(
          rtcConfiguration: RTCConfiguration(iceServers: [turnServer]),
        ),
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
        ),
      );
      _room = room;

      final listener = room.createListener();
      listener.on<LocalTrackPublishedEvent>((event) {
        _reportMediaStatus(event.publication, 'on');
      });
      listener.on<LocalTrackUnpublishedEvent>((event) {
        _reportMediaStatus(event.publication, 'off');
      });
      listener.on<TrackMutedEvent>((event) {
        if (event.participant == room.localParticipant) {
          _reportMediaStatus(event.publication, 'off');
        }
      });
      listener.on<TrackUnmutedEvent>((event) {
        if (event.participant == room.localParticipant) {
          _reportMediaStatus(event.publication, 'on');
        }
      });

      // 3. Create local video track
      final videoTrack = await LocalVideoTrack.createCameraTrack(
        const CameraCaptureOptions(
          cameraPosition: CameraPosition.front,
        ),
      );
      await room.localParticipant?.publishVideoTrack(videoTrack);
      _localVideoTrack = videoTrack;

      // 4. Create local audio track
      if (micStatus.isGranted) {
        final audioTrack = await LocalAudioTrack.create(
          const AudioCaptureOptions(
            autoGainControl: true,
            echoCancellation: true,
            noiseSuppression: true, // Turn on for better quality without much CPU overhead
          ),
        );
        await room.localParticipant?.publishAudioTrack(
          audioTrack,
          publishOptions: const AudioPublishOptions(
            encoding: AudioEncoding.presetSpeech, // Optimize for speech instead of MusicHighQuality
            dtx: true,
          ),
        );
        _localAudioTrack = audioTrack;
      }

      if (mounted) {
        setState(() {
          _isLiveKitConnected = true;
        });
      }

      // Apply initial mute/enable settings
      if (!_isCameraOn) {
        await _localVideoTrack?.mute();
      }
      if (_isMuted) {
        await _localAudioTrack?.mute();
      }
    } catch (e) {
      debugPrint('[LIVE] Error connecting to LiveKit / publishing: $e');
      CustomSnackBar.showError('LiveKit Connection Error: $e');
      _disconnectLiveKit();
    } finally {
      _isConnectingLiveKit = false;
    }
  }

  void _disconnectLiveKit({bool updateState = true}) async {
    _localVideoTrack?.stop();
    _localVideoTrack = null;
    _localAudioTrack?.stop();
    _localAudioTrack = null;

    final roomToDispose = _room;
    _room = null;
    if (roomToDispose != null) {
      try {
        await roomToDispose.disconnect();
        await roomToDispose.dispose();
      } catch (e) {
        debugPrint('[LIVE] Error disconnecting room: $e');
      }
    }

    if (updateState && mounted) {
      setState(() {
        _isLiveKitConnected = false;
      });
    }
  }

  Future<void> _reportTrackStatus(TrackPublication? publication) async {
    if (publication == null) return;
    await _reportMediaStatus(publication, publication.muted ? 'off' : 'on');
  }

  Future<void> _reportMediaStatus(
    TrackPublication? publication,
    String explicitStatus,
  ) async {
    if (publication == null) return;
    try {
      final type = publication.kind == TrackType.VIDEO ? 'camera' : 'audio';
      final apiClient = Get.find<ApiClient>();
      final url = AppUrls.reportMediaStatus(widget.session.id);
      debugPrint('[LIVE] Reporting media status: $type -> $explicitStatus');
      await apiClient.post(
        url,
        data: {'type': type, 'status': explicitStatus},
        handleError: false,
        showErrorScreen: false,
      );
    } catch (e) {
      debugPrint('[LIVE] Media status report failed: $e');
    }
  }

  Future<void> _toggleCamera() async {
    if (_isTogglingCamera) return;
    _isTogglingCamera = true;
    try {
      final publication =
          _room?.localParticipant?.videoTrackPublications.isNotEmpty == true
              ? _room!.localParticipant!.videoTrackPublications.first
              : null;
      if (publication != null) {
        final newMuted = !publication.muted;
        setState(() {
          _isCameraOn = !newMuted;
        });
        if (newMuted) {
          await publication.mute();
        } else {
          await publication.unmute();
        }
        await _reportMediaStatus(publication, newMuted ? 'off' : 'on');
      }
    } finally {
      _isTogglingCamera = false;
    }
  }

  Future<void> _toggleMic() async {
    if (_isTogglingMic) return;
    _isTogglingMic = true;
    try {
      final publication =
          _room?.localParticipant?.audioTrackPublications.isNotEmpty == true
              ? _room!.localParticipant!.audioTrackPublications.first
              : null;
      if (publication != null) {
        final newMuted = !publication.muted;
        setState(() {
          _isMuted = newMuted;
        });
        if (newMuted) {
          await publication.mute();
        } else {
          await publication.unmute();
        }
        await _reportMediaStatus(publication, newMuted ? 'off' : 'on');
      }
    } finally {
      _isTogglingMic = false;
    }
  }

  @override
  void dispose() {
    _simulatedCommentTimer?.cancel();
    _commentsSubscription?.cancel();
    _superChatSubscription?.cancel();
    _userJoinedSubscription?.cancel();
    _userLeftSubscription?.cancel();
    _viewerCountSubscription?.cancel();
    _scrollController.dispose();
    _controller.stopBroadcast(widget.session.id);
    _disconnectLiveKit(updateState: false);
    try {
      final ws = Get.find<WebSocketService>();
      ws.unsubscribeFromChannel('presence-live-session.${widget.session.id}');
    } catch (e) {
      debugPrint('[LIVE] WebSocket unsubscribe error: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera View Area (Renders LiveKit VideoRenderer or fallback)
          Positioned.fill(
            child:
                _isCameraOn && _localVideoTrack != null
                    ? VideoTrackRenderer(
                      _localVideoTrack!,
                      fit: VideoViewFit.cover,
                    )
                    : Container(
                      color: Colors.grey.shade900,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isCameraOn ? Icons.videocam : Icons.videocam_off,
                              size: 80,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            const SizedBox(height: 12),
                            AppText(
                              _isCameraOn
                                  ? 'Initializing camera...'
                                  : 'Camera is Stopped',
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                      ),
                    ),
          ),

          // 3. Top Header Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Live indicator + Viewer count
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.circle, color: Colors.white, size: 8),
                          SizedBox(width: 4),
                          AppText(
                            'LIVE',
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.visibility,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Obx(() {
                            final currentCount =
                                _controller
                                    .currentActiveSession
                                    .value
                                    ?.viewerCount ??
                                _viewerCount;
                            return AppText(
                              '$currentCount',
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),

                // End Session Button
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const AppText(
                              'End Stream?',
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                            content: const AppText(
                              'Are you sure you want to stop broadcasting?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const AppText(
                                  'Cancel',
                                  color: Colors.grey,
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Get.back();
                                  await _controller.stopBroadcast(
                                    widget.session.id,
                                  );
                                  await _controller.stopSession(
                                    widget.session.id,
                                  );
                                  if (mounted) {
                                    setState(() {
                                      _isCameraOn = false;
                                      _isMuted = true;
                                    });
                                  }
                                  Get.back();
                                },
                                child: const AppText(
                                  'End Live',
                                  color: Colors.red,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                    );
                  },
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),

          // 4. Live Comments & controls layout
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title of live stream
                    AppText(
                      widget.session.title,
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      widget.session.description ?? 'Broadcasting Live',
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    const SizedBox(height: 16),

                    // Real-time Comments List
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 180),
                      child: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.white],
                            stops: [0.0, 0.25],
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.dstIn,
                        child: ListView.builder(
                          shrinkWrap: true,
                          controller: _scrollController,
                          itemCount: _comments.length,
                          itemBuilder: (context, index) {
                            final c = _comments[index];

                            final avatarUrl =
                                (c.userAvatar != null &&
                                        c.userAvatar!.isNotEmpty)
                                    ? (c.userAvatar!.startsWith('http')
                                        ? c.userAvatar!
                                        : '${AppUrls.baseImageUrl}${c.userAvatar}')
                                    : null;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipOval(
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      color: Colors.grey.shade800,
                                      child:
                                          avatarUrl != null
                                              ? CustomImageWidget(
                                                imagePath: avatarUrl,
                                                fit: BoxFit.cover,
                                                fallbackWidget: const Icon(
                                                  Icons.person,
                                                  size: 12,
                                                  color: Colors.white,
                                                ),
                                              )
                                              : const Icon(
                                                Icons.person,
                                                size: 12,
                                                color: Colors.white,
                                              ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                c.isSystem
                                                    ? '${c.user} '
                                                    : '${c.user}: ',
                                            style: const TextStyle(
                                              color: Colors.amber,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          TextSpan(
                                            text: c.message,
                                            style: TextStyle(
                                              color:
                                                  c.isSystem
                                                      ? Colors.white70
                                                      : Colors.white,
                                              fontSize: 13,
                                              fontStyle:
                                                  c.isSystem
                                                      ? FontStyle.italic
                                                      : FontStyle.normal,
                                            ),
                                          ),
                                          if (c.giftIconUrl != null)
                                            WidgetSpan(
                                              alignment:
                                                  PlaceholderAlignment.middle,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 4,
                                                ),
                                                child: CustomImageWidget(
                                                  imagePath: c.giftIconUrl!,
                                                  width: 24,
                                                  height: 24,
                                                  fallbackWidget: const Icon(
                                                    Icons.card_giftcard,
                                                    size: 20,
                                                    color: Colors.orange,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Controls Area
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Camera on/off
                        _buildControlButton(
                          icon:
                              _isCameraOn ? Icons.videocam : Icons.videocam_off,
                          color: _isCameraOn ? Colors.white24 : Colors.red,
                          onPressed: _toggleCamera,
                        ),

                        // Flip Camera
                        _buildControlButton(
                          icon: Icons.switch_camera_rounded,
                          color: Colors.white24,
                          onPressed: () {
                            final track = _localVideoTrack;
                            if (track != null) {
                              Helper.switchCamera(track.mediaStreamTrack);
                            }
                          },
                        ),

                        // Mute microphone
                        _buildControlButton(
                          icon: _isMuted ? Icons.mic_off : Icons.mic,
                          color: _isMuted ? Colors.red : Colors.white24,
                          onPressed: _toggleMic,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          ..._giftAnimations,
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 24),
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}

class LiveComment {
  final String user;
  final String message;
  final String? userAvatar;
  final String? giftIconUrl;
  final bool isSystem;

  LiveComment({
    required this.user,
    required this.message,
    this.userAvatar,
    this.giftIconUrl,
    this.isSystem = false,
  });
}

class _FloatingGiftAnimation extends StatefulWidget {
  final String giftIconUrl;
  final String senderName;
  final String giftName;
  final VoidCallback onComplete;

  const _FloatingGiftAnimation({
    super.key,
    required this.giftIconUrl,
    required this.senderName,
    required this.giftName,
    required this.onComplete,
  });

  @override
  State<_FloatingGiftAnimation> createState() => _FloatingGiftAnimationState();
}

class _FloatingGiftAnimationState extends State<_FloatingGiftAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.1,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 10,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInBack)),
        weight: 15,
      ),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 75),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 15),
    ]).animate(_controller);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: const Offset(0, -0.6),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 20),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 0.08,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.08,
          end: -0.08,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -0.08,
          end: 0.05,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.05,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 10,
      ),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 20),
    ]).animate(_controller);

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Center(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RotationTransition(
                    turns: _rotationAnimation,
                    child: CustomImageWidget(
                      imagePath: widget.giftIconUrl,
                      width: 90,
                      height: 90,
                      fallbackWidget: const Icon(
                        Icons.card_giftcard,
                        size: 60,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade700.withOpacity(0.8),
                          Colors.red.shade600.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.yellow, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.senderName} sent ${widget.giftName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.star, color: Colors.yellow, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
