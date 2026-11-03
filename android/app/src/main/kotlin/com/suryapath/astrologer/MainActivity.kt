package com.suryapath.astrologer

import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioDeviceInfo
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.net.wifi.WifiManager
import android.os.Build
import android.os.PowerManager
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.suryapath.astrologer/app_retain"
    private val AUDIO_CHANNEL = "com.suryapath.app/audio_router"

    private var audioFocusRequest: AudioFocusRequest? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var wifiLock: WifiManager.WifiLock? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "bringToForeground") {
                val intent = Intent(context, MainActivity::class.java)
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                context.startActivity(intent)
                result.success(null)
            } else if (call.method == "sendToBackground") {
                moveTaskToBack(true)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUDIO_CHANNEL).setMethodCallHandler { call, result ->
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            when (call.method) {
                "setSpeakerphoneOn" -> {
                    val enable = call.argument<Boolean>("enable") ?: false
                    val res = setSpeakerphone(audioManager, enable)
                    result.success(res)
                }
                "setCallVolume" -> {
                    val ratio = call.argument<Double>("ratio") ?: 1.0
                    val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_VOICE_CALL)
                    val target = (maxVolume * ratio).toInt().coerceIn(1, maxVolume)
                    audioManager.setStreamVolume(AudioManager.STREAM_VOICE_CALL, target, 0)
                    Log.d("AudioRouter", "setCallVolume ratio=$ratio -> $target/$maxVolume")
                    result.success(true)
                }
                "resetAudioRoute" -> {
                    resetAudio(audioManager)
                    result.success(true)
                }
                "isSpeakerphoneOn" -> {
                    result.success(isSpeakerOn(audioManager))
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun acquireCallResources(audioManager: AudioManager) {
        try {
            // 1. Explicit Voice Communication Audio Focus so OS does not mute stream in background
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                if (audioFocusRequest == null) {
                    val playbackAttributes = AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_VOICE_COMMUNICATION)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                        .build()
                    val request = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
                        .setAudioAttributes(playbackAttributes)
                        .setAcceptsDelayedFocusGain(true)
                        .setOnAudioFocusChangeListener { focusChange ->
                            Log.d("AudioRouter", "onAudioFocusChange: $focusChange")
                        }
                        .build()
                    audioFocusRequest = request
                    val res = audioManager.requestAudioFocus(request)
                    Log.d("AudioRouter", "requestAudioFocus result: $res")
                }
            } else {
                @Suppress("DEPRECATION")
                val res = audioManager.requestAudioFocus(
                    null,
                    AudioManager.STREAM_VOICE_CALL,
                    AudioManager.AUDIOFOCUS_GAIN
                )
                Log.d("AudioRouter", "requestAudioFocus legacy result: $res")
            }

            // 2. Partial WakeLock so CPU doesn't throttle or sleep in background
            if (wakeLock == null) {
                val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
                wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "SuryaPath:CallWakeLock").apply {
                    setReferenceCounted(false)
                }
            }
            if (wakeLock?.isHeld != true) {
                wakeLock?.acquire(2 * 60 * 60 * 1000L) // 2 hours max
                Log.d("AudioRouter", "WakeLock acquired for call")
            }

            // 3. High-Performance WifiLock so WebRTC UDP sockets don't throttle in background
            if (wifiLock == null) {
                val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
                @Suppress("DEPRECATION")
                wifiLock = wifiManager.createWifiLock(WifiManager.WIFI_MODE_FULL_HIGH_PERF, "SuryaPath:CallWifiLock").apply {
                    setReferenceCounted(false)
                }
            }
            if (wifiLock?.isHeld != true) {
                wifiLock?.acquire()
                Log.d("AudioRouter", "WifiLock acquired for call")
            }
        } catch (e: Exception) {
            Log.e("AudioRouter", "Error acquiring call resources: ${e.message}", e)
        }
    }

    private fun releaseCallResources(audioManager: AudioManager) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                audioFocusRequest?.let { audioManager.abandonAudioFocusRequest(it) }
            } else {
                @Suppress("DEPRECATION")
                audioManager.abandonAudioFocus(null)
            }
            audioFocusRequest = null
            Log.d("AudioRouter", "AudioFocus released")
        } catch (e: Exception) {
            Log.w("AudioRouter", "Error releasing AudioFocus: ${e.message}")
        }

        try {
            if (wakeLock?.isHeld == true) {
                wakeLock?.release()
                Log.d("AudioRouter", "WakeLock released")
            }
        } catch (e: Exception) {
            Log.w("AudioRouter", "Error releasing WakeLock: ${e.message}")
        }

        try {
            if (wifiLock?.isHeld == true) {
                wifiLock?.release()
                Log.d("AudioRouter", "WifiLock released")
            }
        } catch (e: Exception) {
            Log.w("AudioRouter", "Error releasing WifiLock: ${e.message}")
        }
    }

    private fun setSpeakerphone(audioManager: AudioManager, enable: Boolean): Boolean {
        return try {
            acquireCallResources(audioManager)
            audioManager.mode = AudioManager.MODE_IN_COMMUNICATION
            var routed = false

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val devices = audioManager.availableCommunicationDevices
                if (enable) {
                    val speakerDevice = devices.firstOrNull {
                        it.type == AudioDeviceInfo.TYPE_BUILTIN_SPEAKER
                    }
                    if (speakerDevice != null) {
                        routed = audioManager.setCommunicationDevice(speakerDevice)
                        Log.d("AudioRouter", "setCommunicationDevice(SPEAKER) -> $routed")
                    } else {
                        Log.w("AudioRouter", "No TYPE_BUILTIN_SPEAKER in availableCommunicationDevices")
                    }
                } else {
                    val preferred = audioManager.availableCommunicationDevices.firstOrNull {
                        it.type == AudioDeviceInfo.TYPE_BLUETOOTH_SCO ||
                        it.type == AudioDeviceInfo.TYPE_BLE_HEADSET ||
                        it.type == AudioDeviceInfo.TYPE_WIRED_HEADSET ||
                        it.type == AudioDeviceInfo.TYPE_WIRED_HEADPHONES ||
                        it.type == AudioDeviceInfo.TYPE_BUILTIN_EARPIECE
                    }
                    if (preferred != null) {
                        routed = audioManager.setCommunicationDevice(preferred)
                        Log.d("AudioRouter", "setCommunicationDevice(${preferred.type}) -> $routed")
                    } else {
                        audioManager.clearCommunicationDevice()
                        Log.d("AudioRouter", "clearCommunicationDevice() called")
                        routed = true
                    }
                }
            }

            @Suppress("DEPRECATION")
            audioManager.isSpeakerphoneOn = enable
            Log.d("AudioRouter", "audioManager.isSpeakerphoneOn = $enable, routed = $routed")

            // Ensure optimal voice call stream volume for loudspeaker & earpiece
            try {
                val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_VOICE_CALL)
                if (enable) {
                    audioManager.setStreamVolume(AudioManager.STREAM_VOICE_CALL, maxVolume, 0)
                    Log.d("AudioRouter", "Boosted STREAM_VOICE_CALL volume to max ($maxVolume)")
                } else {
                    val currentVolume = audioManager.getStreamVolume(AudioManager.STREAM_VOICE_CALL)
                    val minEarpieceVolume = (maxVolume * 0.85).toInt().coerceAtLeast(1)
                    if (currentVolume < minEarpieceVolume) {
                        audioManager.setStreamVolume(AudioManager.STREAM_VOICE_CALL, minEarpieceVolume, 0)
                        Log.d("AudioRouter", "Set STREAM_VOICE_CALL volume to $minEarpieceVolume (was $currentVolume)")
                    }
                }
            } catch (volEx: Exception) {
                Log.w("AudioRouter", "Could not adjust STREAM_VOICE_CALL volume: ${volEx.message}")
            }

            true
        } catch (e: Exception) {
            Log.e("AudioRouter", "Error setting speakerphone: ${e.message}", e)
            false
        }
    }

    private fun resetAudio(audioManager: AudioManager) {
        try {
            releaseCallResources(audioManager)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                audioManager.clearCommunicationDevice()
            }
            @Suppress("DEPRECATION")
            audioManager.isSpeakerphoneOn = false
            audioManager.mode = AudioManager.MODE_NORMAL
            Log.d("AudioRouter", "resetAudio completed")
        } catch (e: Exception) {
            Log.e("AudioRouter", "Error resetting audio: ${e.message}", e)
        }
    }

    private fun isSpeakerOn(audioManager: AudioManager): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val comm = audioManager.communicationDevice
                (comm != null && comm.type == AudioDeviceInfo.TYPE_BUILTIN_SPEAKER) || audioManager.isSpeakerphoneOn
            } else {
                audioManager.isSpeakerphoneOn
            }
        } catch (e: Exception) {
            false
        }
    }

    override fun onDestroy() {
        try {
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            releaseCallResources(audioManager)
        } catch (_: Exception) {}
        super.onDestroy()
    }
}
