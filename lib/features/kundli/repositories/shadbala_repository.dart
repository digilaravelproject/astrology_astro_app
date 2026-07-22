import 'package:astro_astrologer/core/services/network/astrology_api_client.dart';
import 'package:astro_astrologer/core/utils/logger.dart';
import '../models/shadbala_model.dart';

class ShadbalaRepository {
  final AstrologyApiClient _client;

  ShadbalaRepository({AstrologyApiClient? client})
      : _client = client ?? AstrologyApiClient();

  Future<ShadbalaModel?> getShadbalaDetails({
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

      final response = await _client.getShadbala(payload);

      if (response.statusCode == 200) {
        final List<dynamic> rawList = response.data is List ? response.data : [response.data];
        
        final mappedList = rawList.map((item) {
          if (item is Map) {
            final double totalStr = (item['total_shadbala_virupa'] as num?)?.toDouble() ?? 0.0;
            final double reqMin = (item['required_minimum_virupa'] as num?)?.toDouble() ?? 1.0;
            final double ratio = totalStr / reqMin;

            return {
              'planet': item['name'],
              'total_strength': totalStr,
              'required_minimum': reqMin,
              'strength_ratio': ratio,
              'is_strong': item['is_strong'],
            };
          }
          return item;
        }).toList();

        final transformedJson = {
          'success': true,
          'data': {
            'shadbala': mappedList
          }
        };

        return ShadbalaModel.fromJson(transformedJson);
      }
    } catch (e) {
      Logger.e('Error fetching shadbala details', error: e);
    }
    return null;
  }
}
