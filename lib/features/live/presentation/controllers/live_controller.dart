import 'package:get/get.dart';
import 'package:astro_astrologer/features/live/data/models/live_session_model.dart';
import 'package:astro_astrologer/features/live/presentation/controllers/live_session_controller.dart';
import 'package:astro_astrologer/features/live/presentation/controllers/live_broadcast_controller.dart';

class LiveController extends GetxController {
  LiveSessionController get _session => Get.find<LiveSessionController>();
  LiveBroadcastController get _broadcast => Get.find<LiveBroadcastController>();

  // State delegates
  RxList<LiveSessionModel> get upcomingSessions => _session.upcomingSessions;
  RxList<LiveSessionModel> get completedSessions => _session.completedSessions;
  Rx<LiveSessionModel?> get currentActiveSession => _session.currentActiveSession;
  RxList<Map<String, dynamic>> get comments => _session.comments;
  
  RxBool get isLoading => _session.isLoading;
  RxBool get isLoadingComments => _session.isLoadingComments;
  RxBool get isCreating => _broadcast.isCreating;

  bool get isRoomOpen => _session.isRoomOpen;
  set isRoomOpen(bool value) => _session.isRoomOpen = value;

  // Session & UI delegates
  Future<void> getSessions() => _session.getSessions();
  Future<void> checkCurrentActiveSession() => _session.checkCurrentActiveSession();
  void showLiveBubbleAndNotification(LiveSessionModel session) => _session.showLiveBubbleAndNotification(session);
  void stopLiveBubbleAndNotification(int sessionId) => _session.stopLiveBubbleAndNotification(sessionId);
  Future<void> fetchComments(int sessionId) => _session.fetchComments(sessionId);

  // Broadcast & API delegates
  Future<void> createSession({
    required String title,
    required String description,
    DateTime? scheduledAt,
    required String sessionType,
    required int duration,
    required int maxParticipants,
    bool isInstant = false,
  }) =>
      _broadcast.createSession(
        title: title,
        description: description,
        scheduledAt: scheduledAt,
        sessionType: sessionType,
        duration: duration,
        maxParticipants: maxParticipants,
        isInstant: isInstant,
      );

  Future<void> deleteSession(int id) => _broadcast.deleteSession(id);
  Future<void> startSession(int id) => _broadcast.startSession(id);
  Future<void> stopSession(int id) => _broadcast.stopSession(id);
  Future<void> updateSession({
    required int id,
    required String title,
    required String description,
    required DateTime scheduledAt,
    required String sessionType,
    required int duration,
    required int maxParticipants,
  }) =>
      _broadcast.updateSession(
        id: id,
        title: title,
        description: description,
        scheduledAt: scheduledAt,
        sessionType: sessionType,
        duration: duration,
        maxParticipants: maxParticipants,
      );

  Future<Map<String, dynamic>?> startBroadcast(int id) => _broadcast.startBroadcast(id);
  Future<bool> stopBroadcast(int id) => _broadcast.stopBroadcast(id);
}
