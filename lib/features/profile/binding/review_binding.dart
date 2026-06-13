import 'package:get/get.dart';
import 'package:astro_astrologer/features/profile/repository/review_repository.dart';
import 'package:astro_astrologer/features/profile/usecase/review_usecases.dart';
import 'package:astro_astrologer/features/profile/controllers/review_controller.dart';
import '../../../../core/services/network/api_client.dart';

class ReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReviewRepository(apiClient: Get.find<ApiClient>()));
    Get.lazyPut(() => GetReviewsUseCase(repository: Get.find<ReviewRepository>()));
    Get.lazyPut(() => PostReplyUseCase(repository: Get.find<ReviewRepository>()));
    Get.lazyPut(() => ReviewController(
      getReviewsUseCase: Get.find<GetReviewsUseCase>(),
      postReplyUseCase: Get.find<PostReplyUseCase>(),
    ), fenix: true);
  }
}
