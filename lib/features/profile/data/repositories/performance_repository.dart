import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/constants/app_urls.dart';
import '../../domain/repositories/performance_repository_interface.dart';

class PerformanceRepository implements PerformanceRepositoryInterface {
  final ApiClient apiClient;

  PerformanceRepository({required this.apiClient});

  Future<ResponseModel> getPerformanceData() async {
    return await apiClient.get(AppUrls.performance);
  }
}
