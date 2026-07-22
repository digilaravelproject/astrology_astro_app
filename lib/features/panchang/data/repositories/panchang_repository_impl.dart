import 'dart:convert';
import '../../../../core/services/network/astrology_api_client.dart';
import '../../domain/repositories/panchang_repository.dart';
import '../models/panchang_model.dart';

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
        latitude: latitude ?? 28.6139,
        longitude: longitude ?? 77.209,
        timezone: (timezone ?? 5.5).toString(),
      );

      final response = await _client.getPanchang(payload);

      if (response.statusCode == 200) {
        final Map<String, dynamic> dataMap = response.data is String
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
