import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../controllers/skill_controller.dart';
import '../controllers/other_detail_cotroller.dart';
import '../dataSource/skill_data_source.dart';
import '../repository/skill_repository.dart';
import '../usecase/skill_usecase.dart';

class AstrologerSkillsBinding extends Bindings {
  @override
  void dependencies() {
    final apiClient = Get.find<ApiClient>();
    final remoteDataSource = AstrologerSkillsRemoteDataSource(apiClient);
    final repository = AstrologerSkillsRepository(remoteDataSource);
    final useCase = UpdateAstrologerSkillsUseCase(repository);

    Get.lazyPut(() => AstrologerSkillsController(useCase));
    Get.lazyPut(() => OtherDetailsController(repository: repository));
  }
}