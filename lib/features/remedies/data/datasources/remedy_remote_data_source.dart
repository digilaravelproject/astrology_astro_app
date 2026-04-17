import '../../../../core/services/network/api_client.dart';
import '../../../../core/constants/app_urls.dart';
import '../../domain/models/remedy_model.dart';

abstract class RemedyRemoteDataSourceInterface {
  Future<List<RemedyModel>> getRemedies();
  Future<RemedyModel?> getRemedyDetails(int id);
}

class RemedyRemoteDataSource implements RemedyRemoteDataSourceInterface {
  final ApiClient _apiClient;

  RemedyRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<RemedyModel>> getRemedies() async {
    final response = await _apiClient.get(AppUrls.remedies);
    if (response.statusCode == 200) {
      final data = response.body;
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data.containsKey('remedies')) {
        list = data['remedies'];
      } else if (data is Map && data.containsKey('data')) {
        list = data['data'];
      } else {
        list = [];
      }
      return list.map((json) => RemedyModel.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<RemedyModel?> getRemedyDetails(int id) async {
    final response = await _apiClient.get(AppUrls.remedyDetails(id));
    if (response.statusCode == 200) {
      final data = response.body;
      if (data is Map) {
        final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(data);
        if (jsonMap.containsKey('remedy')) {
          return RemedyModel.fromJson(jsonMap['remedy']);
        } else if (jsonMap.containsKey('data')) {
          final nestedData = jsonMap['data'];
          if (nestedData is Map && nestedData.containsKey('remedy')) {
            return RemedyModel.fromJson(Map<String, dynamic>.from(nestedData['remedy']));
          }
          return RemedyModel.fromJson(Map<String, dynamic>.from(nestedData));
        }
        return RemedyModel.fromJson(jsonMap);
      }
    }
    return null;
  }
}
