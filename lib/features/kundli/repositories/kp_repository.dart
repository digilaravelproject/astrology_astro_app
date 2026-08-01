import '../../../../core/services/network/astrology_api_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/kp_model.dart';

class KPRepository {
  final AstrologyApiClient _client;

  KPRepository({AstrologyApiClient? client})
      : _client = client ?? AstrologyApiClient();

  Future<KPFullReportModel?> getKPFullReport({
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

      final planetsResponse = await _client.getKpPlanets(payload);
      final cuspsResponse = await _client.getKpHouseCusps(payload);

      if (planetsResponse.statusCode == 200 && cuspsResponse.statusCode == 200) {
        final List<dynamic> rawPlanetsList = planetsResponse.data is List ? planetsResponse.data : [];
        final List<dynamic> rawCuspsList = cuspsResponse.data is List ? cuspsResponse.data : [];

        final signsList = [
          'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
          'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
        ];

        // Format planets list
        final List<Map<String, dynamic>> mappedPlanets = rawPlanetsList.map((item) {
          if (item is Map) {
            final signName = item['sign']?.toString() ?? 'Aries';
            final signIndex = signsList.indexOf(signName); // 0-indexed index

            return {
              'planet': item['planet_name'] ?? item['planet'],
              'degree': item['degree'],
              'longitude': item['degree'] ?? item['longitude'],
              'isRetrograde': item['is_retro']?.toString().toLowerCase() == 'true',
              'sign': signName,
              'signIndex': signIndex >= 0 ? signIndex : 0,
              'signLord': item['sign_lord'],
              'nakshatra': item['nakshatra'],
              'nakshatraLord': item['nakshatra_lord'],
              'subLord': item['sub_lord'],
              'subSubLord': item['sub_sub_lord'],
            };
          }
          return <String, dynamic>{};
        }).toList();

        // Format cusps list
        final List<Map<String, dynamic>> mappedCusps = rawCuspsList.map((item) {
          if (item is Map) {
            final signName = item['sign']?.toString() ?? 'Aries';
            final signIndex = signsList.indexOf(signName); // 0-indexed index

            return {
              'house': item['house_id'] ?? item['house'],
              'cuspLongitude': item['cusp_full_degree'] ?? item['cuspLongitude'],
              'sign': signName,
              'signIndex': signIndex >= 0 ? signIndex : 0,
              'signLord': item['sign_lord'],
              'nakshatra': item['nakshatra'],
              'nakshatraLord': item['nakshatra_lord'],
              'subLord': item['sub_lord'],
              'subSubLord': item['sub_sub_lord'],
            };
          }
          return <String, dynamic>{};
        }).toList();

        // Derive ruling planets
        final ascCusp = mappedCusps.firstWhere((c) => c['house'] == 1, orElse: () => <String, dynamic>{});
        final moonPlanet = mappedPlanets.firstWhere((p) => p['planet'] == 'Moon', orElse: () => <String, dynamic>{});

        // Resolve day lord name from the current day name
        final Map<int, String> dayLords = {
          DateTime.monday: 'Moon',
          DateTime.tuesday: 'Mars',
          DateTime.wednesday: 'Mercury',
          DateTime.thursday: 'Jupiter',
          DateTime.friday: 'Venus',
          DateTime.saturday: 'Saturn',
          DateTime.sunday: 'Sun',
        };
        DateTime birthDt;
        try {
          birthDt = DateTime.parse(datetime);
        } catch (_) {
          birthDt = DateTime.now();
        }
        final dayLord = dayLords[birthDt.weekday] ?? 'Moon';

        final Map<String, dynamic> rulingPlanets = {
          'ascendantSignLord': ascCusp['signLord'] ?? '-',
          'ascendantNakshatraLord': ascCusp['nakshatraLord'] ?? '-',
          'ascendantSubLord': ascCusp['subLord'] ?? '-',
          'dayLord': dayLord,
          'moonSignLord': moonPlanet['signLord'] ?? '-',
          'moonNakshatraLord': moonPlanet['nakshatraLord'] ?? '-',
          'moonSubLord': moonPlanet['subLord'] ?? '-',
        };

        final transformedJson = {
          'success': true,
          'data': {
            'cusps': mappedCusps,
            'planets': mappedPlanets,
            'rulingPlanets': rulingPlanets,
          }
        };

        return KPFullReportModel.fromJson(transformedJson);
      }
    } catch (e) {
      Logger.e('Error fetching KP full report', error: e);
    }
    return null;
  }

  Future<KPFullReportModel?> getKpFullReport({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    return getKPFullReport(
      datetime: datetime,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
    );
  }
}

typedef KpRepository = KPRepository;
