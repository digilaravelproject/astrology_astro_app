import '../../../../core/services/network/astrology_api_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/manglik_model.dart';

class ManglikRepository {
  final AstrologyApiClient _client;

  ManglikRepository({AstrologyApiClient? client})
      : _client = client ?? AstrologyApiClient();

  Future<ManglikModel?> getManglikReport({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    try {
      final payload = _client.buildBirthPayload(
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );

      final response = await _client.getManglikReport(payload);

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return ManglikModel.fromJson(response.data as Map<String, dynamic>);
        } else if (response.data is Map) {
          return ManglikModel.fromJson(Map<String, dynamic>.from(response.data as Map));
        }
      }
    } catch (e) {
      Logger.e('Error fetching Manglik report', error: e);
    }
    return null;
  }
}
