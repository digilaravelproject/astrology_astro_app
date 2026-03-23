import 'package:dio/dio.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/services/network/response_model.dart';
import '../model/skill_model.dart';

class AstrologerSkillsRemoteDataSource {
  final ApiClient _apiClient;
  AstrologerSkillsRemoteDataSource(this._apiClient);

  Future<ResponseModel> updateSkills(AstrologerSkillsModel data) async {
    return await _apiClient.put(
      '/api/v1/astrologer/profile/skills',
      data: data.toJson(),
    );
  }
}