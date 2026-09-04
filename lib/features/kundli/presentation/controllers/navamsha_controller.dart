import 'package:get/get.dart';
import 'package:astro_astrologer/features/kundli/data/models/navamsha_model.dart';
import 'package:astro_astrologer/features/kundli/repositories/navamsha_repository.dart';

class NavamshaController extends GetxController {
  final NavamshaRepository _repository = NavamshaRepository();

  var isLoading = false.obs;
  var navamshaModel = Rxn<NavamshaModel>();
  var northChartSvg = ''.obs;
  var southChartSvg = ''.obs;

  Future<void> fetchNavamsha({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    isLoading.value = true;
    try {
      final result = await _repository.getNavamsha(
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );
      if (result != null) {
        navamshaModel.value = result;
      }

      final northSvg = await _repository.getHoroChartSvg(
        chartId: 'd9',
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
        chartId: 'd9',
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
