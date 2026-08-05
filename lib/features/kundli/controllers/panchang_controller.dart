import 'package:get/get.dart';
import '../models/panchang_model.dart';
import '../repositories/panchang_repository.dart';

class PanchangController extends GetxController {
  final PanchangRepository _repository = PanchangRepository();
  
  var isLoading = false.obs;
  var panchangModel = Rxn<PanchangModel>();

  // Fetch panchang details based on provided parameters, or some defaults if not.
  // In a real scenario, datetime, lat, long should come from user inputs (birth details)
  Future<void> fetchPanchangDetails({
    required String datetime,
    required double latitude,
    required double longitude,
    String timezone = "+05:30",
  }) async {
    isLoading.value = true;
    try {
      final result = await _repository.getPanchangDetails(
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );
      panchangModel.value = result;
    } finally {
      isLoading.value = false;
    }
  }
}
