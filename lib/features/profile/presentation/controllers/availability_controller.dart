import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/availability_model.dart';
import '../../domain/usecases/get_availability_usecase.dart';
import '../../domain/usecases/update_availability_usecase.dart';

class AvailabilityController extends GetxController {
  final GetAvailabilityUseCase _getAvailabilityUseCase;
  final UpdateAvailabilityUseCase _updateAvailabilityUseCase;

  AvailabilityController(
    this._getAvailabilityUseCase,
    this._updateAvailabilityUseCase,
  );

  final RxList<AvailabilityModel> availability = <AvailabilityModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    getAvailability();
  }

  Future<void> getAvailability() async {
    try {
      isLoading.value = true;
      print('[AVAILABILITY] Getting availability...');
      final result = await _getAvailabilityUseCase.call();
      print('[AVAILABILITY] Get availability result: ${result.toString()}');

      if (result.isSuccess) {
        final List<dynamic> data = result.body['availability'] ?? [];
        availability.value = data.map((json) => AvailabilityModel.fromJson(json)).toList();
        print('[AVAILABILITY] Loaded ${availability.length} availability records');
      } else {
        print('[AVAILABILITY] Failed to get availability: ${result.message}');
        Get.snackbar(
          'Error',
          result.message ?? 'Failed to fetch availability',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      print('[AVAILABILITY] Exception in getAvailability: $e');
      Get.snackbar(
        'Error',
        'Something went wrong: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateAvailability(List<AvailabilityModel> updatedAvailability) async {
    try {
      isSaving.value = true;
      print('[AVAILABILITY] Updating availability...');
      final result = await _updateAvailabilityUseCase.call(updatedAvailability);
      print('[AVAILABILITY] Update availability result: ${result.toString()}');

      if (result.isSuccess) {
        print('[AVAILABILITY] Availability updated successfully');
        Get.snackbar(
          'Success',
          result.message ?? 'Availability updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
        await getAvailability();
      } else {
        print('[AVAILABILITY] Failed to update: ${result.message}');
        Get.snackbar(
          'Error',
          result.message ?? 'Failed to update availability',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      print('[AVAILABILITY] Exception in updateAvailability: $e');
      Get.snackbar(
        'Error',
        'Something went wrong: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
