import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/custom_snackbar.dart';

class PriceIncreaseController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final RxBool isLoadingStatus = false.obs;
  final RxBool isLoadingHistory = false.obs;
  final RxBool isSubmitting = false.obs;

  // Status Data observables
  final RxDouble totalBusyMinutes = 0.0.obs;
  final RxMap currentLevel = {}.obs;
  final RxMap nextLevel = {}.obs;
  final RxMap currentRates = {}.obs;
  final RxMap pendingRequest = {}.obs;
  final RxMap canRequestMap = {}.obs;

  // History List
  final RxList<dynamic> historyList = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchStatus();
  }

  Future<void> fetchStatus() async {
    isLoadingStatus.value = true;
    try {
      final response = await _apiClient.get(AppUrls.priceIncreaseStatus);
      if (response.isSuccess && response.body != null) {
        final data = response.body;
        totalBusyMinutes.value = double.tryParse(data['total_busy_minutes']?.toString() ?? '0.0') ?? 0.0;
        
        currentLevel.value = data['current_level'] as Map<String, dynamic>? ?? {};
        nextLevel.value = data['next_level'] as Map<String, dynamic>? ?? {};
        currentRates.value = data['current_rates'] as Map<String, dynamic>? ?? {};
        final pendingList = data['pending_requests'] as List<dynamic>? ?? [];
        if (pendingList.isNotEmpty) {
          pendingRequest.assignAll(pendingList.first as Map<dynamic, dynamic>);
        } else if (data['pending_request'] != null) {
          pendingRequest.assignAll(data['pending_request'] as Map<dynamic, dynamic>);
        } else {
          pendingRequest.clear();
        }
        
        canRequestMap.assignAll(data['can_request'] as Map<dynamic, dynamic>? ?? {});
        Logger.d('PriceIncreaseController: status loaded successfully, canRequestMap: $canRequestMap');
      } else {
        Logger.e('PriceIncreaseController: Failed to fetch status: ${response.message}');
      }
    } catch (e) {
      Logger.e('PriceIncreaseController: fetchStatus error: $e');
    } finally {
      isLoadingStatus.value = false;
    }
  }

  Future<void> fetchHistory() async {
    isLoadingHistory.value = true;
    try {
      final response = await _apiClient.get(AppUrls.priceIncreaseHistory);
      if (response.isSuccess && response.body != null) {
        historyList.assignAll(response.body as List<dynamic>? ?? []);
        Logger.d('PriceIncreaseController: history loaded successfully');
      } else {
        Logger.e('PriceIncreaseController: Failed to fetch history: ${response.message}');
      }
    } catch (e) {
      Logger.e('PriceIncreaseController: fetchHistory error: $e');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<bool> submitRequest(String priceType, double increaseAmount) async {
    isSubmitting.value = true;
    try {
      final response = await _apiClient.post(
        AppUrls.priceIncreaseRequest,
        data: {
          'price_type': priceType,
          'increase_amount': increaseAmount,
        },
      );
      if (response.isSuccess) {
        CustomSnackBar.showSuccess(response.message ?? "Request submitted successfully.");
        await fetchStatus(); // Refresh status
        return true;
      } else {
        CustomSnackBar.showError(response.message ?? "Failed to submit request.");
        return false;
      }
    } catch (e) {
      Logger.e('PriceIncreaseController: submitRequest error: $e');
      CustomSnackBar.showError("Failed to submit request: $e");
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
