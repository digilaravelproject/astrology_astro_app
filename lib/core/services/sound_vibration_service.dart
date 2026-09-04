import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class SoundVibrationService {
  static final SoundVibrationService _instance =
      SoundVibrationService._internal();
  factory SoundVibrationService() => _instance;
  SoundVibrationService._internal();

  AudioPlayer? _audioPlayer;
  Timer? _loopTimer;

  /// Play a sound from assets.
  /// Example: [soundName] = 'incoming_ring' (resolves to 'audio/incoming_ring.mp3')
  Future<void> playSound(String soundName, {bool loop = false}) async {
    try {
      await stopSound();
      _audioPlayer = AudioPlayer();

      String assetPath = soundName;
      if (!soundName.contains('/') && !soundName.contains('.')) {
        assetPath = 'audio/$soundName.mp3';
      }

      await _audioPlayer?.play(AssetSource(assetPath));

      if (loop) {
        await _audioPlayer?.setReleaseMode(ReleaseMode.loop);
        
        // Manual fallback loop timer for devices where ReleaseMode.loop fails or is suspended
        _loopTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
          if (_audioPlayer != null && _audioPlayer!.state != PlayerState.playing) {
             await _audioPlayer?.resume();
          }
        });
      } else {
        await _audioPlayer?.setReleaseMode(ReleaseMode.release);
      }

      debugPrint(
        'SoundVibrationService: Playing sound $assetPath (loop: $loop)',
      );
    } catch (e) {
      debugPrint('SoundVibrationService error playing sound: $e');
    }
  }

  bool _isStopping = false;

  /// Stop the playing sound.
  Future<void> stopSound() async {
    if (_isStopping || _audioPlayer == null) return;
    _isStopping = true;
    try {
      _loopTimer?.cancel();
      _loopTimer = null;
      
      final player = _audioPlayer;
      _audioPlayer = null; // null first to prevent re-entry
      await player?.stop();
      await player?.dispose();
      debugPrint('SoundVibrationService: Sound stopped');
    } catch (e) {
      debugPrint('SoundVibrationService error stopping sound: $e');
    } finally {
      _isStopping = false;
    }
  }

  Timer? _vibrationTimer;

  /// Start device vibration.
  Future<void> startVibration({
    List<int> pattern = const [500, 1000, 500, 1000],
    int repeat = 0,
  }) async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        await stopVibration(); // Stop any existing loop first
        
        // Initial vibration
        await Vibration.vibrate(pattern: pattern, repeat: repeat);
        debugPrint('SoundVibrationService: Vibration started');
        
        // Explicitly loop vibration just in case `repeat: 0` is not fully supported on some devices
        if (repeat == 0) {
           _vibrationTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
             await Vibration.vibrate(pattern: pattern, repeat: repeat);
           });
        }
      }
    } catch (e) {
      debugPrint('SoundVibrationService error starting vibration: $e');
    }
  }

  /// Stop device vibration.
  Future<void> stopVibration() async {
    try {
      _vibrationTimer?.cancel();
      _vibrationTimer = null;
      await Vibration.cancel();
      debugPrint('SoundVibrationService: Vibration stopped');
    } catch (e) {
      debugPrint('SoundVibrationService error stopping vibration: $e');
    }
  }

  /// Helper to start both sound and vibration (e.g. for incoming/outgoing ringtones)
  Future<void> startRingtone(
    String soundName, {
    bool loop = true,
    bool vibrate = true,
  }) async {
    await playSound(soundName, loop: loop);
    if (vibrate) {
      await startVibration(pattern: const [500, 1000, 500, 1000], repeat: 0);
    }
  }

  /// Helper to stop both sound and vibration
  Future<void> stopRingtone() async {
    await stopSound();
    await stopVibration();
  }
}
