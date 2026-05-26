import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/remedy_model.dart';
import '../../domain/usecases/get_remedies_usecase.dart';

class RemedyController extends GetxController {
  final GetRemediesUseCase _getRemediesUseCase;

  RemedyController(this._getRemediesUseCase);

  final RxList<RemedyModel> remedies = <RemedyModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getRemedies();
  }

  Future<void> getRemedies() async {
    try {
      isLoading.value = true;
      print('[REMEDY] Getting remedies...');
      final result = await _getRemediesUseCase.call();
      print('[REMEDY] Get remedies result: ${result.toString()}');

      if (result.isSuccess) {
        final List<dynamic> data = result.body['remedies'] ?? [];
        remedies.value = data.map((json) => RemedyModel.fromJson(json)).toList();
        print('[REMEDY] Loaded ${remedies.length} remedies');
      } else {
        print('[REMEDY] Failed to get remedies: ${result.message}');
        Get.snackbar(
          'Error',
          result.message ?? 'Failed to fetch remedies',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      print('[REMEDY] Exception in getRemedies: $e');
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
}
