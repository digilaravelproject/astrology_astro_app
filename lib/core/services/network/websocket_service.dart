import 'package:astro_astrologer/core/services/local_notification_service.dart';
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../storage/token_manger.dart';
import '../storage/shared_prefs.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/auth/domain/models/user_model.dart';
import 'api_client.dart';
import '../../../features/chat/presentation/widgets/incoming_chat_dialog.dart';
import '../../../core/constants/app_urls.dart';
import '../../utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:astro_astrologer/features/chat/presentation/widgets/chat_summary_dialog.dart';
import 'package:astro_astrologer/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_astrologer/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_astrologer/features/chat/presentation/controllers/chat_controller.dart';
import 'package:astro_astrologer/features/chat/domain/usecases/sync_message_status_usecase.dart';

class WebSocketService extends GetxService {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  String? _socketId;
  int? _userId;
  String? _token;
  
  static int? activeSessionId;
  static final RxMap<int, String> sessionStatusUpdates = <int, String>{}.obs;
  static int? currentUserId;
  static final RxList<Map<String, dynamic>> incomingMessages = <Map<String, dynamic>>[].obs;
  static final RxList<Map<String, dynamic>> messageStatusUpdates = <Map<String, dynamic>>[].obs;
  static final RxList<Map<String, dynamic>> presenceUpdates = <Map<String, dynamic>>[].obs;
  static final RxMap<int, String> sessionStartTimes = <int, String>{}.obs;
  // Signal: when set to a sessionId, that chat session has been ended remotely
  static final RxInt chatEndedSessionId = (-1).obs;
  static final RxInt chatDismissedSessionId = (-1).obs;
  static final StreamController<Map<String, dynamic>> chatInitiatedEvent = StreamController.broadcast();
  static final StreamController<Map<String, dynamic>> chatQueueUpdatedEvent = StreamController.broadcast();
  static final RxMap<String, dynamic> chatEndedBilling = <String, dynamic>{}.obs;

  // Call System State
  static final RxMap<int, String> callSessionStatusUpdates = <int, String>{}.obs;
  static final RxInt callEndedSessionId = (-1).obs;
  static final RxInt callDismissedSessionId = (-1).obs;
  static final StreamController<Map<String, dynamic>> callInitiatedEvent = StreamController.broadcast();
  static final RxMap<String, dynamic> callDismissedData = <String, dynamic>{}.obs;
  static final RxMap<String, dynamic> callAcceptedData = <String, dynamic>{}.obs;
  static final RxMap<String, dynamic> callEndedData = <String, dynamic>{}.obs;
  static final RxMap<String, dynamic> iceCandidateData = <String, dynamic>{}.obs;

  final String _wsUrl = AppUrls.webSocketUrl;
  
  bool get isConnected => _isConnected;

  Future<WebSocketService> init() async {
    // If user is already logged in, connect immediately on app start
    final token = await TokenManager.getToken();
    if (token != null && token.isNotEmpty) {
      connect();
    }
    return this;
  }

