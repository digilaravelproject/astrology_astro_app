import 'package:get/get.dart';
import '../models/planet_positions_model.dart';
import '../repositories/planet_positions_repository.dart';

class PlanetPositionsController extends GetxController {
  final PlanetPositionsRepository _repository = PlanetPositionsRepository();

  var isLoading = false.obs;
  var planetPositionsModel = Rxn<PlanetPositionsModel>();

  Future<void> fetchPlanetPositions({
    required String datetime,
    required double latitude,
    required double longitude,
    String timezone = "+05:30",
  }) async {
    isLoading.value = true;
    try {
      final result = await _repository.getPlanetPositions(
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );
      planetPositionsModel.value = result;
    } finally {
      isLoading.value = false;
    }
  }
}
