import 'package:get/get.dart';
import '../model/training_videos_model.dart';
import '../usecase/training_video_use_case.dart';
import '../../../core/utils/custom_snackbar.dart';

class TrainingVideoDetailController extends GetxController {
  final GetTrainingVideoDetailUseCase _useCase;

  TrainingVideoDetailController(this._useCase);

  final Rx<TrainingVideoModel?> video = Rx(null);
  RxBool isLoading = false.obs;

  Future<void> fetchVideoDetail(int id) async {
    try {
      isLoading.value = true;
      final response = await _useCase.execute(id);
      if (response.isSuccess && response.body != null) {
        final videoData = response.body['video'];
        if (videoData is Map<String, dynamic>) {
          video.value = TrainingVideoModel.fromJson(videoData);
        }
      } else {
        CustomSnackBar.showError(response.message);
      }
    } catch (e) {
      CustomSnackBar.showError('Failed to load video: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
