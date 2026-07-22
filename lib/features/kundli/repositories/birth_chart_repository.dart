import '../../../../core/services/network/astrology_api_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/birth_chart_model.dart';

class BirthChartRepository {
  final AstrologyApiClient _client;

  BirthChartRepository({AstrologyApiClient? client})
      : _client = client ?? AstrologyApiClient();

  List<Map<String, dynamic>> _transformSignListToPlanets(List<dynamic> rawList) {
    final List<Map<String, dynamic>> planets = [];
    for (int i = 0; i < rawList.length; i++) {
      final item = rawList[i];
      if (item is Map) {
        final house = i + 1;
        final signNumber = item['sign'] is int ? item['sign'] as int : int.tryParse(item['sign']?.toString() ?? '1') ?? 1;
        final List<dynamic> pList = item['planet_small'] ?? item['planet'] ?? [];
        for (var p in pList) {
          final pStr = p.toString().trim();
          if (pStr.isNotEmpty) {
            planets.add({
              'name': pStr,
              'house': house,
              'signNumber': signNumber,
            });
          }
        }
      }
    }
    return planets;
  }

  Future<BirthChartModel?> getBirthChart({
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

      final response = await _client.getBirthChart(payload);

      if (response.statusCode == 200) {
        final List<dynamic> rawList = response.data is List ? response.data : [];
        final planets = _transformSignListToPlanets(rawList);
        final transformedJson = {
          'success': true,
          'data': {
            'planets': planets,
          }
        };
        return BirthChartModel.fromJson(transformedJson);
      }
    } catch (e) {
      Logger.e('Error fetching birth chart', error: e);
    }
    return null;
  }
}
