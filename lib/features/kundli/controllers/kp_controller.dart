import 'package:get/get.dart';
import '../models/kp_model.dart';
import '../repositories/kp_repository.dart';

class KPController extends GetxController {
  final KPRepository _kpRepository = KPRepository();

  final Rx<KPFullReportModel?> kpFullReportModel = Rx<KPFullReportModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<void> fetchKPData({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _kpRepository.getKPFullReport(
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );

      kpFullReportModel.value = response;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
