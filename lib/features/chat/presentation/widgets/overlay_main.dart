import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:astro_astrologer/core/widgets/custom_image_widget.dart';

class OverlayChatBubbleApp extends StatelessWidget {
  const OverlayChatBubbleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OverlayChatBubbleWidget(),
    );
  }
}

class OverlayChatBubbleWidget extends StatefulWidget {
  const OverlayChatBubbleWidget({super.key});

  @override
  State<OverlayChatBubbleWidget> createState() =>
      _OverlayChatBubbleWidgetState();
}

class _OverlayChatBubbleWidgetState extends State<OverlayChatBubbleWidget> {
  int _unreadCount = 0;
  String _status = 'initiated';
  String _name = 'User';
  String _imageUrl = '';
  int _elapsedSeconds = 0;
  Timer? _timer;
  DateTime? _startedAt;
  bool _isCall = false;
  bool _isLive = false;

  @override
  void initState() {
    super.initState();
    _startListeningToData();
  }

  void _startListeningToData() {
    FlutterOverlayWindow.overlayListener.listen((event) {
      if (event != null && event is Map) {
        setState(() {
          _status = event['status'] ?? _status;
          _name = event['name'] ?? _name;
          _imageUrl = event['imageUrl'] ?? _imageUrl;
          _unreadCount = event['unreadCount'] ?? _unreadCount;
          _isCall = event['isCall'] ?? _isCall;
          _isLive = event['isLive'] ?? _isLive;

          if (event['type'] == 'init' || event['type'] == 'update') {
            final startedAtStr = event['startedAt'];
            if (startedAtStr != null && startedAtStr.isNotEmpty) {
              _startedAt = DateTime.tryParse(startedAtStr)?.toLocal();
            }
          }
        });

        if (_status == 'ongoing' && _timer == null) {
          _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            setState(() {
              if (_startedAt != null) {
                final diff = DateTime.now().difference(_startedAt!).inSeconds;
                _elapsedSeconds = diff > 0 ? diff : 0;
              } else {
                _elapsedSeconds++;
              }
            });
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          debugPrint("==== GESTURE DETECTOR TAPPED ====");
          FlutterOverlayWindow.shareData({'action': 'tap'});

          final String portName =
              _isLive
                  ? 'overlay_live_port'
                  : (_isCall ? 'overlay_call_port' : 'overlay_chat_port');
          final SendPort? sendPort = IsolateNameServer.lookupPortByName(
            portName,
          );
          sendPort?.send('tap');
        },
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color:
                        _isLive
                            ? Colors.red.shade600
                            : (_isCall
                                ? Colors.green.shade600
                                : const Color(0xFFFF6F00)), // Red for Live
                    width: 2.5,
                  ),
                ),
                child: ClipOval(
                  child:
                      _imageUrl.isNotEmpty
                          ? CustomImageWidget(
                            imagePath:
                                _imageUrl.startsWith('http')
                                    ? _imageUrl
                                    : 'https://suryapathkundli.com/storage/app/public/$_imageUrl',
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => _buildInitials(),
                          )
                          : _buildInitials(),
                ),
              ),

              // Timing overlay
              Positioned(
                bottom: -12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E1A47), // Deep Violet
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Builder(
                      builder: (context) {
                        if (_status == 'initiated' || _status == 'ringing') {
                          return const Text('Waiting'.tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                        return Text(
                          _formatDuration(_elapsedSeconds),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Unread count badge
              if (_unreadCount > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        '$_unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitials() {
    if (_isLive) {
      return Container(
        color: const Color(0xFF2E1A47),
        child: const Center(
          child: Icon(Icons.live_tv_rounded, color: Colors.white, size: 28),
        ),
      );
    }
    if (_isCall) {
      return Container(
        color: const Color(0xFF2E1A47),
        child: const Center(
          child: Icon(Icons.phone, color: Colors.white, size: 28),
        ),
      );
    }
    final String initial = _name.isNotEmpty ? _name[0].toUpperCase() : 'C';
    return Container(
      color: const Color(0xFF2E1A47),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
