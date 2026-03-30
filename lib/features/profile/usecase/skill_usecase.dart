import '../model/other_details_model.dart';
import '../model/skill_model.dart';
import '../../../core/services/network/response_model.dart';
import '../repository/skill_repository.dart';

class UpdateAstrologerSkillsUseCase {
  final AstrologerSkillsRepository _repository;
  UpdateAstrologerSkillsUseCase(this._repository);

  Future<ResponseModel> execute(AstrologerSkillsModel skills) async {
    return await _repository.updateSkills(skills);
  }
  
}