import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

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
  State<OverlayChatBubbleWidget> createState() => _OverlayChatBubbleWidgetState();
}

class _OverlayChatBubbleWidgetState extends State<OverlayChatBubbleWidget> {
  int _unreadCount = 0;
  String _status = 'initiated';
  String _name = 'User';
  String _imageUrl = '';
  int _elapsedSeconds = 0;
  Timer? _timer;
  DateTime? _startedAt;

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
           // When tapped, we send a message back to main app to open
           FlutterOverlayWindow.shareData({'action': 'tap'});
        },
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
                  color: const Color(0xFFFF6F00), // Saffron border
                  width: 2.5,
                ),
              ),
              child: ClipOval(
                child: _imageUrl.isNotEmpty
                    ? Image.network(
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
              bottom: -4,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E1A47), // Deep Violet
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Builder(builder: (context) {
                    if (_status == 'initiated' || _status == 'ringing') {
                      return const Text(
                        'Waiting',
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
                  }),
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
    );
  }

  Widget _buildInitials() {
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
