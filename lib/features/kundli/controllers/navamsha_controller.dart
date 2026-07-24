import 'package:get/get.dart';
import '../models/navamsha_model.dart';
import '../repositories/navamsha_repository.dart';

class NavamshaController extends GetxController {
  final NavamshaRepository _repository = NavamshaRepository();

  var isLoading = false.obs;
  var navamshaModel = Rxn<NavamshaModel>();
  var chartSvg = ''.obs;

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
      final svgResult = await _repository.getHoroChartSvg(
        chartId: 'd9',
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );
      if (svgResult != null) {
        chartSvg.value = svgResult;
      }
    } finally {
      isLoading.value = false;
    }
  }
}
