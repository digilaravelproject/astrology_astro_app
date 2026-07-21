import 'package:dio/dio.dart';
import 'package:astro_astrologer/core/constants/vedika_constants.dart';
import 'package:astro_astrologer/core/utils/logger.dart';
import '../models/panchang_model.dart';

class PanchangRepository {
  final Dio _dio;

  PanchangRepository() : _dio = Dio() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        Logger.d('|🌐 PANCHANG API REQUEST');
        Logger.d('|📍 URL: ${options.baseUrl}${options.path}');
        Logger.d('|🔧 Method: ${options.method}');
        Logger.d('|📋 Headers: ${options.headers}');
        if (options.data != null) {
          Logger.d('|📦 Body: ${options.data}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        Logger.d('|✅ PANCHANG API RESPONSE');
        Logger.d('|📍 URL: ${response.requestOptions.baseUrl}${response.requestOptions.path}');
        Logger.d('|📊 Status Code: ${response.statusCode}');
        Logger.d('|📨 Response: ${response.data}');
        Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return handler.next(response);
      },
      onError: (error, handler) {
        Logger.e('|❌ PANCHANG API ERROR');
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

  Future<PanchangModel?> getPanchangDetails({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    try {
      // Extract just the date part (YYYY-MM-DD) — Vedika returns sunrise/sunset via GET+date
      final date = datetime.contains('T') ? datetime.split('T')[0] : datetime;

      // Convert timezone string (e.g. "+05:30") to decimal offset (e.g. 5.5)
      double tzOffset = 5.5;
      try {
        final sign = timezone.startsWith('-') ? -1 : 1;
        final parts = timezone.replaceAll('+', '').replaceAll('-', '').split(':');
        tzOffset = sign * (double.parse(parts[0]) + (parts.length > 1 ? double.parse(parts[1]) / 60 : 0));
      } catch (_) {}

      final response = await _dio.get(
        '${VedikaConstants.baseUrl}${VedikaConstants.panchangEndpoint}',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': VedikaConstants.apiKey,
          },
        ),
        queryParameters: {
          'date': date,
          'latitude': latitude,
          'longitude': longitude,
          'timezone': tzOffset,
        },
      );

      if (response.statusCode == 200) {
        return PanchangModel.fromJson(response.data);
      }
    } catch (e) {
      print('Error fetching panchang details: $e');
    }
    return null;
  }
}
