import 'package:astro_astrologer/core/services/network/astrology_api_client.dart';
import 'package:astro_astrologer/core/utils/logger.dart';
import 'package:astro_astrologer/features/kundli/data/models/dasha_model.dart';

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
      return _parseDashaResponse(response);
    } catch (e) {
      Logger.e('Error fetching Vimshottari dasha', error: e);
    }
    return null;
  }

  Future<List<DashaItem>> getSubDasha({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
    required String md,
  }) async {
    try {
      final payload = _client.buildBirthPayload(
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );
      final response = await _client.getSubVdasha(payload, md);
      return _parseDashaList(response);
    } catch (e) {
      Logger.e('Error fetching sub dasha for $md', error: e);
    }
    return [];
  }

  Future<List<DashaItem>> getSubSubDasha({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
    required String md,
    required String ad,
  }) async {
    try {
      final payload = _client.buildBirthPayload(
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );
      final response = await _client.getSubSubVdasha(payload, md, ad);
      return _parseDashaList(response);
    } catch (e) {
      Logger.e('Error fetching sub sub dasha for $md/$ad', error: e);
    }
    return [];
  }

  Future<List<DashaItem>> getSubSubSubDasha({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
    required String md,
    required String ad,
    required String pd,
  }) async {
    try {
      final payload = _client.buildBirthPayload(
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );
      final response = await _client.getSubSubSubVdasha(payload, md, ad, pd);
      return _parseDashaList(response);
    } catch (e) {
      Logger.e('Error fetching sub sub sub dasha for $md/$ad/$pd', error: e);
    }
    return [];
  }

  Future<List<DashaItem>> getSubSubSubSubDasha({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
    required String md,
    required String ad,
    required String pd,
    required String sd,
  }) async {
    try {
      final payload = _client.buildBirthPayload(
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );
      final response = await _client.getSubSubSubSubVdasha(
        payload,
        md,
        ad,
        pd,
        sd,
      );
      return _parseDashaList(response);
    } catch (e) {
      Logger.e(
        'Error fetching sub sub sub sub dasha for $md/$ad/$pd/$sd',
        error: e,
      );
    }
    return [];
  }

  DashaModel? _parseDashaResponse(dynamic response) {
    if (response.statusCode == 200) {
      final list = _parseDashaList(response);
      final transformedJson = {
        'success': true,
        'data': {'maha_dasha': list.map((e) => e.toJson()).toList()},
      };
      return DashaModel.fromJson(transformedJson);
    }
    return null;
  }

  List<DashaItem> _parseDashaList(dynamic response) {
    if (response.statusCode == 200) {
      dynamic rawData = response.data;
      if (rawData is Map && rawData.containsKey('sub_dasha')) {
        rawData = rawData['sub_dasha'];
      } else if (rawData is Map && rawData.containsKey('sub_sub_dasha')) {
        rawData = rawData['sub_sub_dasha'];
      } else if (rawData is Map && rawData.containsKey('sub_sub_sub_dasha')) {
        rawData = rawData['sub_sub_sub_dasha'];
      } else if (rawData is Map &&
          rawData.containsKey('sub_sub_sub_sub_dasha')) {
        rawData = rawData['sub_sub_sub_sub_dasha'];
      }

      final List<dynamic> rawList = rawData is List ? rawData : [rawData];
      return rawList.map((item) {
        if (item is Map<String, dynamic>) {
          return DashaItem.fromJson(item);
        } else if (item is Map) {
          return DashaItem.fromJson(Map<String, dynamic>.from(item));
        }
        return DashaItem();
      }).toList();
    }
    return [];
  }
}
