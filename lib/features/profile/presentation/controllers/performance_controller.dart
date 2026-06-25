import 'package:get/get.dart';
import '../../domain/repositories/performance_repository_interface.dart';
import '../../domain/models/performance_model.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/utils/custom_snackbar.dart';

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
        if (response.body['status'] == 'success' && response.body['data'] != null) {
          performanceData.value = PerformanceModel.fromJson(response.body['data']);
        }
      } else {
        showCustomSnackBar(response.message);
      }
    } catch (e) {
      showCustomSnackBar('Error loading performance data');
    } finally {
      isLoading.value = false;
    }
  }
}
