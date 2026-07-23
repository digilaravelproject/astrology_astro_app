import 'dart:convert';

class AstrologyApiConstants {
  static const String baseUrl = 'https://json.astrologyapi.com/v1';
  
  static const String userId = '655788';
  static const String apiKey = 'ak-2e92dd83da6e067eeb157dbf62a5475802e0cbd0';
  
  static String get basicAuth {
    final credentials = '$userId:$apiKey';
    return 'Basic ${base64Encode(utf8.encode(credentials))}';
  }

  static Map<String, String> get authHeaders => {
    'Content-Type': 'application/json',
    'Authorization': basicAuth,
  };

  // Endpoints
  static const String panchangEndpoint = '/advanced_panchang';
  static const String vimshottariDashaEndpoint = '/major_vdasha';
  static const String yoginiDashaEndpoint = '/major_yogini_dasha';
  static const String ashtakavargaEndpoint = '/sarvashtak';
  static const String planetPositionsEndpoint = '/planets';
  static const String shadbalaEndpoint = '/shadbala';
  static const String remediesGemstoneEndpoint = '/basic_gem_suggestion';
  static const String birthChartEndpoint = '/horo_chart/d1';
  static const String navamshaEndpoint = '/horo_chart/d9';
  static const String transitEndpoint = '/planet_transit';
  static const String divisionalChartEndpoint = '/horo_chart';
  static const String houseCuspsEndpoint = '/kp_house_cusps';
  static const String kpFullReportEndpoint = '/kp_planets';
  static const String sadeSatiAdvancedEndpoint = '/sadhesati_current_status';
  static const String sadeSatiLifeDetailsEndpoint = '/sadhesati_life_details';
  static const String matchingAshtakootaEndpoint = '/match_ashtakoot_points';
}
