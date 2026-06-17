import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide navigator;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../data/models/live_session_model.dart';
import '../controllers/live_controller.dart';
import '../../../../core/utils/custom_snackbar.dart';
import '../../../../core/services/network/websocket_service.dart';
import '../../../../core/services/network/api_client.dart';


class LiveRoomScreen extends StatefulWidget {
  final LiveSessionModel session;

  const LiveRoomScreen({
    super.key,
    required this.session,
  });

  @override
  State<LiveRoomScreen> createState() => _LiveRoomScreenState();
}

class _LiveRoomScreenState extends State<LiveRoomScreen> {
  late LiveController _controller;
  bool _isCameraOn = true;
  bool _isMuted = false;
  String _selectedFilter = 'Normal';
  final List<String> _filters = ['Normal', 'Warm', 'Cool', 'Vintage', 'Glow'];
  
  final List<LiveComment> _comments = [];
  final ScrollController _scrollController = ScrollController();
  Timer? _simulatedCommentTimer;
  Timer? _activeSessionPollTimer;
  StreamSubscription? _commentsSubscription;
  StreamSubscription? _superChatSubscription;
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

    // Subscribe to dynamic websocket channel
    try {
      final ws = Get.find<WebSocketService>();
      ws.subscribeToChannel('live-session.${widget.session.id}');
      
      _commentsSubscription = WebSocketService.liveCommentsEvent.stream.listen((event) {
        if (mounted) {
          final String userName = event['user_name'] ?? 'User';
          final String message = event['message'] ?? '';
          setState(() {
            _comments.add(LiveComment(user: userName, message: message));
          });
          _scrollToBottom();
        }
      });

      _superChatSubscription = WebSocketService.superChatEvent.stream.listen((event) {
        if (mounted) {
          final String userName = event['user_name'] ?? 'User';
          final String message = event['message'] ?? '';
          setState(() {
            _comments.add(LiveComment(user: userName, message: '🎁 Gift Tip: $message'));
          });
          _scrollToBottom();
        }
      });
    } catch (e) {
      debugPrint('[LIVE] WebSocket subscription error: $e');
    }

    // Fetch historical comments
    _controller.fetchComments(widget.session.id).then((_) {
      if (mounted) {
        setState(() {
          _comments.addAll(_controller.comments.map((json) {
            final String userName = json['user_name'] ?? 'User';
            final String message = json['message'] ?? '';
            return LiveComment(user: userName, message: message);
          }));
        });
        _scrollToBottom();
      }
    });

    // Initialize camera stream
    _initCamera();
  
