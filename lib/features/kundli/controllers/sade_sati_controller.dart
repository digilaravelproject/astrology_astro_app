import 'package:get/get.dart';
import '../models/sade_sati_model.dart';
import '../repositories/sade_sati_repository.dart';

class SadeSatiController extends GetxController {
  final SadeSatiRepository _repository = SadeSatiRepository();

  final Rx<SadeSatiModel?> sadeSatiModel = Rx<SadeSatiModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<void> fetchSadeSati({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _repository.getSadeSati(
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );

      sadeSatiModel.value = response;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
