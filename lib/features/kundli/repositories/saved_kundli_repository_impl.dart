import 'dart:convert';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import '../../../../core/services/network/astrology_api_client.dart';

import '../../../../core/services/network/api_client.dart';
import 'saved_kundli_repository.dart';
import '../models/kundli_request_model.dart';
import '../models/kundli_response_model.dart';
import '../models/create_kundli_request_model.dart';
import '../models/create_kundli_response_model.dart';
import '../models/kundli_list_response_model.dart';
import '../models/kundli_detail_response_model.dart';

class KundliRepositoryImpl implements KundliRepository {
  final ApiClient apiClient;
  final AstrologyApiClient _astroClient;

  KundliRepositoryImpl({required this.apiClient, AstrologyApiClient? astroClient})
      : _astroClient = astroClient ?? AstrologyApiClient();

  @override
  Future<KundliResponseModel> getBirthChart(KundliRequestModel request) async {
    try {
      final payload = _astroClient.buildBirthPayload(
        datetime: request.datetime,
        latitude: request.latitude,
        longitude: request.longitude,
        timezone: '5.5',
      );

      final response = await _astroClient.getBirthChart(payload);

      if (response.statusCode == 200) {
        final Map<String, dynamic> dataMap = response.data is String
            ? jsonDecode(response.data as String) as Map<String, dynamic>
            : response.data as Map<String, dynamic>;
        return KundliResponseModel.fromJson(dataMap);
      } else {
        throw Exception('Failed to load kundli data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching kundli: $e');
    }
  }

  @override
  Future<CreateKundliResponseModel> createKundli(CreateKundliRequestModel request) async {
    try {
      print('[KUNDLI_APP] [DEBUG] Repository: Creating kundli');
      print('[KUNDLI_APP] [DEBUG] Repository: Request data: ${request.toJson()}');
      
      final response = await apiClient.post(
        AppUrls.createKundali,
        data: request.toJson(),
        handleError: false,
        showToaster: false,
      );

      print('[KUNDLI_APP] [DEBUG] Repository: Response: ${response.body}');
      
      if (response.isSuccess) {
        final model = CreateKundliResponseModel.fromJson(response.body as Map<String, dynamic>);
        print('[KUNDLI_APP] [DEBUG] Repository: Kundli created successfully');
        return model;
      } else {
        throw Exception(response.message ?? 'Failed to create kundli');
      }
    } catch (e) {
      print('[KUNDLI_APP] [ERROR] Repository error: $e');
      throw Exception('Error creating kundli: $e');
    }
  }

  @override
  Future<KundliListResponseModel> getKundliList({int perPage = 15}) async {
    try {
      print('[KUNDLI_APP] [DEBUG] Repository: Fetching kundli list');
      
      final response = await apiClient.get(
        '${AppUrls.getKundali}?per_page=$perPage',
        handleError: false,
        showToaster: false,
      );

      print('[KUNDLI_APP] [DEBUG] Repository: Response isSuccess: ${response.isSuccess}');
      print('[KUNDLI_APP] [DEBUG] Repository: Response body type: ${response.body.runtimeType}');
      
      if (response.isSuccess && response.body != null) {
        try {
          // The response.body is already the pagination object (not wrapped in status/message)
          final model = KundliListResponseModel.fromJson(response.body as Map<String, dynamic>);
          print('[KUNDLI_APP] [DEBUG] Repository: Kundli list fetched successfully, count: ${model.data.length}');
          return model;
        } catch (e) {
          print('[KUNDLI_APP] [ERROR] Repository: JSON parsing error: $e');
          rethrow;
        }
      } else {
        throw Exception(response.message ?? 'Failed to fetch kundli list');
      }
    } catch (e) {
      print('[KUNDLI_APP] [ERROR] Repository error: $e');
      throw Exception('Error fetching kundli list: $e');
    }
  }

  @override
  Future<KundliDetailResponseModel> getKundliById(int id) async {
    try {
      print('[KUNDLI_APP] [DEBUG] Repository: Fetching kundli by id: $id');
      
      final response = await apiClient.get(
       // '/api/v1/kundli/$id',
        AppUrls.getKundaliById(id),
        handleError: false,
        showToaster: false,
      );

      print('[KUNDLI_APP] [DEBUG] Repository: Response isSuccess: ${response.isSuccess}');
      print('[KUNDLI_APP] [DEBUG] Repository: Response message: ${response.message}');
      print('[KUNDLI_APP] [DEBUG] Repository: Response body: ${response.body}');
      print('[KUNDLI_APP] [DEBUG] Repository: Response body type: ${response.body.runtimeType}');
      print('[KUNDLI_APP] [DEBUG] Repository: Response statusCode: ${response.statusCode}');
      
      if (response.isSuccess) {
        if (response.body != null) {
          final model = KundliDetailResponseModel.fromJson(response.body as Map<String, dynamic>);
          print('[KUNDLI_APP] [DEBUG] Repository: Kundli fetched successfully: ${model.data.name}');
          return model;
        } else {
          print('[KUNDLI_APP] [ERROR] Repository: Response body is null but isSuccess is true');
          throw Exception('Response body is null');
        }
      } else {
        throw Exception(response.message ?? 'Failed to fetch kundli');
      }
    } catch (e, stackTrace) {
      print('[KUNDLI_APP] [ERROR] Repository error: $e');
      print('[KUNDLI_APP] [ERROR] Stack trace: $stackTrace');
      throw Exception('Error fetching kundli: $e');
    }
  }

  @override
  Future<CreateKundliResponseModel> updateKundli(int id, CreateKundliRequestModel request) async {
    try {
      print('[KUNDLI_APP] [DEBUG] Repository: Updating kundli id: $id');
      print('[KUNDLI_APP] [DEBUG] Repository: Request data: ${request.toJson()}');
      
      final response = await apiClient.put(
        //'/api/v1/kundli/$id',
        AppUrls.updateKundali(id),
        data: request.toJson(),
        handleError: false,
        showToaster: false,
      );

      print('[KUNDLI_APP] [DEBUG] Repository: Response: ${response.body}');
      
      if (response.isSuccess) {
        final model = CreateKundliResponseModel.fromJson(response.body as Map<String, dynamic>);
        print('[KUNDLI_APP] [DEBUG] Repository: Kundli updated successfully');
        return model;
      } else {
        throw Exception(response.message ?? 'Failed to update kundli');
      }
    } catch (e) {
      print('[KUNDLI_APP] [ERROR] Repository error: $e');
      throw Exception('Error updating kundli: $e');
    }
  }

  @override
  Future<void> deleteKundli(int id) async {
    try {
      print('[KUNDLI_APP] [DEBUG] Repository: Deleting kundli id: $id');
      
      final response = await apiClient.delete(
        AppUrls.deleteKundali(id),
       // '/api/v1/kundli/$id',
        handleError: false,
        showToaster: false,
      );

      print('[KUNDLI_APP] [DEBUG] Repository: Response: ${response.body}');
      
      if (!response.isSuccess) {
        throw Exception(response.message ?? 'Failed to delete kundli');
      }
      
      print('[KUNDLI_APP] [DEBUG] Repository: Kundli deleted successfully');
    } catch (e) {
      print('[KUNDLI_APP] [ERROR] Repository error: $e');
      throw Exception('Error deleting kundli: $e');
    }
  }
}