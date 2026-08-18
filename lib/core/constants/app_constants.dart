import 'package:astro_astrologer/core/constants/app_urls.dart';

import '../services/config/env_config.dart';

class AppConstants {
    static String appName = EnvConfig.appName;
    static String baseUrl = AppUrls.baseUrl;
    static const String fontFamily = 'Poppins';
    static const String defaultTag = 'PCB_APP'; // default tag for log checking
    static const String googleMapApiKey = 'AIzaSyA4mCZDv97Ks802PCQgStmdkQfQXe7ZT2Y';

    static const bool isHandleInternetScreen = true;
    static const bool isHandleErrorScreen = false;
    static const bool handleError = true; // manages logic-level error flow.
    static const bool showToaster = false; // manages UI-level notifications.

    // API base URLs
    static  String imageUrl = '$baseUrl';

    // API endpoints
    // Add your endpoints here

    // Shared Preferences keys
    static const String theme = 'theme';
    static const String language = 'language';
    static const String token = 'token';
    static const String userData = 'user_data';
    static const String isLoggedIn = 'is_logged_in';
    // Call-related constants
    static const String outgoingRingPath = 'audio/outgoing_ring.mp3';
    static const String incomingRingPath = 'audio/incoming_ring.mp3';
    static const String webrtcStunServer = 'stun:stun.l.google.com:19302';
    
    // LiveKit TURN Server Config
    static const String liveKitTurnServerUrl = 'turn:187.127.173.87:3478';
    static const String liveKitTurnUsername = 'livekit';
    static const String liveKitTurnCredential = 'livekit_secret_2024';

    // Notification Sound Asset Paths
    static const String callNotificationSound = 'assets/audio/incoming_ring.mp3';
    static const String chatNotificationSound = 'assets/audio/incoming_ring.mp3';
    static const String generalNotificationSound = 'assets/audio/incoming_ring.mp3';
}
