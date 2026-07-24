import 'package:get/get.dart';
import '../models/transit_model.dart';
import '../repositories/transit_repository.dart';

class TransitController extends GetxController {
  final TransitRepository _repository = TransitRepository();

  var isLoading = false.obs;
  var transitModel = Rxn<TransitModel>();
  var chartSvg = ''.obs;

  Future<void> fetchTransit({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    isLoading.value = true;
    try {
      final result = await _repository.getTransit(
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );
      if (result != null) {
        transitModel.value = result;
      }
      final svgResult = await _repository.getHoroChartSvg(
        chartId: 'transit',
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
