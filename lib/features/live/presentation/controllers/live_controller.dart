import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';
import 'package:astro_astrologer/core/services/network/api_checker.dart';
import 'package:astro_astrologer/core/services/local_notification_service.dart';
import 'package:astro_astrologer/features/live/data/models/live_session_model.dart';
import 'package:astro_astrologer/features/live/domain/usecases/live_usecases.dart';
import 'package:astro_astrologer/core/constants/app_constants.dart';
import 'package:astro_astrologer/core/services/storage/shared_prefs.dart';
import 'package:astro_astrologer/features/live/presentation/pages/live_room_screen.dart';

class LiveController extends GetxController {
  final GetLiveSessionsUseCase _getSessionsUseCase;
  final GetCurrentLiveSessionUseCase _getCurrentSessionUseCase;
  final CreateLiveSessionUseCase _createSessionUseCase;
  final DeleteLiveSessionUseCase _deleteSessionUseCase;
  final StartLiveSessionUseCase _startSessionUseCase;
  final StopLiveSessionUseCase _stopSessionUseCase;
  final UpdateLiveSessionUseCase _updateSessionUseCase;
  final StartBroadcastUseCase _startBroadcastUseCase;
  final StopBroadcastUseCase _stopBroadcastUseCase;
  final GetLiveCommentsUseCase _getCommentsUseCase;

  LiveController(
    this._getSessionsUseCase,
    this._getCurrentSessionUseCase,
    this._createSessionUseCase,
    this._deleteSessionUseCase,
    this._startSessionUseCase,
    this._stopSessionUseCase,
    this._updateSessionUseCase,
    this._startBroadcastUseCase,
    this._stopBroadcastUseCase,
    this._getCommentsUseCase,
  );

  final RxList<LiveSessionModel> upcomingSessions = <LiveSessionModel>[].obs;
  final RxList<LiveSessionModel> completedSessions = <LiveSessionModel>[].obs;
  final Rx<LiveSessionModel?> currentActiveSession = Rx<LiveSessionModel?>(
    null,
  );
  final RxList<Map<String, dynamic>> comments = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool isLoadingComments = false.obs;

  bool isRoomOpen = false;

  @override
  void onInit() {
    super.onInit();
    final isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;
    if (isLoggedIn) {
      getSessions();
      checkCurrentActiveSession();
    }
  }

  void showLiveBubbleAndNotification(LiveSessionModel session) {
    if (Get.context != null) {
      LocalNotificationService.showOngoingLiveNotification(
        sessionId: session.id,
        title: 'Live Session in Progress',
        body: 'Ongoing session: ${session.title}',
        startedAtMillis: session.startedAt?.millisecondsSinceEpoch,
      );
    }
  }

  void stopLiveBubbleAndNotification(int sessionId) {
    LocalNotificationService.cancelOngoingLiveNotification(sessionId);
  }

  Future<void> checkCurrentActiveSession() async {
    try {
      final result = await _getCurrentSessionUseCase.call();
      if (result.isSuccess && result.body != null) {
        final bodyMap = result.body as Map<String, dynamic>;
        Map<String, dynamic>? sessionData;

        if (bodyMap.containsKey('id') && bodyMap['id'] != null) {
          sessionData = bodyMap;
        } else if (bodyMap['data'] is Map<String, dynamic>) {
          sessionData = bodyMap['data'];
        } else if (bodyMap['message'] is Map<String, dynamic>) {
          sessionData = bodyMap['message'];
        }

        if (sessionData != null && sessionData['status'] == 'ongoing') {
          final session = LiveSessionModel.fromJson(sessionData);
          currentActiveSession.value = session;
          print('[LIVE] Active ongoing session found: ${session.title}');
          showLiveBubbleAndNotification(session);

          if (!isRoomOpen) {
            isRoomOpen = true;
            Get.to(() => LiveRoomScreen(session: session))?.then((_) {
              isRoomOpen = false;
            });
          }
        } else {
          if (currentActiveSession.value != null) {
            stopLiveBubbleAndNotification(currentActiveSession.value!.id);
          }
          currentActiveSession.value = null;
        }
      }
    } catch (e) {
      print('[LIVE] Exception in checkCurrentActiveSession: $e');
    }
  }

