import 'package:dio/dio.dart';
import 'package:astro_astrologer/core/constants/vedika_constants.dart';
import 'package:astro_astrologer/core/utils/logger.dart';
import '../models/planet_positions_model.dart';

class PlanetPositionsRepository {
  final Dio _dio;

  PlanetPositionsRepository() : _dio = Dio() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        Logger.d('|🌐 PLANET POSITIONS API REQUEST');
        Logger.d('|📍 URL: ${options.baseUrl}${options.path}');
        Logger.d('|🔧 Method: ${options.method}');
        Logger.d('|📋 Headers: ${options.headers}');
        if (options.data != null) {
          Logger.d('|📦 Body: ${options.data}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        Logger.d('|✅ PLANET POSITIONS API RESPONSE');
        Logger.d('|📍 URL: ${response.requestOptions.baseUrl}${response.requestOptions.path}');
        Logger.d('|📊 Status Code: ${response.statusCode}');
        Logger.d('|📨 Response: ${response.data}');
        Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return handler.next(response);
      },
      onError: (error, handler) {
        Logger.e('|❌ PLANET POSITIONS API ERROR');
        Logger.e('|📍 URL: ${error.requestOptions.baseUrl}${error.requestOptions.path}');
        Logger.e('|🔧 Method: ${error.requestOptions.method}');
        Logger.e('|⚠️ Error Type: ${error.type}');
        Logger.e('|💬 Error Message: ${error.message}');
        if (error.response != null) {
          Logger.e('|📊 Status Code: ${error.response?.statusCode}');
          Logger.e('|📨 Response: ${error.response?.data}');
        }
        Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return handler.next(error);
      },
    ));
  }

  Future<PlanetPositionsModel?> getPlanetPositions({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    try {
      final response = await _dio.post(
        '${VedikaConstants.baseUrl}${VedikaConstants.planetPositionsEndpoint}',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': VedikaConstants.apiKey,
          },
        ),
        data: {
          'datetime': datetime,
          'latitude': latitude,
          'longitude': longitude,
          'timezone': timezone,
          'ayanamsa': 'lahiri',
        },
      );

      if (response.statusCode == 200) {
        return PlanetPositionsModel.fromJson(response.data);
      }
    } catch (e) {
      Logger.e('Error fetching planet positions: $e');
    }
    return null;
  }
}
