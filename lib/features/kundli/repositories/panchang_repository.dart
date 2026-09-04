import 'package:astro_astrologer/core/services/network/astrology_api_client.dart';
import 'package:astro_astrologer/core/utils/logger.dart';
import 'package:astro_astrologer/features/kundli/data/models/panchang_model.dart';

class PanchangRepository {
  final AstrologyApiClient _client;

  PanchangRepository({AstrologyApiClient? client})
    : _client = client ?? AstrologyApiClient();

  Future<PanchangModel?> getPanchangDetails({
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

      final response = await _client.getPanchang(payload);

      if (response.statusCode == 200) {
        final Map<String, dynamic> rawData =
            response.data is Map<String, dynamic> ? response.data : {};

        final tithiName = rawData['tithi']?['details']?['tithi_name'];
        final tithiId = rawData['tithi']?['details']?['tithi_number'];

        final nakshatraName = rawData['nakshatra']?['details']?['nak_name'];
        final nakshatraId = rawData['nakshatra']?['details']?['nak_number'];

        final yogaName = rawData['yog']?['details']?['yog_name'];
        final yogaId = rawData['yog']?['details']?['yog_number'];

        final karanaName = rawData['karan']?['details']?['karan_name'];
        final karanaId = rawData['karan']?['details']?['karan_number'];

        final masaName =
            rawData['hindu_maah']?['purnimanta'] ??
            rawData['hindu_maah']?['amanta'] ??
            'N/A';
        final masaId =
            rawData['hindu_maah']?['purnimanta_id'] ??
            rawData['hindu_maah']?['amanta_id'] ??
            0;

        final rituName = rawData['ritu'] ?? 'N/A';

        final vaaraName = rawData['day'] ?? 'N/A';

        final transformedJson = {
          'success': true,
          'data': {
            'tithi': {'name': tithiName, 'id': tithiId},
            'karana': {'name': karanaName, 'id': karanaId},
            'yoga': {'name': yogaName, 'id': yogaId},
            'nakshatra': {'name': nakshatraName, 'id': nakshatraId},
            'masa': {'name': masaName, 'id': masaId},
            'ritu': {'name': rituName, 'id': 0},
            'vaara': {'name': vaaraName, 'id': 0},
            'timezone': payload['tzone']?.toString() ?? '+05:30',
            'sunrise': rawData['sunrise']?.toString(),
            'sunset': rawData['sunset']?.toString(),
          },
        };

        return PanchangModel.fromJson(transformedJson);
      }
    } catch (e) {
      Logger.e('Error fetching panchang details', error: e);
    }
    return null;
  }
}
