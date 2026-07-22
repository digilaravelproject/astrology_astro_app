import 'package:astro_user/core/services/network/astrology_api_client.dart';
import 'package:astro_user/core/utils/logger.dart';
import '../models/ashtakvarga_model.dart';

class AshtakvargaRepository {
  final AstrologyApiClient _client;

  AshtakvargaRepository({AstrologyApiClient? client})
      : _client = client ?? AstrologyApiClient();

  Future<AshtakvargaModel?> getAshtakvargaDetails({
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

      final response = await _client.getAshtakavarga(payload);

      if (response.statusCode == 200) {
        final Map<String, dynamic> rawData = response.data is Map<String, dynamic> ? response.data : {};
        final Map<String, dynamic> ashtakPoints = rawData['ashtak_points'] ?? {};
        
        final Map<String, dynamic> bhinnashtakavarga = {};
        final planets = {
          'Sun': 'sun',
          'Moon': 'moon',
          'Mars': 'mars',
          'Mercury': 'mercury',
          'Jupiter': 'jupiter',
          'Venus': 'venus',
          'Saturn': 'saturn'
        };

        final signsMap = {
          'aries': 'Aries',
          'taurus': 'Taurus',
          'gemini': 'Gemini',
          'cancer': 'Cancer',
          'leo': 'Leo',
          'virgo': 'Virgo',
          'libra': 'Libra',
          'scorpio': 'Scorpio',
          'sagittarius': 'Sagittarius',
          'capricorn': 'Capricorn',
          'aquarius': 'Aquarius',
          'pisces': 'Pisces'
        };

        planets.forEach((modelPlanet, apiPlanet) {
          final List<Map<String, dynamic>> strongSigns = [];
          ashtakPoints.forEach((apiSign, pointsMap) {
            final properSignName = signsMap[apiSign.toLowerCase()] ?? apiSign;
            if (pointsMap is Map) {
              final pts = pointsMap[apiPlanet] ?? 0;
              strongSigns.add({
                'points': pts,
                'sign': properSignName
              });
            }
          });
          bhinnashtakavarga[modelPlanet] = {
            'planet': modelPlanet,
            'strongSigns': strongSigns
          };
        });

        final transformedJson = {
          'success': true,
          'data': {
            'bhinnashtakavarga': bhinnashtakavarga
          }
        };

        return AshtakvargaModel.fromJson(transformedJson);
      }
    } catch (e) {
      Logger.e('Error fetching ashtakvarga details', error: e);
    }
    return null;
  }
}
