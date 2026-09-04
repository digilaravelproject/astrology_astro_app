import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/services/network/response_model.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/constants/app_constants.dart';
import 'package:astro_astrologer/core/services/storage/shared_prefs.dart';

class RemedyRemoteDataSource {
  final ApiClient _apiClient;

  RemedyRemoteDataSource(this._apiClient);

  Future<ResponseModel> getRemedies() async {
    final lang = SharedPrefs.getString(AppConstants.language) ?? 'en';
    return await _apiClient.get('${AppUrls.remedies}?language=$lang');
  }

  Future<ResponseModel> getRemedyDetails(int id) async {
    final lang = SharedPrefs.getString(AppConstants.language) ?? 'en';
    return await _apiClient.get('${AppUrls.remedyDetails(id)}?language=$lang');
  }
}
