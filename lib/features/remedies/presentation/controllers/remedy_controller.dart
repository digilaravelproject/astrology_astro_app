import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/remedy_model.dart';
import '../../domain/usecases/get_remedies_usecase.dart';
import '../../domain/usecases/get_remedy_details_usecase.dart';

class RemedyController extends GetxController {
  final GetRemediesUseCase _getRemediesUseCase;
  final GetRemedyDetailsUseCase _getRemedyDetailsUseCase;

  RemedyController({
    required GetRemediesUseCase getRemediesUseCase,
    required GetRemedyDetailsUseCase getRemedyDetailsUseCase,
  })  : _getRemediesUseCase = getRemediesUseCase,
        _getRemedyDetailsUseCase = getRemedyDetailsUseCase;

  final isLoading = false.obs;
  final isDetailLoading = false.obs;
  final remedies = <RemedyModel>[].obs;
  final filteredRemedies = <RemedyModel>[].obs;
  final selectedRemedy = Rxn<RemedyModel>();
  final searchQuery = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchRemedies();
  }

  Future<void> fetchRemedies() async {
    try {
      isLoading.value = true;
      final result = await _getRemediesUseCase.execute();
      remedies.assignAll(result);
      _applyFilters();
    } catch (e) {
      debugPrint('Error fetching remedies: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void _applyFilters() {
    if (searchQuery.value.isEmpty) {
      filteredRemedies.assignAll(remedies);
    } else {
      filteredRemedies.assignAll(remedies.where((remedy) {
        final matchesSearch = remedy.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
                            remedy.description.toLowerCase().contains(searchQuery.value.toLowerCase());
        return matchesSearch;
      }).toList());
    }
  }

  Future<void> refreshRemedies() async {
    await fetchRemedies();
  }

  Future<void> fetchRemedyDetails(int id) async {
    try {
      isDetailLoading.value = true;
      selectedRemedy.value = null; // Clear previous
      final result = await _getRemedyById(id);
      selectedRemedy.value = result;
    } catch (e) {
      debugPrint('Error fetching remedy detail: $e');
    } finally {
      isDetailLoading.value = false;
    }
  }

  // Alias for fetchRemedyById to match use case or previous logic if needed
  Future<RemedyModel?> _getRemedyById(int id) async {
    return await _getRemedyDetailsUseCase.execute(id);
  }
}
