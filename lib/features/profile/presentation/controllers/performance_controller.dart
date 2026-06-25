import 'package:get/get.dart';
import '../../domain/repositories/performance_repository_interface.dart';
import '../../domain/models/performance_model.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/widgets/custom_snackbar.dart';

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
      if (response.isSuccess && response.data != null) {
        if (response.data['status'] == 'success' && response.data['data'] != null) {
          performanceData.value = PerformanceModel.fromJson(response.data['data']);
        }
      } else {
        showCustomSnackBar(response.message ?? 'Failed to fetch performance data');
      }
    } catch (e) {
      showCustomSnackBar('Error loading performance data');
    } finally {
      isLoading.value = false;
    }
  }
}
