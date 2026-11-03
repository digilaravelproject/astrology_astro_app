package com.suryapath.astrologer

import android.content.Context
import android.content.Intent
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.os.Build
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.suryapath.astrologer/app_retain"
    private val AUDIO_CHANNEL = "com.suryapath.app/audio_router"

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

    private fun setSpeakerphone(audioManager: AudioManager, enable: Boolean): Boolean {
        return try {
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
            true
        } catch (e: Exception) {
            Log.e("AudioRouter", "Error setting speakerphone: ${e.message}", e)
            false
        }
    }

    private fun resetAudio(audioManager: AudioManager) {
        try {
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
}
