import 'package:get/get.dart';
import '../models/dasha_model.dart';
import '../repositories/dasha_repository.dart';

class DashaController extends GetxController {
  final DashaRepository _repository = DashaRepository();
  
  var isLoading = false.obs;
  var dashaModel = Rxn<DashaModel>();

  Future<void> fetchDashaDetails({
    required String datetime,
    required double latitude,
    required double longitude,
    String timezone = "+05:30",
  }) async {
    isLoading.value = true;
    try {
      final result = await _repository.getDashaDetails(
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );
      dashaModel.value = result;
    } finally {
      isLoading.value = false;
    }
  }
}
