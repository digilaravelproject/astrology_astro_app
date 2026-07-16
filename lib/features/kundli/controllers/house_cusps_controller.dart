import 'package:get/get.dart';
import '../models/house_cusps_model.dart';
import '../repositories/house_cusps_repository.dart';

class HouseCuspsController extends GetxController {
  final HouseCuspsRepository _repository = HouseCuspsRepository();

  var isLoading = false.obs;
  var houseCuspsModel = Rxn<HouseCuspsModel>();

  Future<void> fetchHouseCusps({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    isLoading.value = true;
    try {
      final result = await _repository.getHouseCusps(
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );
      if (result != null) {
        houseCuspsModel.value = result;
      }
    } finally {
      isLoading.value = false;
    }
  }
}
