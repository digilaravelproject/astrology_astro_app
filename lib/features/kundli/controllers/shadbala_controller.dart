import 'package:get/get.dart';
import '../models/shadbala_model.dart';
import '../repositories/shadbala_repository.dart';

class ShadbalaController extends GetxController {
  final ShadbalaRepository _repository = ShadbalaRepository();
  
  var isLoading = false.obs;
  var shadbalaModel = Rxn<ShadbalaModel>();

  Future<void> fetchShadbalaDetails({
    String datetime = "1994-07-05T20:13:00",
    double latitude = 28.65,
    double longitude = 77.23,
    String timezone = "+05:30",
  }) async {
    isLoading.value = true;
    try {
      final result = await _repository.getShadbalaDetails(
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );
      shadbalaModel.value = result;
    } finally {
      isLoading.value = false;
    }
  }
}
