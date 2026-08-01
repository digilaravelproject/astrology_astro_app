import 'package:get/get.dart';
import '../models/divisional_chart_model.dart';
import '../repositories/divisional_chart_repository.dart';

class DivisionalChartController extends GetxController {
  final DivisionalChartRepository _repository = DivisionalChartRepository();

  var isLoading = false.obs;
  var isSvgLoading = false.obs;
  var divisionalChartModel = Rxn<DivisionalChartModel>();
  var currentDivision = 1.obs;
  var northChartSvg = ''.obs;
  var southChartSvg = ''.obs;

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

  Future<void> fetchDivisionalChartSvg({
    required String chartId,
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    isSvgLoading.value = true;
    try {
      final northSvg = await _repository.getHoroChartSvg(
        chartId: chartId,
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
        chartType: 'north',
      );
      northChartSvg.value = northSvg ?? '';

      final southSvg = await _repository.getHoroChartSvg(
        chartId: chartId,
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
        chartType: 'south',
      );
      southChartSvg.value = southSvg ?? '';
    } finally {
      isSvgLoading.value = false;
    }
  }
}
