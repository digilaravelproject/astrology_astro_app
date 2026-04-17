import 'package:get/get.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../model/training_videos_model.dart';
import '../usecase/training_video_use_case.dart';

class TrainingVideoController extends GetxController {
  final GetTrainingVideosUseCase _useCase;

  TrainingVideoController(this._useCase);

  RxBool isLoading = false.obs;
  RxList<TrainingVideoModel> videoList = <TrainingVideoModel>[].obs;

  Future<void> fetchVideos({String type = "profile"}) async {
    if (isLoading.value) return;
    try {
      // Use microtask to avoid "setState() called during build" when called from initState
      Future.microtask(() => isLoading.value = true);

      final response = await _useCase.execute(type);

      if (response.isSuccess && response.body != null) {
        // Handle nested 'data' key if present
        final dynamic bodyData = response.body['data'] ?? response.body;
        final dynamic videosData = bodyData['videos'];
        
        final List list = videosData is List
            ? videosData
            : (videosData != null ? [videosData] : []);

        videoList.value =
            list.map((e) => TrainingVideoModel.fromJson(e as Map<String, dynamic>?)).toList();
      } else {
        CustomSnackBar.showError(response.message);
      }
    } catch (e) {
      CustomSnackBar.showError(e.toString());
    } finally {
      Future.microtask(() => isLoading.value = false);
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchVideos();
  }
}