import 'package:dio/dio.dart';
import '../../../../core/constants/vedika_constants.dart';
import '../../../../core/utils/logger.dart';
import '../models/sade_sati_model.dart';

class SadeSatiRepository {
  final Dio _dio;

  SadeSatiRepository() : _dio = Dio() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        Logger.d('|🌐 SADE SATI API REQUEST');
        Logger.d('|📍 URL: ${options.baseUrl}${options.path}');
        Logger.d('|🔧 Method: ${options.method}');
        Logger.d('|📋 Headers: ${options.headers}');
        if (options.data != null) {
          Logger.d('|📦 Body: ${options.data}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        Logger.d('|✅ SADE SATI API RESPONSE');
        Logger.d('|📍 URL: ${response.requestOptions.baseUrl}${response.requestOptions.path}');
        Logger.d('|📊 Status Code: ${response.statusCode}');
        Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return handler.next(response);
      },
      onError: (error, handler) {
        Logger.e('|❌ SADE SATI API ERROR');
        Logger.e('|📍 URL: ${error.requestOptions.baseUrl}${error.requestOptions.path}');
        Logger.e('|🔧 Method: ${error.requestOptions.method}');
        Logger.e('|⚠️ Error Type: ${error.type}');
        Logger.e('|💬 Error Message: ${error.message}');
        if (error.response != null) {
          Logger.e('|📊 Status Code: ${error.response?.statusCode}');
        }
        Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return handler.next(error);
      },
    ));
  }

  Future<SadeSatiModel?> getSadeSati({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    try {
      final response = await _dio.post(
        '${VedikaConstants.baseUrl}${VedikaConstants.sadeSatiAdvancedEndpoint}',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': VedikaConstants.apiKey,
          },
        ),
        data: {
          "datetime": datetime,
          "latitude": latitude,
          "longitude": longitude,
          "timezone": timezone,
        },
      );

      if (response.statusCode == 200) {
        return SadeSatiModel.fromJson(response.data);
      }
    } catch (e) {
      Logger.e('Error fetching sade sati advanced', error: e);
    }
    return null;
  }
}
