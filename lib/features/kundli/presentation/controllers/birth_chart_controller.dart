import 'package:get/get.dart';
import 'package:astro_astrologer/features/kundli/data/models/birth_chart_model.dart';
import 'package:astro_astrologer/features/kundli/repositories/birth_chart_repository.dart';

class BirthChartController extends GetxController {
  final BirthChartRepository _repository = BirthChartRepository();

  var isLoading = false.obs;
  var birthChartModel = Rxn<BirthChartModel>();
  var northChartSvg = ''.obs;
  var southChartSvg = ''.obs;

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

      final northSvg = await _repository.getHoroChartSvg(
        chartId: 'd1',
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
        chartType: 'north',
      );
      if (northSvg != null) {
        northChartSvg.value = northSvg;
      }

      final southSvg = await _repository.getHoroChartSvg(
        chartId: 'd1',
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
        chartType: 'south',
      );
      if (southSvg != null) {
        southChartSvg.value = southSvg;
      }
    } finally {
      isLoading.value = false;
    }
  }
}
