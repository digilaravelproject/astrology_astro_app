import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NativeAudioRouter {
  static const MethodChannel _channel = MethodChannel('com.suryapath.app/audio_router');

  /// Routes audio output to loudspeaker when [enable] is true,
  /// or back to earpiece / headset when false.
  static Future<bool> setSpeakerphoneOn(bool enable) async {
    if (!Platform.isAndroid) return false;
    try {
      final res = await _channel.invokeMethod<bool>('setSpeakerphoneOn', {'enable': enable});
      debugPrint('[NativeAudioRouter] setSpeakerphoneOn($enable) -> $res');
      return res ?? false;
    } catch (e) {
      debugPrint('[NativeAudioRouter] Error calling setSpeakerphoneOn: $e');
      return false;
    }
  }

  /// Clears active communication device and restores normal audio mode on call finish.
  static Future<void> resetAudioRoute() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('resetAudioRoute');
      debugPrint('[NativeAudioRouter] resetAudioRoute completed');
    } catch (e) {
      debugPrint('[NativeAudioRouter] Error calling resetAudioRoute: $e');
    }
  }

  /// Checks whether speakerphone is currently active.
  static Future<bool> isSpeakerphoneOn() async {
    if (!Platform.isAndroid) return false;
    try {
      final res = await _channel.invokeMethod<bool>('isSpeakerphoneOn');
      return res ?? false;
    } catch (e) {
      return false;
    }
  }
}

