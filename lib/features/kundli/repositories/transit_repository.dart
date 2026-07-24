import '../../../../core/services/network/astrology_api_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/transit_model.dart';

class TransitRepository {
  final AstrologyApiClient _client;

  TransitRepository({AstrologyApiClient? client})
      : _client = client ?? AstrologyApiClient();

  Future<TransitModel?> getTransit({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    return getTransitDetails(
      datetime: datetime,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
    );
  }

  Future<TransitModel?> getTransitDetails({
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
        final List<dynamic> rawList = response.data is List ? response.data : [response.data];
        
        final signsList = [
          'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
          'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
        ];

        final mappedPlanets = rawList.map((item) {
          if (item is Map) {
            final signName = item['sign']?.toString() ?? 'Aries';
            final signIndex = signsList.indexOf(signName) + 1; // 1-based index
            final house = item['house'] is int ? item['house'] as int : int.tryParse(item['house']?.toString() ?? '1') ?? 1;

            return {
              'name': item['name'],
              'houseFromLagna': house,
              'signNumber': signIndex,
              'isRetrograde': item['isRetro']?.toString().toLowerCase() == 'true',
            };
          }
          return item;
        }).toList();

        final transformedJson = {
          'success': true,
          'data': {
            'planets': mappedPlanets
          }
        };

        return TransitModel.fromJson(transformedJson);
      }
    } catch (e) {
      Logger.e('Error fetching transit details', error: e);
    }
    return null;
  }

  Future<String?> getHoroChartSvg({
    required String chartId,
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

      final response = await _client.getHoroChartImage(chartId, payload);
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map && response.data['svg'] != null) {
          return response.data['svg'].toString();
        }
      }
    } catch (e) {
      Logger.e('Error fetching chart SVG for $chartId', error: e);
    }
    return null;
  }
}
