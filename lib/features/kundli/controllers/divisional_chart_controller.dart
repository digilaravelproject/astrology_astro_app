import 'package:get/get.dart';
import '../models/divisional_chart_model.dart';
import '../repositories/divisional_chart_repository.dart';

class DivisionalChartController extends GetxController {
  final DivisionalChartRepository _repository = DivisionalChartRepository();

  var isLoading = false.obs;
  var divisionalChartModel = Rxn<DivisionalChartModel>();
  var currentDivision = 1.obs;

  Future<void> fetchDivisionalChart({
    required int division,
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    isLoading.value = true;
    currentDivision.value = division;
    try {
      final result = await _repository.getDivisionalChart(
        division: division,
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );
      if (result != null) {
        divisionalChartModel.value = result;
      }
    } finally {
      isLoading.value = false;
    }
  }
}
