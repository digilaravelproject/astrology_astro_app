import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/constants/app_urls.dart';
import '../../domain/models/availability_model.dart';

class AvailabilityRemoteDataSource {
  final ApiClient _apiClient;

  AvailabilityRemoteDataSource(this._apiClient);

  Future<ResponseModel> getAvailability() async {
    print('[AVAILABILITY_DS] Getting availability');
    final result = await _apiClient.get(AppUrls.availability);
    print('[AVAILABILITY_DS] Get availability response: ${result.toString()}');
    return result;
  }

  Future<ResponseModel> updateAvailability(List<AvailabilityModel> availability) async {
    print('[AVAILABILITY_DS] Updating availability');
    final data = {
      'availability': availability.map((a) => a.toJson()).toList(),
    };
    final result = await _apiClient.put(AppUrls.availability, data: data);
    print('[AVAILABILITY_DS] Update availability response: ${result.toString()}');
    return result;
  }
}
