import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/custom_snackbar.dart';
import '../../../../core/services/network/api_checker.dart';
import '../../domain/models/live_session_model.dart';
import '../../domain/usecases/live_session_usecases.dart';

class LiveSessionController extends GetxController {
  final GetLiveSessionsUseCase _getSessionsUseCase;
  final CreateLiveSessionUseCase _createSessionUseCase;
  final DeleteLiveSessionUseCase _deleteSessionUseCase;

  LiveSessionController(
    this._getSessionsUseCase,
    this._createSessionUseCase,
    this._deleteSessionUseCase,
  );

  final RxList<LiveSessionModel> upcomingSessions = <LiveSessionModel>[].obs;
  final RxList<LiveSessionModel> completedSessions = <LiveSessionModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;

  @override
  void onInit() {
    super.onInit();
    getSessions();
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
          
          // Case 1: API returns { upcoming: { data: [...] }, completed: { data: [...] } }
          if (bodyMap.containsKey('upcoming') || bodyMap.containsKey('completed')) {
            if (bodyMap['upcoming'] is Map && bodyMap['upcoming']['data'] is List) {
              final List<dynamic> upcomingData = bodyMap['upcoming']['data'];
              allUpcoming = upcomingData.map((json) => LiveSessionModel.fromJson(json)).toList();
            }
            if (bodyMap['completed'] is Map && bodyMap['completed']['data'] is List) {
              final List<dynamic> completedData = bodyMap['completed']['data'];
              allCompleted = completedData.map((json) => LiveSessionModel.fromJson(json)).toList();
            }
          } 
          // Case 2: API returns { data: [...] }
          else if (bodyMap['data'] is List) {
            final List<dynamic> data = bodyMap['data'];
            final all = data.map((json) => LiveSessionModel.fromJson(json)).toList();
            _splitSessions(all, allUpcoming, allCompleted);
          }
        } 
        // Case 3: API returns [...] directly
        else if (result.body is List) {
          final List<dynamic> data = result.body;
          final all = data.map((json) => LiveSessionModel.fromJson(json)).toList();
          _splitSessions(all, allUpcoming, allCompleted);
        }

        upcomingSessions.value = allUpcoming;
        completedSessions.value = allCompleted;
        
        // Sort sessions
        upcomingSessions.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
        completedSessions.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
        
        print('[LIVE] Loaded ${upcomingSessions.length} upcoming and ${completedSessions.length} completed sessions');
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
    required DateTime scheduledAt,
    required String sessionType,
    required int duration,
    required int maxParticipants,
  }) async {
    try {
      isCreating.value = true;
      
      // Format: 2026-06-20 18:00:00
      final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(scheduledAt);
      
      final data = {
        'title': title,
        'description': description,
        'scheduled_at': formattedDate,
        'session_type': sessionType,
        'duration_minutes': duration,
        'max_participants': maxParticipants,
      };

      final result = await _createSessionUseCase.call(data);
      
      if (result.isSuccess) {
        ApiChecker.handleResponse(result, showSuccess: true);
        await getSessions();
        Get.back(); // Close bottom sheet
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
  void _splitSessions(List<LiveSessionModel> all, List<LiveSessionModel> upcoming, List<LiveSessionModel> completed) {
    final now = DateTime.now();
    for (var session in all) {
      if (session.scheduledAt.isAfter(now)) {
        upcoming.add(session);
      } else {
        completed.add(session);
      }
    }
  }
}
