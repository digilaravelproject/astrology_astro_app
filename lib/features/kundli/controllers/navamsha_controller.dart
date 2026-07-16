import 'package:get/get.dart';
import '../models/navamsha_model.dart';
import '../repositories/navamsha_repository.dart';

class NavamshaController extends GetxController {
  final NavamshaRepository _repository = NavamshaRepository();

  var isLoading = false.obs;
  var navamshaModel = Rxn<NavamshaModel>();

  Future<void> fetchNavamsha({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    isLoading.value = true;
    try {
      final result = await _repository.getNavamsha(
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );
      if (result != null) {
        navamshaModel.value = result;
      }
    } finally {
      isLoading.value = false;
    }
  }
}
