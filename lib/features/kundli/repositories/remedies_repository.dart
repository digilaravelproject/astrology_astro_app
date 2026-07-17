import 'package:dio/dio.dart';
import 'package:astro_astrologer/core/constants/vedika_constants.dart';
import 'package:astro_astrologer/core/utils/logger.dart';
import '../models/remedies_model.dart';

class RemediesRepository {
  final Dio _dio;

  RemediesRepository() : _dio = Dio() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        Logger.d('|🌐 REMEDIES API REQUEST');
        Logger.d('|📍 URL: ${options.baseUrl}${options.path}');
        Logger.d('|🔧 Method: ${options.method}');
        Logger.d('|📋 Headers: ${options.headers}');
        if (options.data != null) {
          Logger.d('|📦 Body: ${options.data}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        Logger.d('|✅ REMEDIES API RESPONSE');
        Logger.d('|📍 URL: ${response.requestOptions.baseUrl}${response.requestOptions.path}');
        Logger.d('|📊 Status Code: ${response.statusCode}');
        Logger.d('|📨 Response: ${response.data}');
        Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return handler.next(response);
      },
      onError: (error, handler) {
        Logger.e('|❌ REMEDIES API ERROR');
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

  Future<RemediesModel?> getGemstoneRemedies({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    try {
      final response = await _dio.post(
        '${VedikaConstants.baseUrl}${VedikaConstants.remediesGemstoneEndpoint}',
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
        },
      );

      if (response.statusCode == 200) {
        return RemediesModel.fromJson(response.data);
      }
    } catch (e) {
      Logger.e('Error fetching gemstone remedies details: $e');
    }
    return null;
  }
}
