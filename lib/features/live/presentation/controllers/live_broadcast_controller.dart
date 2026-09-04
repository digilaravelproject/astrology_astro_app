import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';
import 'package:astro_astrologer/core/services/network/api_checker.dart';
import 'package:astro_astrologer/features/live/domain/usecases/live_usecases.dart';
import 'package:astro_astrologer/routes/app_routes.dart';
import 'package:astro_astrologer/features/live/presentation/controllers/live_session_controller.dart';

class LiveBroadcastController extends GetxController {
  final CreateLiveSessionUseCase _createSessionUseCase;
  final DeleteLiveSessionUseCase _deleteSessionUseCase;
  final StartLiveSessionUseCase _startSessionUseCase;
  final StopLiveSessionUseCase _stopSessionUseCase;
  final UpdateLiveSessionUseCase _updateSessionUseCase;
  final StartBroadcastUseCase _startBroadcastUseCase;
  final StopBroadcastUseCase _stopBroadcastUseCase;

  LiveBroadcastController(
    this._createSessionUseCase,
    this._deleteSessionUseCase,
    this._startSessionUseCase,
    this._stopSessionUseCase,
    this._updateSessionUseCase,
    this._startBroadcastUseCase,
    this._stopBroadcastUseCase,
  );

  final RxBool isCreating = false.obs;

  LiveSessionController get _sessionCtrl => Get.find<LiveSessionController>();

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
        await _sessionCtrl.getSessions();
        await _sessionCtrl.checkCurrentActiveSession();
        Get.back();
        if (isInstant && _sessionCtrl.currentActiveSession.value != null) {
          _sessionCtrl.isRoomOpen = true;
          Get.toNamed(
            AppRoutes.liveRoomScreen,
            arguments: _sessionCtrl.currentActiveSession.value!,
          )?.then((_) {
            _sessionCtrl.isRoomOpen = false;
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
      _sessionCtrl.isLoading.value = true;
      final result = await _deleteSessionUseCase.call(id);

      if (result.isSuccess) {
        ApiChecker.handleResponse(result, showSuccess: true);
        await _sessionCtrl.getSessions();
        await _sessionCtrl.checkCurrentActiveSession();
      } else {
        ApiChecker.handleResponse(result);
      }
    } catch (e) {
      print('[LIVE] Exception in deleteSession: $e');
      CustomSnackBar.showError('Something went wrong: $e');
    } finally {
      _sessionCtrl.isLoading.value = false;
    }
  }

  Future<void> startSession(int id) async {
    try {
      _sessionCtrl.isLoading.value = true;
      final result = await _startSessionUseCase.call(id);
      if (result.isSuccess) {
        ApiChecker.handleResponse(result, showSuccess: true);
        await _sessionCtrl.getSessions();
        await _sessionCtrl.checkCurrentActiveSession();
        if (_sessionCtrl.currentActiveSession.value != null) {
          _sessionCtrl.showLiveBubbleAndNotification(
            _sessionCtrl.currentActiveSession.value!,
          );
          _sessionCtrl.isRoomOpen = true;
          Get.toNamed(
            AppRoutes.liveRoomScreen,
            arguments: _sessionCtrl.currentActiveSession.value!,
          )?.then((_) {
            _sessionCtrl.isRoomOpen = false;
          });
        }
      } else {
        ApiChecker.handleResponse(result);
      }
    } catch (e) {
      print('[LIVE] Exception in startSession: $e');
      CustomSnackBar.showError('Something went wrong: $e');
    } finally {
      _sessionCtrl.isLoading.value = false;
    }
  }

  Future<void> stopSession(int id) async {
    try {
      _sessionCtrl.isLoading.value = true;
      final result = await _stopSessionUseCase.call(id);
      if (result.isSuccess) {
        ApiChecker.handleResponse(result, showSuccess: true);
        await _sessionCtrl.getSessions();
        await _sessionCtrl.checkCurrentActiveSession();
        _sessionCtrl.stopLiveBubbleAndNotification(id);
      } else {
        ApiChecker.handleResponse(result);
      }
    } catch (e) {
      print('[LIVE] Exception in stopSession: $e');
      CustomSnackBar.showError('Something went wrong: $e');
    } finally {
      _sessionCtrl.isLoading.value = false;
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
        await _sessionCtrl.getSessions();
        await _sessionCtrl.checkCurrentActiveSession();
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
}
