import 'package:get/get.dart';
import '../models/ashtakvarga_model.dart';
import '../repositories/ashtakvarga_repository.dart';

class AshtakvargaController extends GetxController {
  final AshtakvargaRepository _repository = AshtakvargaRepository();
  
  var isLoading = false.obs;
  var ashtakvargaModel = Rxn<AshtakvargaModel>();

  Future<void> fetchAshtakvargaDetails({
    required String datetime,
    double latitude = 28.65,
    double longitude = 77.23,
    String timezone = "+05:30",
  }) async {
    isLoading.value = true;
    try {
      final result = await _repository.getAshtakvargaDetails(
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );
      ashtakvargaModel.value = result;
    } finally {
      isLoading.value = false;
    }
  }
}
