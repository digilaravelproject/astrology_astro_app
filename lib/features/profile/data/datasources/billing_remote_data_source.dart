import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/utils/logger.dart';

abstract class BillingRemoteDataSourceInterface {
  Future<ResponseModel> getBillingAddress();
  Future<ResponseModel> updateBillingAddress(Map<String, dynamic> data);
}

class BillingRemoteDataSource implements BillingRemoteDataSourceInterface {
  final ApiClient apiClient;

  BillingRemoteDataSource({required this.apiClient});

  @override
  Future<ResponseModel> getBillingAddress() async {
    try {
      final response = await apiClient.get(AppUrls.billingAddress);
      Logger.d('BillingRemoteDataSource.getBillingAddress success');
      return response;
    } catch (e) {
      Logger.e('BillingRemoteDataSource.getBillingAddress error: $e');
      return ResponseModel(isSuccess: false, message: 'Something went wrong: $e');
    }
  }

  @override
  Future<ResponseModel> updateBillingAddress(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.put(AppUrls.billingAddress, data: data);
      Logger.d('BillingRemoteDataSource.updateBillingAddress success');
      return response;
    } catch (e) {
      Logger.e('BillingRemoteDataSource.updateBillingAddress error: $e');
      return ResponseModel(isSuccess: false, message: 'Something went wrong: $e');
    }
  }
}
