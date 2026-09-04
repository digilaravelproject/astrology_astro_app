import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:astro_astrologer/core/services/callkit_service.dart';

import 'package:astro_astrologer/core/services/local_notification_service.dart';
import 'dart:async';
import 'dart:convert';
import 'package:astro_astrologer/core/enums/session_status_enums.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:astro_astrologer/features/live/data/models/live_session_model.dart';
import 'package:astro_astrologer/core/services/storage/token_manger.dart';
import 'package:astro_astrologer/core/services/storage/shared_prefs.dart';
import 'package:astro_astrologer/core/constants/app_constants.dart';
import 'package:astro_astrologer/features/auth/data/models/user_model.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:astro_astrologer/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_astrologer/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_astrologer/features/call/presentation/widgets/floating_call_bubble.dart';
import 'package:astro_astrologer/features/chat/presentation/controllers/chat_controller.dart';
import 'package:astro_astrologer/features/chat/domain/usecases/sync_message_status_usecase.dart';
import 'package:astro_astrologer/features/live/presentation/controllers/live_controller.dart';
import 'package:astro_astrologer/features/chat/presentation/controllers/assistant_chat_list_controller.dart';
import 'package:astro_astrologer/features/chat/presentation/controllers/assistant_chat_list_controller.dart';
import 'package:astro_astrologer/features/chat/presentation/controllers/assistance_chat_room_controller.dart';
import 'package:astro_astrologer/features/live/data/models/live_session_model.dart';
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';
import 'package:astro_astrologer/core/services/websocket/router/websocket_event_router.dart';
import '../network/api_client.dart';
import 'websocket_state.dart';

class WebSocketService extends GetxService with WidgetsBindingObserver {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _isConnecting = false;
  String? _socketId;
  final Set<String> _subscribedChannels = {};
  int? _userId;
  String? _token;
  int _reconnectAttempts = 0;
  DateTime? _lastPingSentAt;
  Timer? _heartbeatTimer;
  Timer? _pongTimeoutTimer;
  static const Duration _heartbeatInterval = Duration(seconds: 25);
  static const Duration _pongTimeout = Duration(seconds: 10);

  // ─── State Forwarding Shims ────────────────────────────────────────────────
  // All reactive state now lives in WebSocketState.
  // These shims keep existing code (WebSocketService.xxx) compiling unchanged.

  static int? get activeSessionId => WebSocketState.activeSessionId;
  static set activeSessionId(int? v) => WebSocketState.activeSessionId = v;

  static int? get currentUserId => WebSocketState.currentUserId;
  static set currentUserId(int? v) => WebSocketState.currentUserId = v;

  static Map<int, String> get sessionStartTimes => WebSocketState.sessionStartTimes;
  static Map<String, dynamic>? get lastChatSenderData => WebSocketState.lastChatSenderData;
  static set lastChatSenderData(Map<String, dynamic>? v) => WebSocketState.lastChatSenderData = v;

  // Chat
  static RxInt get currentPingMs => WebSocketState.currentPingMs;
  static RxMap<int, String> get sessionStatusUpdates => WebSocketState.sessionStatusUpdates;
  static RxList<Map<String, dynamic>> get incomingMessages => WebSocketState.incomingMessages;
  static RxList<Map<String, dynamic>> get messageStatusUpdates => WebSocketState.messageStatusUpdates;
  static RxList<Map<String, dynamic>> get presenceUpdates => WebSocketState.presenceUpdates;
  static RxInt get chatEndedSessionId => WebSocketState.chatEndedSessionId;
  static RxInt get chatDismissedSessionId => WebSocketState.chatDismissedSessionId;
  static RxMap<String, dynamic> get chatEndedBilling => WebSocketState.chatEndedBilling;
  static StreamController<Map<String, dynamic>> get chatInitiatedEvent => WebSocketState.chatInitiatedEvent;
  static StreamController<Map<String, dynamic>> get chatQueueUpdatedEvent => WebSocketState.chatQueueUpdatedEvent;

  // Call
  static RxMap<int, String> get callSessionStatusUpdates => WebSocketState.callSessionStatusUpdates;
  static RxInt get callEndedSessionId => WebSocketState.callEndedSessionId;
  static RxInt get callDismissedSessionId => WebSocketState.callDismissedSessionId;
  static StreamController<Map<String, dynamic>> get callInitiatedEvent => WebSocketState.callInitiatedEvent;
  static RxMap<String, dynamic> get callAcceptedData => WebSocketState.callAcceptedData;
  static RxMap<String, dynamic> get callDismissedData => WebSocketState.callDismissedData;
  static RxMap<String, dynamic> get callEndedData => WebSocketState.callEndedData;
  static RxMap<String, dynamic> get iceCandidateData => WebSocketState.iceCandidateData;

