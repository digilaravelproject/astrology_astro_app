import 'dart:convert';
import '../../../../core/services/network/astrology_api_client.dart';
import 'matching_repository.dart';
import '../models/matching_request_model.dart';
import '../models/matching_response_model.dart';

class MatchingRepositoryImpl implements MatchingRepository {
  final AstrologyApiClient _client;

  MatchingRepositoryImpl({AstrologyApiClient? client})
      : _client = client ?? AstrologyApiClient();

  Map<String, dynamic> _buildPersonPayload(PersonDetails details, String prefix) {
    DateTime dt;
    try {
      dt = DateTime.parse(details.datetime);
    } catch (_) {
      dt = DateTime.now();
    }
    
    double tzOffset = 5.5;
    try {
      final sign = details.timezone.startsWith('-') ? -1 : 1;
      final parts = details.timezone.replaceAll('+', '').replaceAll('-', '').split(':');
      tzOffset = sign * (double.parse(parts[0]) + (parts.length > 1 ? double.parse(parts[1]) / 60 : 0));
    } catch (_) {}

    return {
      '${prefix}day': dt.day,
      '${prefix}month': dt.month,
      '${prefix}year': dt.year,
      '${prefix}hour': dt.hour,
      '${prefix}min': dt.minute,
      '${prefix}lat': details.latitude,
      '${prefix}lon': details.longitude,
      '${prefix}tzone': tzOffset,
    };
  }

  @override
  Future<MatchingResponseModel> getMatching(MatchingRequestModel request) async {
    try {
      final malePayload = _buildPersonPayload(request.male, 'm_');
      final femalePayload = _buildPersonPayload(request.female, 'f_');
      final payload = {...malePayload, ...femalePayload};

      final response = await _client.getMatching(payload);

      if (response.statusCode == 200) {
        final Map<String, dynamic> dataMap = response.data is String
            ? jsonDecode(response.data as String) as Map<String, dynamic>
            : response.data as Map<String, dynamic>;
        return MatchingResponseModel.fromJson(dataMap);
      } else {
        throw Exception('Failed to load matching data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching matching: $e');
    }
  }
}
