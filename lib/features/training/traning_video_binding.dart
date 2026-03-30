import 'package:astro_astrologer/features/training/repository/training_video_repository.dart';
import 'package:astro_astrologer/features/training/usecase/training_video_use_case.dart';
import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import 'controller/training_video_controller.dart';
import 'controller/training_video_detail_controller.dart';
import 'dataSource/training_video_data_source.dart';

class TrainingVideoBinding extends Bindings {
  @override
  void dependencies() {
    final apiClient = Get.find<ApiClient>();

    final dataSource = TrainingVideoRemoteDataSource(apiClient);
    final repository = TrainingVideoRepository(dataSource);

    final listUseCase = GetTrainingVideosUseCase(repository);
    final detailUseCase = GetTrainingVideoDetailUseCase(repository);

    Get.lazyPut(() => TrainingVideoController(listUseCase), fenix: true);
    Get.lazyPut(() => TrainingVideoDetailController(detailUseCase), fenix: true);

  }
}