  // Live
  static StreamController<Map<String, dynamic>> get liveCommentsEvent => WebSocketState.liveCommentsEvent;
  static StreamController<Map<String, dynamic>> get superChatEvent => WebSocketState.superChatEvent;
  static StreamController<Map<String, dynamic>> get userJoinedEvent => WebSocketState.userJoinedEvent;
  static StreamController<Map<String, dynamic>> get userLeftEvent => WebSocketState.userLeftEvent;
  static RxMap<int, int> get liveViewerCounts => WebSocketState.liveViewerCounts;

  // Package
  static RxInt get packageRemainingSeconds => WebSocketState.packageRemainingSeconds;
  static RxBool get isPackageSessionTerminated => WebSocketState.isPackageSessionTerminated;

  final String _wsUrl = AppUrls.webSocketUrl;

  bool get isConnected => _isConnected;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    disconnect();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      Logger.d('[WebSocketService] App detached, disconnecting socket.');
      disconnect();
    } else if (state == AppLifecycleState.resumed) {
      if (!_isConnected && !_isConnecting) {
        Logger.d(
          '[WebSocketService] App resumed and socket disconnected, reconnecting.',
        );
        connect();
      }
    }
  }

  Future<WebSocketService> init() async {
    // If user is already logged in, connect immediately on app start
    final isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;
    if (isLoggedIn) {
      final token = await TokenManager.getToken();
      if (token != null && token.isNotEmpty) {
        connect();
      }
    }
    return this;
  }

  /// Connects the websocket if user is logged in
  Future<void> connect() async {
    if (_isConnected || _isConnecting) return;
    _isConnecting = true;

    try {
      _token = await TokenManager.getToken();

      final userDataStr = SharedPrefs.getString(AppConstants.userData);
      if (userDataStr != null && userDataStr.isNotEmpty) {
        final userModel = UserModel.fromJsonString(userDataStr);
        _userId = userModel?.id;
        currentUserId = _userId;
      }

      if (_token == null || _token!.isEmpty || _userId == null) {
        Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        Logger.e('|🔌 WEBSOCKET ERROR');
        Logger.e('|⚠️ Cannot connect, token or userId is missing.');
        Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        _isConnecting = false;
        return;
      }

      Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      Logger.d('|🔌 WEBSOCKET CONNECTING');
      Logger.d('|📍 URL: $_wsUrl');
      Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      _channel = IOWebSocketChannel.connect(
        Uri.parse(_wsUrl),
        headers: {'Origin': 'https://suryapathkundli.com'},
        pingInterval: const Duration(
          seconds: 25,
        ), // 🔥 Fix for weak networks (silent drops)
      );

      _channel?.stream.listen(
        (message) {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|📥 WEBSOCKET RECEIVED');
          Logger.d('|📨 Data: $message');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleMessage(message);
        },
        onDone: () {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|🔌 WEBSOCKET DISCONNECTED');
          Logger.d('|⚠️ Connection closed (onDone)');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _isConnecting = false;
          _isConnected = false;
          _socketId = null;
          _reconnect();
        },
        onError: (error) {
          Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.e('|🔌 WEBSOCKET ERROR');
          Logger.e('|⚠️ Exception: $error');
          Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _isConnecting = false;
          _isConnected = false;
          _socketId = null;
          _reconnect();
        },
      );
    } catch (e) {
      Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      Logger.e('|🔌 WEBSOCKET EXCEPTION');
      Logger.e('|⚠️ Exception: $e');
      Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      _isConnecting = false;
      _reconnect();
    }
  }

  void _handleMessage(dynamic message) {
    if (message is String) {
      try {
        final Map<String, dynamic> data = jsonDecode(message);
        final String? event = data['event'];

        if (event == AppUrls.pusherConnectionEstablished) {
          final String connectionDataStr = data['data'];
          final Map<String, dynamic> connectionData = jsonDecode(
            connectionDataStr,
          );
          _socketId = connectionData['socket_id'];
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|✅ WEBSOCKET ESTABLISHED');
          Logger.d('|🔗 Socket ID: $_socketId');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _isConnecting = false;
          _isConnected = true;
          _reconnectAttempts = 0;
          _startHeartbeat();
          _authenticateAndSubscribe();
        } else if (event == AppUrls.pusherSubscriptionSucceeded) {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|✅ WEBSOCKET SUBSCRIPTION SUCCESS');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        } else if (event == AppUrls.pusherPing) {
          _send(AppUrls.pusherPong);
        } else if (event == AppUrls.pusherPong) {
          _pongTimeoutTimer?.cancel();
          if (_lastPingSentAt != null) {
            WebSocketState.currentPingMs.value = DateTime.now().difference(_lastPingSentAt!).inMilliseconds;
            _lastPingSentAt = null;
          }
        } else if (event != null) {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|🔔 WEBSOCKET EVENT ROUTED: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          WebSocketEventRouter.routeEvent(event, data['data']);
        }
      } catch (e) {
        Logger.e('WebSocketService: Error parsing message -> $e');
      }
    }
  }

  Future<void> subscribeToChannel(String channelName) async {
    if (!_subscribedChannels.contains(channelName)) {
      _subscribedChannels.add(channelName);
      if (_isConnected) {
        _authenticateAndSubscribeToChannel(channelName);
      }
    }
  }

  Future<void> unsubscribeFromChannel(String channelName) async {
    if (_subscribedChannels.contains(channelName)) {
      _subscribedChannels.remove(channelName);
      if (_isConnected) {
        _send(
          jsonEncode({
            "event": "pusher:unsubscribe",
            "data": {"channel": channelName},
          }),
        );
      }
    }
  }

  Future<void> _authenticateAndSubscribe() async {
    if (_socketId == null || _userId == null) return;

    final Set<String> channelsToSubscribe = {
      AppUrls.privateUserChannel(_userId!),
      'astrologers',
      ..._subscribedChannels,
    };

    for (String channelName in channelsToSubscribe) {
      _authenticateAndSubscribeToChannel(channelName);
    }
  }

  Future<void> _authenticateAndSubscribeToChannel(String channelName) async {
    if (!channelName.startsWith('private-') &&
        !channelName.startsWith('presence-')) {
      Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      Logger.d('|✅ WEBSOCKET PUBLIC CHANNEL SUBSCRIPTION');
      Logger.d('|📺 Channel: $channelName');
      Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      _send(
        jsonEncode({
          "event": AppUrls.pusherSubscribe,
          "data": {"channel": channelName},
        }),
      );
      return;
    }

    Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    Logger.d('|🔐 WEBSOCKET AUTHENTICATING');
    Logger.d('|📺 Channel: $channelName');
    Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      final apiClient = Get.find<ApiClient>();

      final response = await apiClient.post(
        AppUrls.broadcastingAuth,
        data: {'channel_name': channelName, 'socket_id': _socketId},
        options: Options(contentType: Headers.formUrlEncodedContentType),
        handleError: false,
        showErrorScreen: false,
      );

      final authString = response.body?['auth']?.toString();
      final channelData = response.body?['channel_data'];

      if (authString != null && authString.isNotEmpty) {
        Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        Logger.d('|✅ WEBSOCKET AUTH SUCCESS');
        Logger.d('|🔑 Channel: $channelName');
        Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        final Map<String, dynamic> subscribeData = {
          "channel": channelName,
          "auth": authString,
        };
        if (channelName.startsWith('presence-') && channelData != null) {
          subscribeData["channel_data"] =
              channelData is String ? channelData : jsonEncode(channelData);
        }

        _send(
          jsonEncode({"event": AppUrls.pusherSubscribe, "data": subscribeData}),
        );
      } else {
        Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        Logger.e('|❌ WEBSOCKET AUTH FAILED');
        Logger.e('|🔑 Channel: $channelName');
        Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      }
    } catch (e) {
      Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      Logger.e('|❌ WEBSOCKET AUTH ERROR');
      Logger.e('|🔑 Channel: $channelName');
      Logger.e('|⚠️ Exception: $e');
      Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      if (_isConnected && _channel != null) {
        _sendHeartbeat();
      }
    });
  }

  void _sendHeartbeat() {
    try {
      _pongTimeoutTimer?.cancel();
      _pongTimeoutTimer = Timer(_pongTimeout, () {
        Logger.w('|⚠️ WebSocket pong timeout! Socket is unresponsive. Forcing reconnect...');
        _isConnecting = false;
        _isConnected = false;
        _socketId = null;
        _stopHeartbeat();
        _channel?.sink.close();
        _channel = null;
        _reconnect();
      });
      _lastPingSentAt = DateTime.now();
      _send(jsonEncode({"event": AppUrls.pusherPing, "data": {}}));
    } catch (e) {
      Logger.e('|⚠️ Error sending heartbeat ping: $e');
    }
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _pongTimeoutTimer?.cancel();
    _pongTimeoutTimer = null;
  }

  void _send(String data) {
    if (_channel != null && _isConnected) {
      Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      Logger.d('|📤 WEBSOCKET SENT');
      Logger.d('|📦 Data: $data');
      Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      _channel!.sink.add(data);
    }
  }

  void _reconnect() {
    if (_reconnectAttempts < 6) {
      _reconnectAttempts++;
    }
    final delaySeconds = 5 * _reconnectAttempts;

    Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    Logger.d('|⏱️ WEBSOCKET RECONNECTING');
    Logger.d('|⚠️ Attempting to reconnect in $delaySeconds seconds... (Attempt $_reconnectAttempts)');
    Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    Future.delayed(Duration(seconds: delaySeconds), () {
      connect();
    });
  }

  void disconnect() {
    Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    Logger.d('|🔌 WEBSOCKET DISCONNECTING');
    Logger.d('|⚠️ Client manually closing connection.');
    Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _isConnected = false;
    _socketId = null;
    _stopHeartbeat();
    _subscribedChannels.clear();
    _channel?.sink.close();
    _channel = null;
  }
}
