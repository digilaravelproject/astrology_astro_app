import 'package:dio/dio.dart';
import 'package:astro_astrologer/core/constants/vedika_constants.dart';
import '../../domain/repositories/panchang_repository.dart';
import '../models/panchang_model.dart';

class PanchangRepositoryImpl implements PanchangRepository {
  final Dio _dio;

  PanchangRepositoryImpl() : _dio = Dio() {
    _dio.options.baseUrl = VedikaConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  @override
  Future<PanchangModel> getPanchangByDate(
    String date, {
    double? latitude,
    double? longitude,
    double? timezone,
  }) async {
    try {
      print('[PCB_APP] [DEBUG] Repository: Fetching panchang for date: $date from new API');
      
      final response = await _dio.get(
        VedikaConstants.panchangEndpoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': VedikaConstants.apiKey,
          },
        ),
        queryParameters: {
          'date': date,
          'latitude': latitude ?? 28.6139,
          'longitude': longitude ?? 77.209,
          'timezone': timezone ?? 5.5,
        },
      );

      print('[PCB_APP] [DEBUG] Repository: Response status: ${response.statusCode}');
      print('[PCB_APP] [DEBUG] Repository: Response data: ${response.data}');
      
      if (response.statusCode == 200) {
        final model = PanchangModel.fromJson(response.data as Map<String, dynamic>);
        print('[PCB_APP] [DEBUG] Repository: Model created successfully');
        print('[PCB_APP] [DEBUG] Repository: Model success: ${model.success}');
        return model;
      } else {
        throw Exception('Failed to load panchang data: ${response.statusCode}');
      }
    } catch (e) {
      print('[PCB_APP] [ERROR] Repository error: $e');
      throw Exception('Error fetching panchang: $e');
    }
  }
}
