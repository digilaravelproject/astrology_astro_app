import 'package:get/get.dart';
import '../models/remedies_model.dart';
import '../repositories/remedies_repository.dart';

class RemediesController extends GetxController {
  final RemediesRepository _repository = RemediesRepository();
  
  var isLoading = false.obs;
  var remediesModel = Rxn<RemediesModel>();

  Future<void> fetchGemstoneRemedies({
    String datetime = "1994-07-05T20:13:00",
    double latitude = 28.65,
    double longitude = 77.23,
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
