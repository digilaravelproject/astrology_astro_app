import 'package:astro_astrologer/core/services/network/astrology_api_client.dart';
import 'package:astro_astrologer/core/utils/logger.dart';
import 'package:astro_astrologer/features/kundli/data/models/planet_positions_model.dart';

class PlanetPositionsRepository {
  final AstrologyApiClient _client;

  PlanetPositionsRepository({AstrologyApiClient? client})
    : _client = client ?? AstrologyApiClient();

  Future<PlanetPositionsModel?> getPlanetPositions({
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

      final response = await _client.getPlanetPositions(payload);

      if (response.statusCode == 200) {
        final List<dynamic> rawList =
            response.data is List ? response.data : [response.data];

        final signsList = [
          'Aries',
          'Taurus',
          'Gemini',
          'Cancer',
          'Leo',
          'Virgo',
          'Libra',
          'Scorpio',
          'Sagittarius',
          'Capricorn',
          'Aquarius',
          'Pisces',
        ];

        final mappedPlanets =
            rawList.map((item) {
              if (item is Map) {
                final signName = item['sign']?.toString() ?? 'Aries';
                final signIndex =
                    signsList.indexOf(signName) + 1; // 1-based index

                return {
                  'name': item['name'],
                  'sign': signName,
                  'normDegree': item['normDegree'],
                  'nakshatra': {'name': item['nakshatra']?.toString() ?? 'N/A'},
                  'house': item['house'],
                  'signNumber': signIndex,
                  'fullDegree': item['fullDegree'],
                };
              }
              return item;
            }).toList();

        final transformedJson = {
          'success': true,
          'data': {'planets': mappedPlanets},
        };

        return PlanetPositionsModel.fromJson(transformedJson);
      }
    } catch (e) {
      Logger.e('Error fetching planet positions', error: e);
    }
    return null;
  }
}
