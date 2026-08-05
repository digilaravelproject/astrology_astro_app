import 'package:astro_astrologer/core/services/network/astrology_api_client.dart';
import 'package:astro_astrologer/core/utils/logger.dart';
import '../models/remedies_model.dart';

class RemediesRepository {
  final AstrologyApiClient _client;

  RemediesRepository({AstrologyApiClient? client})
      : _client = client ?? AstrologyApiClient();

  Future<RemediesModel?> getGemstoneRemedies({
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

      final response = await _client.getGemstoneRemedies(payload);

      if (response.statusCode == 200) {
        final Map<String, dynamic> rawData = response.data is Map<String, dynamic> ? response.data : {};
        
        final List<Map<String, dynamic>> crystals = [];
        
        rawData.forEach((key, val) {
          if (val is Map) {
            crystals.add({
              'planet': val['gem_deity'] ?? key,
              'planetStrength': key,
              'gemstone': {
                'gemstone': val['name'],
                'weight': val['weight_caret'],
                'finger': val['wear_finger'],
                'dayToWear': val['wear_day'],
                'metal': val['wear_metal'],
                'planet': val['gem_deity'],
                'planetStrength': key,
              },
              'mantra': {
                'mantra': 'Om Sham Shanaishcharaye Namah',
                'japaCount': 108,
              }
            });
          }
        });

        final transformedJson = {
          'success': true,
          'data': {
            'crystals': crystals,
          }
        };

        return RemediesModel.fromJson(transformedJson);
      }
    } catch (e) {
      Logger.e('Error fetching gemstone remedies', error: e);
    }
    return null;
  }
}
