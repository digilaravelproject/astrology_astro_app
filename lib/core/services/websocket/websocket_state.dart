import 'dart:async';
import 'package:get/get.dart';

/// Single source of truth for all WebSocket-driven reactive state.
///
/// Previously these were `static` members on [WebSocketService] directly.
/// Extracting them here makes them importable independently — controllers
/// no longer need to import the full WebSocketService just to read state.
class WebSocketState {
  WebSocketState._(); // prevent instantiation

  // ─── Session Meta ──────────────────────────────────────────────────────────
  /// ID of the chat/call session currently in focus (active on screen).
  static int? activeSessionId;

  /// Logged-in user's ID — set on WebSocket connect.
  static int? currentUserId;

  /// Maps sessionId → ISO-8601 start timestamp (used for timer sync).
  static final Map<int, String> sessionStartTimes = {};

  // ─── Chat State ────────────────────────────────────────────────────────────
  /// Maps sessionId → current status string (e.g. 'ongoing', 'accepted').
  static final RxMap<int, String> sessionStatusUpdates = <int, String>{}.obs;

  /// Incoming chat messages from WebSocket (MessageSent event).
  static final RxList<Map<String, dynamic>> incomingMessages =
      <Map<String, dynamic>>[].obs;

  /// Message delivered/seen status updates from WebSocket.
  static final RxList<Map<String, dynamic>> messageStatusUpdates =
      <Map<String, dynamic>>[].obs;

  /// Presence (online/offline) updates per user.
  static final RxList<Map<String, dynamic>> presenceUpdates =
      <Map<String, dynamic>>[].obs;

  /// Signal: emits sessionId when a chat session ends remotely.
  static final RxInt chatEndedSessionId = (-1).obs;

  /// Signal: emits sessionId when a chat is dismissed/timed out.
  static final RxInt chatDismissedSessionId = (-1).obs;

  /// Billing payload received with ChatEnded event.
  static final RxMap<String, dynamic> chatEndedBilling =
      <String, dynamic>{}.obs;

  /// Broadcast stream: emits full ChatInitiated payload.
  static final StreamController<Map<String, dynamic>> chatInitiatedEvent =
      StreamController.broadcast();

  /// Broadcast stream: emits ChatQueueUpdated payload.
  static final StreamController<Map<String, dynamic>> chatQueueUpdatedEvent =
      StreamController.broadcast();

  /// Last sender data from ChatInitiated event (used as fallback in bubble).
  static Map<String, dynamic>? lastChatSenderData;

  // ─── Call State ────────────────────────────────────────────────────────────
  /// Maps sessionId → call status string (e.g. 'ongoing', 'ringing').
  static final RxMap<int, String> callSessionStatusUpdates =
      <int, String>{}.obs;

  /// Signal: emits sessionId when a call session ends remotely.
  static final RxInt callEndedSessionId = (-1).obs;

  /// Signal: emits sessionId when a call is dismissed/missed.
  static final RxInt callDismissedSessionId = (-1).obs;

  /// Broadcast stream: emits full CallInitiated payload.
  static final StreamController<Map<String, dynamic>> callInitiatedEvent =
      StreamController.broadcast();

  /// CallAccepted event payload (contains answer SDP).
  static final RxMap<String, dynamic> callAcceptedData =
      <String, dynamic>{}.obs;

  /// CallDismissed event payload.
  static final RxMap<String, dynamic> callDismissedData =
      <String, dynamic>{}.obs;

  /// CallEnded event payload.
  static final RxMap<String, dynamic> callEndedData = <String, dynamic>{}.obs;

  /// WebRTC ICE candidate payload from IceCandidateSent event.
  static final RxMap<String, dynamic> iceCandidateData =
      <String, dynamic>{}.obs;

  // ─── Live Session State ────────────────────────────────────────────────────
  /// Broadcast stream: live comments received.
  static final StreamController<Map<String, dynamic>> liveCommentsEvent =
      StreamController.broadcast();

  /// Broadcast stream: super-chat events.
  static final StreamController<Map<String, dynamic>> superChatEvent =
      StreamController.broadcast();

  /// Broadcast stream: user joined live session.
  static final StreamController<Map<String, dynamic>> userJoinedEvent =
      StreamController.broadcast();

  /// Broadcast stream: user left live session.
  static final StreamController<Map<String, dynamic>> userLeftEvent =
      StreamController.broadcast();

  /// Maps liveSessionId → current viewer count.
  static final RxMap<int, int> liveViewerCounts = <int, int>{}.obs;

  // ─── Prepaid Package State ─────────────────────────────────────────────────
  /// Remaining seconds in the active prepaid package session.
  static final RxInt packageRemainingSeconds = 0.obs;

  /// True when the backend terminates a package session (balance exhausted).
  static final RxBool isPackageSessionTerminated = false.obs;
}
