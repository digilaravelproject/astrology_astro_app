import 'package:get/get.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/features/profile/presentation/controllers/skill_controller.dart';
import 'package:astro_astrologer/features/profile/presentation/controllers/other_detail_cotroller.dart';
import 'package:astro_astrologer/features/profile/dataSource/skill_data_source.dart';
import 'package:astro_astrologer/features/profile/repository/skill_repository.dart';
import 'package:astro_astrologer/features/profile/usecase/skill_usecase.dart';

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
