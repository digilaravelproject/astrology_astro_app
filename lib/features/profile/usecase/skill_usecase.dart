import 'package:astro_astrologer/features/profile/model/other_details_model.dart';
import 'package:astro_astrologer/features/profile/model/skill_model.dart';
import 'package:astro_astrologer/core/services/network/response_model.dart';
import 'package:astro_astrologer/features/profile/repository/skill_repository.dart';

class UpdateAstrologerSkillsUseCase {
  final AstrologerSkillsRepository _repository;
  UpdateAstrologerSkillsUseCase(this._repository);

  Future<ResponseModel> execute(AstrologerSkillsModel skills) async {
    return await _repository.updateSkills(skills);
  }
}
