import '../../../../core/services/network/astrology_api_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/sade_sati_model.dart';

class SadeSatiRepository {
  final AstrologyApiClient _client;

  SadeSatiRepository({AstrologyApiClient? client})
      : _client = client ?? AstrologyApiClient();

  Future<SadeSatiModel?> getSadeSati({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    return getSadeSatiDetails(
      datetime: datetime,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
    );
  }

  Future<SadeSatiModel?> getSadeSatiDetails({
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

      final response = await _client.getSadhesatiStatus(payload);

      if (response.statusCode == 200) {
        final Map<String, dynamic> rawData = response.data is Map<String, dynamic> ? response.data : {};
        
        final transformedJson = {
          'success': true,
          'data': {
            'description': rawData['what_is_sadhesati'],
            'is_in_sade_sati': rawData['sadhesati_status'] == true || rawData['is_undergoing_sadhesati']?.toString().toLowerCase().contains('yes') == true,
            'moon_sign': {
              'name': rawData['moon_sign'],
              'id': 0
            },
            'phase': rawData['sadhesati_phase'],
            'phase_name': rawData['sadhesati_phase'],
            'sade_sati_status': rawData['is_undergoing_sadhesati'],
            'start_date': rawData['start_date'],
            'end_date': rawData['end_date'],
            'transit_saturn': {
              'sign': {
                'name': rawData['saturn_sign'],
                'id': 0
              }
            }
          }
        };

        return SadeSatiModel.fromJson(transformedJson);
      }
    } catch (e) {
      Logger.e('Error fetching Sade Sati details', error: e);
    }
    return null;
  }
}
