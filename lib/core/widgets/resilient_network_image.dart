import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// A robust network image widget that automatically detects and repairs
/// truncated or corrupted image streams (e.g. truncated JPEGs missing EOI markers)
/// that normal Image.network / CachedNetworkImage fail to decode.
class ResilientNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ResilientNetworkImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  /// In-memory cache of decoded/repaired image bytes (limited to 50 entries to conserve memory)
  static final _LruMemoryCache _cache = _LruMemoryCache(50);

  /// Public helper to pre-fetch or get repaired image bytes
  static Future<Uint8List?> getBytes(String url) => _cache.getOrFetch(url);

  @override
  State<ResilientNetworkImage> createState() => _ResilientNetworkImageState();
}

class _ResilientNetworkImageState extends State<ResilientNetworkImage> {
  Uint8List? _bytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant ResilientNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    final cached = ResilientNetworkImage._cache.get(widget.imageUrl);
    if (cached != null) {
      if (mounted) {
        setState(() {
          _bytes = cached;
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final bytes = await ResilientNetworkImage._cache.getOrFetch(widget.imageUrl);

    if (!mounted) return;

    if (bytes != null) {
      setState(() {
        _bytes = bytes;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes != null) {
      return Image.memory(
        _bytes!,
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    }

    if (_isLoading) {
      return widget.placeholder ??
          Container(
            height: widget.height,
            width: widget.width,
            color: Colors.grey.shade100,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
    }

    return _buildErrorWidget();
  }

  Widget _buildErrorWidget() {
    return widget.errorWidget ??
        Container(
          height: widget.height,
          width: widget.width,
          color: Colors.grey.shade300,
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
  }
}

class _LruMemoryCache {
  final int maxEntries;
  final LinkedHashMap<String, Uint8List> _map = LinkedHashMap<String, Uint8List>();

  _LruMemoryCache(this.maxEntries);

  Uint8List? get(String key) {
    if (_map.containsKey(key)) {
      final value = _map.remove(key)!;
      _map[key] = value;
      return value;
    }
    return null;
  }

  void put(String key, Uint8List value) {
    if (_map.containsKey(key)) {
      _map.remove(key);
    } else if (_map.length >= maxEntries) {
      _map.remove(_map.keys.first);
    }
    _map[key] = value;
  }

  Future<Uint8List?> getOrFetch(String url) async {
    final cached = get(url);
    if (cached != null) return cached;

    try {
      final uri = Uri.parse(url);
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      client.connectionTimeout = const Duration(seconds: 15);
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode != 200) return null;

      final bytesList = await response.fold<List<int>>([], (acc, chunk) => acc..addAll(chunk));
      Uint8List bytes = Uint8List.fromList(bytesList);

      // 1. Try decoding standard bytes
      bool canDecode = false;
      try {
        final codec = await ui.instantiateImageCodec(bytes);
        await codec.getNextFrame();
        canDecode = true;
      } catch (_) {
        canDecode = false;
      }

      // 2. If decoding fails, check for truncated JPEG and repair
      if (!canDecode && bytes.length > 4) {
        if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
          // Find last non-zero byte (strip corrupt trailing zeroes)
          int lastIdx = bytes.length - 1;
          while (lastIdx >= 0 && bytes[lastIdx] == 0x00) {
            lastIdx--;
          }
          if (lastIdx > 1) {
            final clean = bytes.sublist(0, lastIdx + 1);
            Uint8List repaired;
            if (clean.length >= 2 &&
                clean[clean.length - 2] == 0xFF &&
                clean[clean.length - 1] == 0xD9) {
              repaired = clean;
            } else {
              // Append missing EOI (End of Image) marker
              repaired = Uint8List(clean.length + 2);
              repaired.setRange(0, clean.length, clean);
              repaired[clean.length] = 0xFF;
              repaired[clean.length + 1] = 0xD9;
            }

            try {
              final codec = await ui.instantiateImageCodec(repaired);
              await codec.getNextFrame();
              bytes = repaired;
              canDecode = true;
            } catch (e) {
              debugPrint('[ResilientNetworkImage] Repair failed: $e');
            }
          }
        }
      }

      if (canDecode) {
        put(url, bytes);
        return bytes;
      }
    } catch (e) {
      debugPrint('[ResilientNetworkImage] Error downloading $url: $e');
    }
    return null;
  }
}
