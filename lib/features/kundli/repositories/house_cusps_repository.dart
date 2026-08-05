import '../../../../core/services/network/astrology_api_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/house_cusps_model.dart';

class HouseCuspsRepository {
  final AstrologyApiClient _client;

  HouseCuspsRepository({AstrologyApiClient? client})
      : _client = client ?? AstrologyApiClient();

  Future<HouseCuspsModel?> getHouseCusps({
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

      final response = await _client.getKpHouseCusps(payload);

      if (response.statusCode == 200) {
        final List<dynamic> rawList = response.data is List ? response.data : [response.data];
        
        final mappedCusps = rawList.map((item) {
          if (item is Map) {
            return {
              'number': item['house_id'] ?? item['house'],
              'sign': item['sign'],
              'signNumber': item['sign_id'] ?? item['signNumber'],
              'cusp': item['cusp_full_degree'] ?? item['cuspLongitude'],
              'degree': item['cusp_full_degree'] ?? item['cuspLongitude'],
            };
          }
          return item;
        }).toList();

        final transformedJson = {
          'success': true,
          'data': mappedCusps
        };

        return HouseCuspsModel.fromJson(transformedJson);
      }
    } catch (e) {
      Logger.e('Error fetching house cusps', error: e);
    }
    return null;
  }
}
