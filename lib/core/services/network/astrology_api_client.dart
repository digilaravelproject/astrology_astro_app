import 'package:dio/dio.dart';
import '../../constants/astrology_api_constants.dart';
import '../../utils/logger.dart';

class AstrologyApiClient {
  final Dio _dio;

  AstrologyApiClient({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = AstrologyApiConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = AstrologyApiConstants.authHeaders;

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          Logger.d('|🌐 ASTROLOGY API SDK REQUEST');
          Logger.d('|📍 Endpoint: ${options.path}');
          Logger.d('|📋 Headers: ${options.headers}');
          if (options.data != null) {
            Logger.d('|📦 Payload: ${options.data}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          Logger.d('|✅ ASTROLOGY API SDK RESPONSE');
          Logger.d('|📍 Endpoint: ${response.requestOptions.path}');
          Logger.d('|📊 Status: ${response.statusCode}');
          Logger.d('|📨 Data: ${response.data}');
          Logger.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          return handler.next(response);
        },
        onError: (error, handler) {
          Logger.e('|❌ ASTROLOGY API SDK ERROR');
          Logger.e('|📍 Endpoint: ${error.requestOptions.path}');
          Logger.e('|💬 Message: ${error.message}');
          if (error.response != null) {
            Logger.e('|📊 Status: ${error.response?.statusCode}');
            Logger.e('|📨 Response: ${error.response?.data}');
          }
          Logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          return handler.next(error);
        },
      ),
    );
  }

  Map<String, dynamic> buildBirthPayload({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) {
    DateTime dt;
    try {
      dt = DateTime.parse(datetime);
    } catch (_) {
      dt = DateTime.now();
    }

    double tzOffset = 5.5;
    try {
      final sign = timezone.startsWith('-') ? -1 : 1;
      final parts = timezone.replaceAll('+', '').replaceAll('-', '').split(':');
      tzOffset =
          sign *
          (double.parse(parts[0]) +
              (parts.length > 1 ? double.parse(parts[1]) / 60 : 0));
    } catch (_) {}

    return {
      'day': dt.day,
      'month': dt.month,
      'year': dt.year,
      'hour': dt.hour,
      'min': dt.minute,
      'lat': latitude,
      'lon': longitude,
      'tzone': tzOffset,
      'theme_name': 'detailed',
    };
  }

  // SDK Methods
  Future<Response> getMatching(Map<String, dynamic> payload) {
    return _dio.post(
      AstrologyApiConstants.matchingAshtakootaEndpoint,
      data: payload,
    );
  }

  Future<Response> getBirthChart(Map<String, dynamic> payload) {
    return _dio.post(AstrologyApiConstants.birthChartEndpoint, data: payload);
  }

  Future<Response> getHoroChartImage(
    String chartId,
    Map<String, dynamic> payload, {
    String chartType = 'north',
  }) {
    final body = Map<String, dynamic>.from(payload);
    body['chartType'] = chartType;
    body['image_type'] = 'svg';
    return _dio.post(
      '${AstrologyApiConstants.horoChartImageEndpoint}/${chartId.toLowerCase()}',
      data: body,
    );
  }

  Future<Response> getDivisionalChart(
    String chartType,
    Map<String, dynamic> payload,
  ) {
    return _dio.post(
      '${AstrologyApiConstants.divisionalChartEndpoint}/${chartType.toLowerCase()}',
      data: payload,
    );
  }

  Future<Response> getPanchang(Map<String, dynamic> payload) {
    return _dio.post(AstrologyApiConstants.panchangEndpoint, data: payload);
  }

  Future<Response> getVimshottariDasha(Map<String, dynamic> payload) {
    return _dio.post(
      AstrologyApiConstants.vimshottariDashaEndpoint,
      data: payload,
    );
  }

  Future<Response> getPlanetPositions(Map<String, dynamic> payload) {
    return _dio.post(
      AstrologyApiConstants.planetPositionsEndpoint,
      data: payload,
    );
  }

  Future<Response> getShadbala(Map<String, dynamic> payload) {
    return _dio.post(AstrologyApiConstants.shadbalaEndpoint, data: payload);
  }

  Future<Response> getGemstoneRemedies(Map<String, dynamic> payload) {
    return _dio.post(
      AstrologyApiConstants.remediesGemstoneEndpoint,
      data: payload,
    );
  }

  Future<Response> getKpHouseCusps(Map<String, dynamic> payload) {
    return _dio.post(AstrologyApiConstants.houseCuspsEndpoint, data: payload);
  }

  Future<Response> getKpPlanets(Map<String, dynamic> payload) {
    return _dio.post(AstrologyApiConstants.kpFullReportEndpoint, data: payload);
  }

  Future<Response> getSadhesatiStatus(Map<String, dynamic> payload) {
    return _dio.post(
      AstrologyApiConstants.sadeSatiAdvancedEndpoint,
      data: payload,
    );
  }

  Future<Response> getSadhesatiLifeDetails(Map<String, dynamic> payload) {
    return _dio.post(
      AstrologyApiConstants.sadeSatiLifeDetailsEndpoint,
      data: payload,
    );
  }

  Future<Response> getManglikReport(Map<String, dynamic> payload) {
    return _dio.post(AstrologyApiConstants.manglikEndpoint, data: payload);
  }

  Future<Response> getSubVdasha(Map<String, dynamic> payload, String md) {
    return _dio.post(
      '${AstrologyApiConstants.subVdashaEndpoint}/$md',
      data: payload,
    );
  }

  Future<Response> getSubSubVdasha(
    Map<String, dynamic> payload,
    String md,
    String ad,
  ) {
    return _dio.post(
      '${AstrologyApiConstants.subSubVdashaEndpoint}/$md/$ad',
      data: payload,
    );
  }

  Future<Response> getSubSubSubVdasha(
    Map<String, dynamic> payload,
    String md,
    String ad,
    String pd,
  ) {
    return _dio.post(
      '${AstrologyApiConstants.subSubSubVdashaEndpoint}/$md/$ad/$pd',
      data: payload,
    );
  }

  Future<Response> getSubSubSubSubVdasha(
    Map<String, dynamic> payload,
    String md,
    String ad,
    String pd,
    String sd,
  ) {
    return _dio.post(
      '${AstrologyApiConstants.subSubSubSubVdashaEndpoint}/$md/$ad/$pd/$sd',
      data: payload,
    );
  }
}
