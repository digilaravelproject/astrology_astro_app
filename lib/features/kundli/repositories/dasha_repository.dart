import 'package:astro_user/core/services/network/astrology_api_client.dart';
import 'package:astro_user/core/utils/logger.dart';
import '../models/dasha_model.dart';
import '../models/yogini_dasha_model.dart';

class DashaRepository {
  final AstrologyApiClient _client;

  DashaRepository({AstrologyApiClient? client})
      : _client = client ?? AstrologyApiClient();

  Future<DashaModel?> getVimshottariDasha({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    return getDashaDetails(
      datetime: datetime,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
    );
  }

  Future<DashaModel?> getDashaDetails({
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

      final response = await _client.getVimshottariDasha(payload);

      if (response.statusCode == 200) {
        final List<dynamic> rawList = response.data is List ? response.data : [response.data];
        final mappedList = rawList.map((item) {
          if (item is Map) {
            return {
              'planet': item['planet'],
              'start_date': item['start'] ?? item['start_date'],
              'end_date': item['end'] ?? item['end_date'],
              'vedic_name': item['vedic_name'],
            };
          }
          return item;
        }).toList();
        final transformedJson = {
          'success': true,
          'data': {
            'maha_dasha': mappedList,
          }
        };
        return DashaModel.fromJson(transformedJson);
      }
    } catch (e) {
      Logger.e('Error fetching Vimshottari dasha', error: e);
    }
    return null;
  }

  Future<YoginiDashaModel?> getYoginiDashaDetails({
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

      final response = await _client.getYoginiDasha(payload);

      if (response.statusCode == 200) {
        final List<dynamic> rawList = response.data is List ? response.data : [response.data];
        final mappedList = rawList.map((item) {
          if (item is Map) {
            return {
              'yogini': item['dasha_name'] ?? item['yogini'],
              'startDate': item['start_date'] ?? item['start'],
              'endDate': item['end_date'] ?? item['end'],
            };
          }
          return item;
        }).toList();
        final transformedJson = {
          'success': true,
          'data': {
            'mahadashas': mappedList,
          }
        };
        return YoginiDashaModel.fromJson(transformedJson);
      }
    } catch (e) {
      Logger.e('Error fetching Yogini dasha', error: e);
    }
    return null;
  }

  Future<DashaModel?> getYoginiDasha({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    return getDashaDetails(
      datetime: datetime,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
    );
  }
}
