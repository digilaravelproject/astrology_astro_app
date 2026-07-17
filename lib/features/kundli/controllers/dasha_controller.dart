import 'package:get/get.dart';
import '../models/dasha_model.dart';
import '../models/yogini_dasha_model.dart';
import '../repositories/dasha_repository.dart';

class DashaController extends GetxController {
  final DashaRepository _repository = DashaRepository();
  
  var isLoading = false.obs;
  var isYoginiLoading = false.obs;
  var dashaModel = Rxn<DashaModel>();
  var yoginiDashaModel = Rxn<YoginiDashaModel>();

  Future<void> fetchDashaDetails({
    required String datetime,
    double latitude = 28.65,
    double longitude = 77.23,
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

  Future<void> fetchYoginiDashaDetails({
    required String datetime,
    double latitude = 28.65,
    double longitude = 77.23,
    String timezone = "+05:30",
  }) async {
    isYoginiLoading.value = true;
    try {
      final result = await _repository.getYoginiDashaDetails(
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );
      yoginiDashaModel.value = result;
    } finally {
      isYoginiLoading.value = false;
    }
  }
}
