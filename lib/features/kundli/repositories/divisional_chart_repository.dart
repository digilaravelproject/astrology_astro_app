import '../../../../core/services/network/astrology_api_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/divisional_chart_model.dart';

class DivisionalChartRepository {
  final AstrologyApiClient _client;

  DivisionalChartRepository({AstrologyApiClient? client})
      : _client = client ?? AstrologyApiClient();

  List<Map<String, dynamic>> _transformSignListToPlanets(List<dynamic> rawList) {
    final List<Map<String, dynamic>> planets = [];
    for (int i = 0; i < rawList.length; i++) {
      final item = rawList[i];
      if (item is Map) {
        final house = i + 1;
        final signNumber = item['sign'] is int ? item['sign'] as int : int.tryParse(item['sign']?.toString() ?? '1') ?? 1;
        final signName = item['sign_name']?.toString() ?? '';
        final List<dynamic> pList = item['planet_small'] ?? item['planet'] ?? [];
        for (var p in pList) {
          final pStr = p.toString().trim();
          if (pStr.isNotEmpty) {
            planets.add({
              'planet': pStr,
              'house': house,
              'sign': signNumber - 1, // Model expects 0-indexed sign, signNumber gets sign + 1
              'signName': signName,
            });
          }
        }
      }
    }
    return planets;
  }

  Future<DivisionalChartModel?> getDivisionalChart({
    dynamic division,
    String? chartType,
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

      final String typeStr = chartType ?? (division != null ? 'd$division' : 'd1');

      final response = await _client.getDivisionalChart(typeStr, payload);

      if (response.statusCode == 200) {
        final List<dynamic> rawList = response.data is List ? response.data : [];
        final positions = _transformSignListToPlanets(rawList);
        final transformedJson = {
          'success': true,
          'data': {
            'division': division is int ? division : int.tryParse(division?.toString() ?? '1') ?? 1,
            'positions': positions,
          }
        };
        return DivisionalChartModel.fromJson(transformedJson);
      }
    } catch (e) {
      Logger.e('Error fetching divisional chart', error: e);
    }
    return null;
  }
}
