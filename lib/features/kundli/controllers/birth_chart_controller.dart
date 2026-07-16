import 'package:get/get.dart';
import '../models/birth_chart_model.dart';
import '../repositories/birth_chart_repository.dart';

class BirthChartController extends GetxController {
  final BirthChartRepository _repository = BirthChartRepository();

  var isLoading = false.obs;
  var birthChartModel = Rxn<BirthChartModel>();

  Future<void> fetchBirthChart({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    isLoading.value = true;
    try {
      final result = await _repository.getBirthChart(
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );
      if (result != null) {
        birthChartModel.value = result;
      }
    } finally {
      isLoading.value = false;
    }
  }
}