  Future<void> getSessions() async {
    try {
      isLoading.value = true;
      print('[LIVE] Getting all sessions...');
      final result = await _getSessionsUseCase.call(filter: 'all');

      if (result.isSuccess) {
        List<LiveSessionModel> allUpcoming = [];
        List<LiveSessionModel> allCompleted = [];

        if (result.body is Map) {
          final bodyMap = result.body as Map<String, dynamic>;

          if (bodyMap.containsKey('upcoming') ||
              bodyMap.containsKey('completed')) {
            if (bodyMap['upcoming'] is Map &&
                bodyMap['upcoming']['data'] is List) {
              final List<dynamic> upcomingData = bodyMap['upcoming']['data'];
              allUpcoming =
                  upcomingData
                      .map((json) => LiveSessionModel.fromJson(json))
                      .toList();
            }
            if (bodyMap['completed'] is Map &&
                bodyMap['completed']['data'] is List) {
              final List<dynamic> completedData = bodyMap['completed']['data'];
              allCompleted =
                  completedData
                      .map((json) => LiveSessionModel.fromJson(json))
                      .toList();
            }
          } else if (bodyMap['data'] is List) {
            final List<dynamic> data = bodyMap['data'];
            final all =
                data.map((json) => LiveSessionModel.fromJson(json)).toList();
            _splitSessions(all, allUpcoming, allCompleted);
          }
        } else if (result.body is List) {
          final List<dynamic> data = result.body;
          final all =
              data.map((json) => LiveSessionModel.fromJson(json)).toList();
          _splitSessions(all, allUpcoming, allCompleted);
        }

        upcomingSessions.value = allUpcoming;
        completedSessions.value = allCompleted;

        upcomingSessions.sort((a, b) {
          if (a.status == 'ongoing' && b.status != 'ongoing') return -1;
          if (b.status == 'ongoing' && a.status != 'ongoing') return 1;
          return a.scheduledAt.compareTo(b.scheduledAt);
        });
        completedSessions.sort(
          (a, b) => b.scheduledAt.compareTo(a.scheduledAt),
        );

        print(
          '[LIVE] Loaded ${upcomingSessions.length} upcoming and ${completedSessions.length} completed sessions',
        );
      } else {
        ApiChecker.handleResponse(result);
      }
    } catch (e) {
      print('[LIVE] Exception in getSessions: $e');
      CustomSnackBar.showError('Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createSession({
    required String title,
    required String description,
    DateTime? scheduledAt,
    required String sessionType,
    required int duration,
    required int maxParticipants,
    bool isInstant = false,
  }) async {
    try {
      isCreating.value = true;

      final Map<String, dynamic> data = {
        'title': title,
        'description': description,
        'session_type': sessionType,
        'duration_minutes': duration,
        'max_participants': maxParticipants,
      };

      if (isInstant) {
        data['is_instant'] = true;
      } else if (scheduledAt != null) {
        data['scheduled_at'] = DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).format(scheduledAt);
      }

      final result = await _createSessionUseCase.call(data);

      if (result.isSuccess) {
        ApiChecker.handleResponse(result, showSuccess: true);
        await getSessions();
        await checkCurrentActiveSession();
        Get.back();
        if (isInstant && currentActiveSession.value != null) {
          isRoomOpen = true;
          Get.to(
            () => LiveRoomScreen(session: currentActiveSession.value!),
          )?.then((_) {
            isRoomOpen = false;
          });
        }
      } else {
        ApiChecker.handleResponse(result);
      }
    } catch (e) {
      print('[LIVE] Exception in createSession: $e');
      CustomSnackBar.showError('Something went wrong: $e');
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> deleteSession(int id) async {
    try {
      isLoading.value = true;
      final result = await _deleteSessionUseCase.call(id);

      if (result.isSuccess) {
        ApiChecker.handleResponse(result, showSuccess: true);
        await getSessions();
        await checkCurrentActiveSession();
      } else {
        ApiChecker.handleResponse(result);
      }
    } catch (e) {
      print('[LIVE] Exception in deleteSession: $e');
      CustomSnackBar.showError('Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startSession(int id) async {
    try {
      isLoading.value = true;
      final result = await _startSessionUseCase.call(id);
      if (result.isSuccess) {
        ApiChecker.handleResponse(result, showSuccess: true);
        await getSessions();
        await checkCurrentActiveSession();
        if (currentActiveSession.value != null) {
          showLiveBubbleAndNotification(currentActiveSession.value!);
          isRoomOpen = true;
          Get.to(
            () => LiveRoomScreen(session: currentActiveSession.value!),
          )?.then((_) {
            isRoomOpen = false;
          });
        }
      } else {
        ApiChecker.handleResponse(result);
      }
    } catch (e) {
      print('[LIVE] Exception in startSession: $e');
      CustomSnackBar.showError('Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> stopSession(int id) async {
    try {
      isLoading.value = true;
      final result = await _stopSessionUseCase.call(id);
      if (result.isSuccess) {
        ApiChecker.handleResponse(result, showSuccess: true);
        await getSessions();
        await checkCurrentActiveSession();
        stopLiveBubbleAndNotification(id);
      } else {
        ApiChecker.handleResponse(result);
      }
    } catch (e) {
      print('[LIVE] Exception in stopSession: $e');
      CustomSnackBar.showError('Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSession({
    required int id,
    required String title,
    required String description,
    required DateTime scheduledAt,
    required String sessionType,
    required int duration,
    required int maxParticipants,
  }) async {
    try {
      isCreating.value = true;
      final formattedDate = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(scheduledAt);
      final data = {
        'title': title,
        'description': description,
        'scheduled_at': formattedDate,
        'session_type': sessionType,
        'duration_minutes': duration,
        'max_participants': maxParticipants,
      };
      final result = await _updateSessionUseCase.call(id, data);
      if (result.isSuccess) {
        ApiChecker.handleResponse(result, showSuccess: true);
        await getSessions();
        await checkCurrentActiveSession();
        Get.back();
      } else {
        ApiChecker.handleResponse(result);
      }
    } catch (e) {
      print('[LIVE] Exception in updateSession: $e');
      CustomSnackBar.showError('Something went wrong: $e');
    } finally {
      isCreating.value = false;
    }
  }

  void _splitSessions(
    List<LiveSessionModel> all,
    List<LiveSessionModel> upcoming,
    List<LiveSessionModel> completed,
  ) {
    for (var session in all) {
      if (session.status == 'completed') {
        completed.add(session);
      } else {
        upcoming.add(session);
      }
    }
  }

  Future<Map<String, dynamic>?> startBroadcast(int id) async {
    try {
      final result = await _startBroadcastUseCase.call(id);
      if (result.isSuccess && result.body != null) {
        final dynamic body = result.body;
        if (body is Map<String, dynamic>) {
          if (body['data'] is Map<String, dynamic>) {
            return body['data'];
          }
          return body;
        }
      } else {
        ApiChecker.handleResponse(result);
      }
    } catch (e) {
      print('[LIVE] Exception in startBroadcast: $e');
    }
    return null;
  }

  Future<bool> stopBroadcast(int id) async {
    try {
      final result = await _stopBroadcastUseCase.call(id);
      if (result.isSuccess) {
        return true;
      } else {
        ApiChecker.handleResponse(result);
      }
    } catch (e) {
      print('[LIVE] Exception in stopBroadcast: $e');
    }
    return false;
  }

  Future<void> fetchComments(int sessionId) async {
    try {
      isLoadingComments.value = true;
      final result = await _getCommentsUseCase.call(sessionId);
      if (result.isSuccess && result.body != null) {
        final List<dynamic> data;
        if (result.body is List) {
          data = result.body;
        } else if (result.body is Map) {
          final dynamic rawData = result.body['data'];
          if (rawData is List) {
            data = rawData;
          } else if (rawData is Map && rawData['data'] is List) {
            data = rawData['data'];
          } else {
            data = [];
          }
        } else {
          data = [];
        }
        comments.value = List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      print('[LIVE] Error fetching comments: $e');
    } finally {
      isLoadingComments.value = false;
    }
  }
}
