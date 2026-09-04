import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/services/network/response_model.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';

class ScheduleRemoteDataSource {
  final ApiClient _apiClient;

  ScheduleRemoteDataSource(this._apiClient);

  Future<ResponseModel> setSleepHours(String startTime, String endTime) async {
    return await _apiClient.post(
      AppUrls.sleepHours,
      data: {'sleep_start_time': startTime, 'sleep_end_time': endTime},
    );
  }

  Future<ResponseModel> getSleepHours() async {
    return await _apiClient.get(AppUrls.sleepHours);
  }
}