  /// Connects the websocket if user is logged in
  Future<void> connect() async {
    if (_isConnected) return;

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
        return;
      }

      Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      Logger.d('|🔌 WEBSOCKET CONNECTING');
      Logger.d('|📍 URL: $_wsUrl');
      Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      
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
          _isConnected = false;
          _reconnect();
        },
        onError: (error) {
          Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.e('|🔌 WEBSOCKET ERROR');
          Logger.e('|⚠️ Exception: $error');
          Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _isConnected = false;
          _reconnect();
        },
      );
    } catch (e) {
      Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      Logger.e('|🔌 WEBSOCKET EXCEPTION');
      Logger.e('|⚠️ Exception: $e');
      Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
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
          final Map<String, dynamic> connectionData = jsonDecode(connectionDataStr);
          _socketId = connectionData['socket_id'];
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|✅ WEBSOCKET ESTABLISHED');
          Logger.d('|🔗 Socket ID: $_socketId');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _isConnected = true;
          _authenticateAndSubscribe();
        } else if (event == AppUrls.pusherSubscriptionSucceeded) {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|✅ WEBSOCKET SUBSCRIPTION SUCCESS');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        } else if (event == AppUrls.eventChatAccepted) {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|🔔 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleChatAccepted(data['data']);
        } else if (event == AppUrls.eventChatEnded) {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|🔔 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleChatEnded(data['data']);
        } else if (event == AppUrls.eventChatDismissed) {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|🔔 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleChatDismissed(data['data']);
        } else if (event == AppUrls.eventMessageSent || event == 'App\\Events\\MessageSent') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|🔔 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleMessageSent(data['data']);
        } else if (event == AppUrls.eventChatInitiated || event == 'App\\Events\\ChatInitiated') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|🔔 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleChatInitiated(data['data']);
        } else if (event == AppUrls.eventChatQueueUpdated || event == 'App\\Events\\ChatQueueUpdated') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|🔔 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          chatQueueUpdatedEvent.add(data['data'] ?? {});
        } else if (event == AppUrls.eventMessageStatusUpdated || event == 'App\\Events\\MessageStatusUpdated') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|🔔 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleMessageStatusUpdated(data['data']);
        } else if (event == AppUrls.eventPresenceUpdated || event == 'App\\Events\\PresenceUpdated') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|🔔 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handlePresenceUpdated(data['data']);
        } else if (event == AppUrls.eventChatDismissed || event == 'App\\Events\\ChatDismissed') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|🔔 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleChatDismissed(data['data']);
        } else if (event == AppUrls.eventCallInitiated || event == 'App\\Events\\CallInitiated') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|📞 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleCallInitiated(data['data']);
        } else if (event == AppUrls.eventCallAccepted || event == 'App\\Events\\CallAccepted') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|📞 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleCallAccepted(data['data']);
        } else if (event == AppUrls.eventCallDismissed || event == 'App\\Events\\CallDismissed') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|📞 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleCallDismissed(data['data']);
        } else if (event == AppUrls.eventCallEnded || event == 'App\\Events\\CallEnded') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|📞 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleCallEnded(data['data']);
        } else if (event == AppUrls.eventIceCandidateSent || event == 'App\\Events\\IceCandidateSent') {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|📞 WEBSOCKET EVENT: $event');
          Logger.d('|📦 Data: ${data['data']}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _handleIceCandidateSent(data['data']);
        } else if (event == AppUrls.pusherPing) {
           _send(AppUrls.pusherPong);
        }
      } catch (e) {
        debugPrint('WebSocketService: Error parsing message -> $e');
      }
    }
  }

  Future<void> _authenticateAndSubscribe() async {
    if (_socketId == null || _userId == null) return;

    final List<String> channelsToSubscribe = [
      AppUrls.privateUserChannel(_userId!),
      AppUrls.presenceRoomChannel,
    ];

    for (String channelName in channelsToSubscribe) {
      Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      Logger.d('|🔐 WEBSOCKET AUTHENTICATING');
      Logger.d('|📺 Channel: $channelName');
      Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      try {
        final apiClient = Get.find<ApiClient>();
        
        final response = await apiClient.post(
          AppUrls.broadcastingAuth,
          data: {
            'channel_name': channelName,
            'socket_id': _socketId,
          },
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
          ),
          handleError: false,
          showErrorScreen: false,
        );

        // broadcasting/auth returns {"auth": "..."} not standard format
        // so check body['auth'] directly, not response.isSuccess
        final authString = response.body?['auth']?.toString();
        
        if (authString != null && authString.isNotEmpty) {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|✅ WEBSOCKET AUTH SUCCESS');
          Logger.d('|🔑 Channel: $channelName');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

          _send(jsonEncode({
            "event": AppUrls.pusherSubscribe,
            "data": {
              "channel": channelName,
              "auth": authString
            }
          }));
        } else {
          Logger.e('|❌ WEBSOCKET AUTH FAILED for $channelName, body=${response.body}');
        }
      } catch (e) {
        Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        Logger.e('|❌ WEBSOCKET AUTH EXCEPTION');
        Logger.e('|⚠️ Channel: $channelName, Error: $e');
        Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      }
    }
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
    Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    Logger.d('|⏱️ WEBSOCKET RECONNECTING');
    Logger.d('|⚠️ Attempting to reconnect in 5 seconds...');
    Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    Future.delayed(const Duration(seconds: 5), () {
      connect();
    });
  }

  void disconnect() {
    Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    Logger.d('|🔌 WEBSOCKET DISCONNECTING');
    Logger.d('|⚠️ Client manually closing connection.');
    Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _isConnected = false;
    _channel?.sink.close();
    _channel = null;
  }

  void _handleChatInitiated(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      Logger.d('_handleChatInitiated: eventData keys = ${eventData.keys}');
      
      final session = eventData['session'];
      final senderData = eventData['senderData'];
      
      Logger.d('_handleChatInitiated: session=$session, senderData=$senderData');

      if (session != null && senderData != null) {
        chatInitiatedEvent.add(Map<String, dynamic>.from(session));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.dialog(
            IncomingChatDialog(
              sessionData: Map<String, dynamic>.from(session),
              senderData: Map<String, dynamic>.from(senderData),
            ),
            barrierDismissible: false,
          );
        });
      } else {
        Logger.e('_handleChatInitiated: session or senderData is null! rawData=$rawData');
      }
    } catch (e) {
      Logger.e('Error handling ChatInitiated: $e');
    }
  }

  void _handleChatAccepted(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final session = eventData['session'];
      if (session == null) return;

      final int sessionId = session['id'] is int 
          ? session['id'] 
          : (int.tryParse(session['id']?.toString() ?? '') ?? 0);
      final String? startedAt = session['started_at']?.toString();
      if (startedAt != null) {
        sessionStartTimes[sessionId] = startedAt;
      }
      sessionStatusUpdates[sessionId] = 'ongoing';
      sessionStatusUpdates.refresh();

      // Update FloatingChatBubble status directly!
      if (FloatingChatBubble.isActive && FloatingChatBubble.sessionId == sessionId) {
        FloatingChatBubble.updateStatus('ongoing');

        // Show ongoing local notification since user minimized the chat and it just started!
        int? startedAtMillis;
        if (startedAt != null) {
          final parsedDate = DateTime.tryParse(startedAt);
          if (parsedDate != null) {
            startedAtMillis = parsedDate.millisecondsSinceEpoch;
          }
        }
        LocalNotificationService.showOngoingChatNotification(
          sessionId: sessionId,
          title: 'Chat in progress',
          body: 'Active chat with ${FloatingChatBubble.name ?? "Astrologer"}',
          startedAtMillis: startedAtMillis,
        );
      }

      // Update ChatController directly if registered
      if (Get.isRegistered<ChatController>()) {
        final controller = Get.find<ChatController>();
        if (controller.sessionId == sessionId) {
          controller.status.value = 'ongoing';
        }
      }
    } catch (e) {
      Logger.e('WebSocketService: error handling ChatAccepted -> $e');
    }
  }

  void _handleChatEnded(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final session = eventData['session'];
      if (session == null) return;

      final int sessionId = session['id'] is int 
          ? session['id'] 
          : (int.tryParse(session['id']?.toString() ?? '') ?? 0);
      final int durationSeconds = session['duration_seconds'] is int 
          ? session['duration_seconds'] 
          : (int.tryParse(session['duration_seconds']?.toString() ?? '') ?? 0);
      final double totalCost = double.tryParse(session['total_cost']?.toString() ?? '') ?? 0.0;

      Logger.d('WebSocketService: ChatEnded for sessionId=$sessionId, active=$activeSessionId');

      // Cancel notification
      LocalNotificationService.cancelOngoingChatNotification(sessionId);

      // If the chat screen is open (active), signal it to close
      if (activeSessionId == sessionId) {
        activeSessionId = null;
        // Emit signal — ChatScreen listens and closes itself
        chatEndedSessionId.value = sessionId;
        // Show summary after brief delay to allow screen pop
        Future.delayed(const Duration(milliseconds: 300), () {
          ChatSummaryDialog.show(
            sessionId: sessionId,
            durationSeconds: durationSeconds,
            totalCost: totalCost,
          );
        });
      } else if (FloatingChatBubble.isActive && FloatingChatBubble.sessionId == sessionId) {
        // Chat is minimized as a bubble
        FloatingChatBubble.dismiss();
        chatEndedSessionId.value = sessionId;
        ChatSummaryDialog.show(
          sessionId: sessionId,
          durationSeconds: durationSeconds,
          totalCost: totalCost,
        );
      }
    } catch (e) {
      Logger.e('WebSocketService: error handling ChatEnded -> $e');
    }
  }

  void _handleChatDismissed(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final session = eventData['session'];
      if (session == null) return;

      final int sessionId = session['id'];
      Logger.d('WebSocketService: ChatDismissed for sessionId=$sessionId');

      // Cancel notification
      LocalNotificationService.cancelOngoingChatNotification(sessionId);

      // Dismiss floating bubble if active
      if (FloatingChatBubble.isActive && FloatingChatBubble.sessionId == sessionId) {
        FloatingChatBubble.dismiss();
      }

      // Propagate the ended/dismissed status so ChatScreen / ChatController can react
      sessionStatusUpdates[sessionId] = 'ended';
      sessionStatusUpdates.refresh();

      // Always signal that this session was dismissed
      chatDismissedSessionId.value = sessionId;

      // If active screen is open, clear it
      if (activeSessionId == sessionId) {
        activeSessionId = null;
      }
    } catch (e) {
      Logger.e('WebSocketService: error handling ChatDismissed -> $e');
    }
  }

  void _handleMessageSent(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final messageData = eventData['messageData'];
      if (messageData != null) {
        final map = Map<String, dynamic>.from(messageData);
        incomingMessages.add(map);

        final int senderId = int.tryParse(map['sender_id']?.toString() ?? '') ?? 0;
        final int sessionId = int.tryParse(map['chat_session_id']?.toString() ?? '') ?? 0;

        if (senderId != currentUserId && activeSessionId != sessionId) {
          if (FloatingChatBubble.isActive && FloatingChatBubble.sessionId == sessionId) {
            FloatingChatBubble.incrementUnreadCount();
          }
          _showInAppNotification(map);
          
          final int messageId = int.tryParse(map['id']?.toString() ?? '') ?? 0;
          if (messageId > 0 && Get.isRegistered<SyncMessageStatusUseCase>()) {
            Get.find<SyncMessageStatusUseCase>().execute(
              sessionId: sessionId,
              messageIds: [messageId],
              status: 'delivered',
            ).catchError((e) {
              debugPrint('Error syncing message status: $e');
            });
          }
        }
      }
    } catch (e) {
      Logger.e('WebSocketService: error handling MessageSent -> $e');
    }
  }

  void _showInAppNotification(Map<String, dynamic> msg) {
    final int sessionId = int.tryParse(msg['chat_session_id']?.toString() ?? '') ?? 0;
    final String text = msg['message'] ?? 'Sent an attachment';
    
    try {
      Get.snackbar(
        'New Message',
        text,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        colorText: const Color(0xFF2E1A47),
        icon: const Icon(Icons.message, color: Color(0xFFFF6F00)),
        boxShadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        duration: const Duration(seconds: 4),
        onTap: (_) {
          Get.to(() => ChatScreen(
            userName: "User",
            userImage: "",
            sessionId: sessionId,
            initialStatus: 'ongoing',
          ));
        },
      );
    } catch (e) {
      Logger.e('WebSocketService: error showing snackbar -> $e');
    }
  }

  void _handleMessageStatusUpdated(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      messageStatusUpdates.add(eventData);
    } catch (e) {
      Logger.e('WebSocketService: error handling MessageStatusUpdated -> $e');
    }
  }

  void _handlePresenceUpdated(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      presenceUpdates.add(eventData);
    } catch (e) {
      Logger.e('WebSocketService: error handling PresenceUpdated -> $e');
    }
  }

  void _handleCallInitiated(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }

      final session = eventData['session'];
      final callerData = eventData['callerData'];

      if (session != null && callerData != null) {
        final sessionMap = Map<String, dynamic>.from(session);
        final callerMap = Map<String, dynamic>.from(callerData);
        callInitiatedEvent.add({
          'session': sessionMap,
          'callerData': callerMap,
        });
      }
    } catch (e) {
      Logger.e('WebSocketService: error handling CallInitiated -> $e');
    }
  }

  void _handleCallAccepted(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      final session = eventData['session'];
      if (session != null) {
        final int sessionId = session['id'] is int 
            ? session['id'] 
            : (int.tryParse(session['id']?.toString() ?? '') ?? 0);
        callSessionStatusUpdates[sessionId] = 'ongoing';
        callSessionStatusUpdates.refresh();
      }
      callAcceptedData.value = eventData;
      callAcceptedData.refresh();
    } catch (e) {
      Logger.e('WebSocketService: error handling CallAccepted -> $e');
    }
  }

  void _handleCallDismissed(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      final session = eventData['session'];
      if (session != null) {
        final int sessionId = session['id'] is int 
            ? session['id'] 
            : (int.tryParse(session['id']?.toString() ?? '') ?? 0);
        final String? reason = eventData['reason']?.toString();
        callSessionStatusUpdates[sessionId] = reason ?? 'dismissed';
        callSessionStatusUpdates.refresh();
        callDismissedSessionId.value = sessionId;
      }
      callDismissedData.value = eventData;
      callDismissedData.refresh();
    } catch (e) {
      Logger.e('WebSocketService: error handling CallDismissed -> $e');
    }
  }

  void _handleCallEnded(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      final session = eventData['session'];
      if (session != null) {
        final int sessionId = session['id'] is int 
            ? session['id'] 
            : (int.tryParse(session['id']?.toString() ?? '') ?? 0);
        callSessionStatusUpdates[sessionId] = 'completed';
        callSessionStatusUpdates.refresh();
        callEndedSessionId.value = sessionId;
      }
      callEndedData.value = eventData;
      callEndedData.refresh();
    } catch (e) {
      Logger.e('WebSocketService: error handling CallEnded -> $e');
    }
  }

  void _handleIceCandidateSent(dynamic rawData) {
    try {
      Map<String, dynamic> eventData = {};
      if (rawData is String) {
        eventData = jsonDecode(rawData);
      } else if (rawData is Map) {
        eventData = Map<String, dynamic>.from(rawData);
      }
      iceCandidateData.value = eventData;
      iceCandidateData.refresh();
    } catch (e) {
      Logger.e('WebSocketService: error handling IceCandidateSent -> $e');
    }
  }
}