    // Poll active session details for viewer count
    _activeSessionPollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _controller.checkCurrentActiveSession();
      }
    });
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

  Future<void> _initCamera() async {
    try {
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
      await room.connect(
        wsUrl,
        token,
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
        ),
      );
      _room = room;
      
      final listener = room.createListener();
      listener.on<LocalTrackPublishedEvent>((event) {
        _reportTrackStatus(event.publication);
      });
      listener.on<LocalTrackUnpublishedEvent>((event) {
        _reportTrackStatus(event.publication);
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
        final audioTrack = await LocalAudioTrack.create();
        await room.localParticipant?.publishAudioTrack(audioTrack);
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
    }
  }
  
  void _disconnectLiveKit() {
    _localVideoTrack?.stop();
    _localVideoTrack = null;
    _localAudioTrack?.stop();
    _localAudioTrack = null;
    _room?.disconnect();
    _room = null;
    if (mounted) {
      setState(() {
        _isLiveKitConnected = false;
      });
    }
  }

  Future<void> _reportTrackStatus(LocalTrackPublication publication) async {
    final type = publication.kind == TrackType.Video ? 'camera' : 'audio';
    final status = publication.muted ? 'off' : 'on';
    await _reportMediaStatus(type, status);
  }

  Future<void> _reportMediaStatus(String type, String status) async {
    try {
      final apiClient = Get.find<ApiClient>();
      final url = '/astrologer/live/${widget.session.id}/media-status';
      debugPrint('[LIVE] Reporting media status: $type -> $status');
      await apiClient.post(
        url,
        data: {
          'type': type,
          'status': status,
        },
        handleError: false,
        showErrorScreen: false,
      );
    } catch (e) {
      debugPrint('[LIVE] Media status report failed: $e');
    }
  }
  
  @override
  void dispose() {
    _simulatedCommentTimer?.cancel();
    _activeSessionPollTimer?.cancel();
    _commentsSubscription?.cancel();
    _superChatSubscription?.cancel();
    _scrollController.dispose();
    _controller.stopBroadcast(widget.session.id);
    _disconnectLiveKit();
    try {
      final ws = Get.find<WebSocketService>();
      ws.unsubscribeFromChannel('live-session.${widget.session.id}');
    } catch (e) {
      debugPrint('[LIVE] WebSocket unsubscribe error: $e');
    }
    super.dispose();
  }



  Color _getFilterColor() {
    switch (_selectedFilter) {
      case 'Warm':
        return Colors.orange.withOpacity(0.15);
      case 'Cool':
        return Colors.blue.withOpacity(0.12);
      case 'Vintage':
        return Colors.brown.withOpacity(0.18);
      case 'Glow':
        return Colors.yellow.withOpacity(0.1);
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera View Area (Renders LiveKit VideoRenderer or fallback)
          Positioned.fill(
            child: _isCameraOn && _localVideoTrack != null
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
                            _isCameraOn ? 'Initializing camera...' : 'Camera is Stopped',
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // 2. Filter Color overlay
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                color: _getFilterColor(),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.circle, color: Colors.white, size: 8),
                          SizedBox(width: 4),
                          AppText('LIVE', color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.visibility, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Obx(() {
                            final currentCount = _controller.currentActiveSession.value?.viewerCount ?? _viewerCount;
                            return AppText('$currentCount', color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold);
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
                      builder: (context) => AlertDialog(
                        title: const AppText('End Stream?', fontWeight: FontWeight.w700, fontSize: 18),
                        content: const AppText('Are you sure you want to stop broadcasting?'),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const AppText('Cancel', color: Colors.grey),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.back();
                              _controller.stopSession(widget.session.id);
                              Get.back();
                            },
                            child: const AppText('End Live', color: Colors.red, fontWeight: FontWeight.w700),
                          ),
                        ],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  SizedBox(
                    height: 180,
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
                        controller: _scrollController,
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final c = _comments[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${c.user}: ',
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  TextSpan(
                                    text: c.message,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
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
                        icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                        color: _isCameraOn ? Colors.white24 : Colors.red,
                        onPressed: () async {
                          final isNewStateOn = !_isCameraOn;
                          setState(() {
                            _isCameraOn = isNewStateOn;
                          });
                          if (isNewStateOn) {
                            await _localVideoTrack?.unmute();
                          } else {
                            await _localVideoTrack?.mute();
                          }
                          await _reportMediaStatus('camera', isNewStateOn ? 'on' : 'off');
                        },
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
                      
                      // Filter Selection
                      _buildControlButton(
                        icon: Icons.filter_vintage,
                        color: Colors.white24,
                        onPressed: () {
                          _showFilterBottomSheet();
                        },
                      ),

                      // Mute microphone
                      _buildControlButton(
                        icon: _isMuted ? Icons.mic_off : Icons.mic,
                        color: _isMuted ? Colors.red : Colors.white24,
                        onPressed: () async {
                          final isNewStateMuted = !_isMuted;
                          setState(() {
                            _isMuted = isNewStateMuted;
                          });
                          if (isNewStateMuted) {
                            await _localAudioTrack?.mute();
                          } else {
                            await _localAudioTrack?.unmute();
                          }
                          await _reportMediaStatus('audio', isNewStateMuted ? 'off' : 'on');
                        },
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ),
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
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 24),
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F0F12),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  'Select Camera Filter',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final f = _filters[index];
                      final isSelected = _selectedFilter == f;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilter = f;
                          });
                          setSheetState(() {});
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryColor : Colors.white12,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isSelected ? Colors.amber : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: AppText(
                              f,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LiveComment {
  final String user;
  final String message;

  LiveComment({required this.user, required this.message});
}
