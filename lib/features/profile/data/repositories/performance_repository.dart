import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../domain/repositories/performance_repository_interface.dart';

class PerformanceRepository implements PerformanceRepositoryInterface {
  final ApiClient apiClient;

  PerformanceRepository({required this.apiClient});

  @override
  Future<ResponseModel> getPerformanceData() async {
    return await apiClient.get('/api/v1/astrologer/performance');
  }
}
