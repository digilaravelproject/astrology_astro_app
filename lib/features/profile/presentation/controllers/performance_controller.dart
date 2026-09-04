import 'package:get/get.dart';
import 'package:astro_astrologer/features/profile/domain/repositories/performance_repository_interface.dart';
import 'package:astro_astrologer/features/profile/data/models/performance_model.dart';
import 'package:astro_astrologer/core/services/network/response_model.dart';
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';

class PerformanceController extends GetxController {
  final PerformanceRepositoryInterface repository;

  PerformanceController({required this.repository});

  final RxBool isLoading = false.obs;
  final Rx<PerformanceModel?> performanceData = Rx<PerformanceModel?>(null);

  @override
  void onInit() {
    super.onInit();
    getPerformanceData();
  }

  Future<void> getPerformanceData() async {
    isLoading.value = true;
    try {
      ResponseModel response = await repository.getPerformanceData();
      if (response.isSuccess && response.body != null) {
        performanceData.value = PerformanceModel.fromJson(response.body);
      } else {
        CustomSnackBar.showError(response.message);
      }
    } catch (e) {
      CustomSnackBar.showError('Error loading performance data');
    } finally {
      isLoading.value = false;
    }
  }
}
