import 'package:get/get.dart';
import '../models/manglik_model.dart';
import '../repositories/manglik_repository.dart';

class ManglikController extends GetxController {
  final ManglikRepository _repository = ManglikRepository();

  var isLoading = false.obs;
  var manglikModel = Rxn<ManglikModel>();

  Future<void> fetchManglikReport({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    isLoading.value = true;
    try {
      final result = await _repository.getManglikReport(
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );
      if (result != null) {
        manglikModel.value = result;
      }
    } finally {
      isLoading.value = false;
    }
  }
}
