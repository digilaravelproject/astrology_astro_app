import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/usecases/set_sleep_hours_usecase.dart';
import '../../domain/usecases/get_sleep_hours_usecase.dart';
import '../../domain/models/sleep_hours_model.dart';
import '../../../../core/utils/custom_snackbar.dart';

class ScheduleController extends GetxController {
  final SetSleepHoursUseCase _setSleepHoursUseCase;
  final GetSleepHoursUseCase _getSleepHoursUseCase;

  ScheduleController(this._setSleepHoursUseCase, this._getSleepHoursUseCase);

  final isLoading = false.obs;
  final sleepHours = Rx<SleepHoursModel?>(null);

  String _formatTimeForAPI(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> setSleepHours(TimeOfDay startTime, TimeOfDay endTime) async {
    try {
      isLoading.value = true;
      
      final startTimeStr = _formatTimeForAPI(startTime);
      final endTimeStr = _formatTimeForAPI(endTime);
      
      final response = await _setSleepHoursUseCase.execute(startTimeStr, endTimeStr);
      
      if (response.isSuccess) {
        if (response.body != null) {
          sleepHours.value = SleepHoursModel.fromJson(response.body);
        }
        CustomSnackBar.showSuccess(response.message);
        Get.back();
      } else {
        CustomSnackBar.showError(response.message);
      }
    } catch (e) {
      CustomSnackBar.showError('Failed to save sleep hours');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getSleepHours() async {
    try {
      isLoading.value = true;
      
      final response = await _getSleepHoursUseCase.execute();
      
      if (response.isSuccess && response.body != null) {
        sleepHours.value = SleepHoursModel.fromJson(response.body);
      }
    } catch (e) {
      // Silently handle error for get operation
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshSleepHours() async {
    await getSleepHours();
  }

  @override
  void onInit() {
    super.onInit();
    getSleepHours();
  }
}