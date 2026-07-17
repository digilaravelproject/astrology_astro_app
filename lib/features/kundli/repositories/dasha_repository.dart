import 'package:dio/dio.dart';
import 'package:astro_astrologer/core/constants/vedika_constants.dart';
import 'package:astro_astrologer/core/utils/logger.dart';
import '../models/dasha_model.dart';
import '../models/yogini_dasha_model.dart';

class DashaRepository {
  final Dio _dio;

  DashaRepository() : _dio = Dio() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        Logger.d('|🌐 DASHA API REQUEST');
        Logger.d('|📍 URL: ${options.baseUrl}${options.path}');
        Logger.d('|🔧 Method: ${options.method}');
        Logger.d('|📋 Headers: ${options.headers}');
        if (options.data != null) {
          Logger.d('|📦 Body: ${options.data}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        Logger.d('|✅ DASHA API RESPONSE');
        Logger.d('|📍 URL: ${response.requestOptions.baseUrl}${response.requestOptions.path}');
        Logger.d('|📊 Status Code: ${response.statusCode}');
        Logger.d('|📨 Response: ${response.data}');
        Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return handler.next(response);
      },
      onError: (error, handler) {
        Logger.e('|❌ DASHA API ERROR');
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

  Future<DashaModel?> getDashaDetails({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    try {
      final response = await _dio.post(
        '${VedikaConstants.baseUrl}${VedikaConstants.vimshottariDashaEndpoint}',
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
          'depth': 1,
        },
      );

      if (response.statusCode == 200) {
        return DashaModel.fromJson(response.data);
      }
    } catch (e) {
      Logger.e('Error fetching dasha details: $e');
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
      final response = await _dio.post(
        '${VedikaConstants.baseUrl}${VedikaConstants.yoginiDashaEndpoint}',
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
        return YoginiDashaModel.fromJson(response.data);
      }
    } catch (e) {
      Logger.e('Error fetching yogini dasha details: $e');
    }
    return null;
  }
}
