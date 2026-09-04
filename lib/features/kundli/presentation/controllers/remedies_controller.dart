import 'package:get/get.dart';
import 'package:astro_astrologer/features/kundli/data/models/remedies_model.dart';
import 'package:astro_astrologer/features/kundli/repositories/remedies_repository.dart';

class RemediesController extends GetxController {
  final RemediesRepository _repository = RemediesRepository();

  var isLoading = false.obs;
  var remediesModel = Rxn<RemediesModel>();

  Future<void> fetchGemstoneRemedies({
    required String datetime,
    required double latitude,
    required double longitude,
    String timezone = "+05:30",
  }) async {
    isLoading.value = true;
    try {
      final result = await _repository.getGemstoneRemedies(
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );
      remediesModel.value = result;
    } finally {
      isLoading.value = false;
    }
  }
}
