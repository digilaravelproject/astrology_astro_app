import 'package:get/get.dart';
import 'package:astro_astrologer/features/kundli/data/models/shadbala_model.dart';
import 'package:astro_astrologer/features/kundli/repositories/shadbala_repository.dart';

class ShadbalaController extends GetxController {
  final ShadbalaRepository _repository = ShadbalaRepository();

  var isLoading = false.obs;
  var shadbalaModel = Rxn<ShadbalaModel>();

  Future<void> fetchShadbalaDetails({
    required String datetime,
    required double latitude,
    required double longitude,
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
