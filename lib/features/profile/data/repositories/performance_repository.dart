import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/services/network/response_model.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/features/profile/domain/repositories/performance_repository_interface.dart';

class PerformanceRepository implements PerformanceRepositoryInterface {
  final ApiClient apiClient;

  PerformanceRepository({required this.apiClient});

  Future<ResponseModel> getPerformanceData() async {
    return await apiClient.get(AppUrls.performance);
  }
}
