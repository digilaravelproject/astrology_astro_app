import 'dart:convert';
import 'package:astro_astrologer/core/services/network/astrology_api_client.dart';
import 'package:astro_astrologer/features/panchang/domain/repositories/panchang_repository.dart';
import 'package:astro_astrologer/features/panchang/data/models/panchang_model.dart';

class PanchangRepositoryImpl implements PanchangRepository {
  final AstrologyApiClient _client;

  PanchangRepositoryImpl({AstrologyApiClient? client})
    : _client = client ?? AstrologyApiClient();

  @override
  Future<PanchangModel> getPanchangByDate(
    String date, {
    double? latitude,
    double? longitude,
    double? timezone,
  }) async {
    try {
      final payload = _client.buildBirthPayload(
        datetime: date,
        latitude: (latitude == null || latitude == 0.0) ? 28.6139 : latitude,
        longitude:
            (longitude == null || longitude == 0.0) ? 77.2090 : longitude,
        timezone: (timezone ?? 5.5).toString(),
      );

      final response = await _client.getPanchang(payload);

      if (response.statusCode == 200) {
        final Map<String, dynamic> dataMap =
            response.data is String
                ? jsonDecode(response.data as String) as Map<String, dynamic>
                : response.data as Map<String, dynamic>;
        return PanchangModel.fromJson(dataMap);
      } else {
        throw Exception('Failed to load panchang data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching panchang: $e');
    }
  }
}
