import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/utils/logger.dart';
import 'package:astro_astrologer/features/remedies/data/models/remedy_model.dart';
import 'package:astro_astrologer/features/remedies/domain/usecases/get_remedies_usecase.dart';
import 'package:astro_astrologer/features/remedies/domain/usecases/get_remedy_details_usecase.dart';
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';

class RemedyController extends GetxController {
  final GetRemediesUseCase _getRemediesUseCase;
  final GetRemedyDetailsUseCase _getRemedyDetailsUseCase;

  RemedyController(this._getRemediesUseCase, this._getRemedyDetailsUseCase);

  final RxList<RemedyModel> remedies = <RemedyModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isDetailLoading = false.obs;
  final Rxn<RemedyModel> selectedRemedy = Rxn<RemedyModel>();

  @override
  void onInit() {
    super.onInit();
    getRemedies();
  }

  Future<void> getRemedies() async {
    try {
      isLoading.value = true;
      Logger.d('Getting remedies...', tag: 'REMEDY');
      final result = await _getRemediesUseCase.call();
      Logger.d('Get remedies result: ${result.toString()}', tag: 'REMEDY');

      if (result.isSuccess) {
        final List<dynamic> data = result.body['remedies'] ?? [];
        remedies.value =
            data.map((json) => RemedyModel.fromJson(json)).toList();
        Logger.d('Loaded ${remedies.length} remedies', tag: 'REMEDY');
      } else {
        Logger.e('Failed to get remedies: ${result.message}', tag: 'REMEDY');
        CustomSnackBar.disabledSnackbar(
          'Error',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      Logger.e('Exception in getRemedies: $e', tag: 'REMEDY');
      CustomSnackBar.disabledSnackbar(
        'Error',
        'Something went wrong: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRemedyDetails(int id) async {
    try {
      isDetailLoading.value = true;
      Logger.d('Fetching remedy details for id: $id', tag: 'REMEDY');
      final result = await _getRemedyDetailsUseCase.execute(id);
      if (result != null) {
        selectedRemedy.value = result;
        Logger.d('Loaded remedy details: ${result.title}', tag: 'REMEDY');
      } else {
        Logger.w('Remedy details not found for id: $id', tag: 'REMEDY');
      }
    } catch (e) {
      Logger.e('Exception in fetchRemedyDetails: $e', tag: 'REMEDY');
    } finally {
      isDetailLoading.value = false;
    }
  }
}
