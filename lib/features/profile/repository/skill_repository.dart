import 'package:astro_astrologer/features/profile/dataSource/skill_data_source.dart';
import 'package:astro_astrologer/features/profile/model/skill_model.dart';
import 'package:astro_astrologer/core/services/network/response_model.dart';

class AstrologerSkillsRepository {
  final AstrologerSkillsRemoteDataSource _remoteDataSource;
  AstrologerSkillsRepository(this._remoteDataSource);

  Future<ResponseModel> updateSkills(AstrologerSkillsModel skills) async {
    return await _remoteDataSource.updateSkills(skills);
  }

  Future<ResponseModel> updateOtherDetails(Map<String, dynamic> data) async {
    return await _remoteDataSource.updateOtherDetails(data);
  }
}
