import 'package:get/get.dart';
import 'package:astro_astrologer/features/profile/usecase/review_usecases.dart';
import 'package:astro_astrologer/features/profile/model/review_model.dart';
import 'package:astro_astrologer/features/auth/controllers/auth_controller.dart';
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';
import '../../../../core/utils/logger.dart';

class ReviewController extends GetxController {
  final GetReviewsUseCase getReviewsUseCase;
  final PostReplyUseCase postReplyUseCase;

  ReviewController({
    required this.getReviewsUseCase,
    required this.postReplyUseCase,
  });

  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isReplying = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    final authController = Get.find<AuthController>();
    final astrologerId = authController.currentUser.value?.astrologer?.id;

    if (astrologerId == null) {
      Logger.e('ReviewController: Astrologer ID not found');
      return;
    }

    isLoading.value = true;
    try {
      final result = await getReviewsUseCase.execute(astrologerId);
      reviews.assignAll(result);
      Logger.d('ReviewController: Fetched ${reviews.length} reviews');
    } catch (e) {
      Logger.e('ReviewController: Error fetching reviews: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitReply(int reviewId, String reply) async {
    if (reply.trim().isEmpty) {
      CustomSnackBar.showError('Please enter a reply');
      return;
    }

    isReplying.value = true;
    try {
      final response = await postReplyUseCase.execute(reviewId, reply);
      if (response.isSuccess) {
        CustomSnackBar.showSuccess(response.message);
        Get.back(); // Close dialog
        await fetchReviews(); // Refresh list
      } else {
        CustomSnackBar.showError(response.message);
      }
    } catch (e) {
      Logger.e('ReviewController: Error submitting reply: $e');
      CustomSnackBar.showError('Failed to submit reply');
    } finally {
      isReplying.value = false;
    }
  }

  double get averageRating {
    if (reviews.isEmpty) return 0.0;
    double sum = reviews.fold(0.0, (prev, element) => prev + element.rating);
    return sum / reviews.length;
  }
}
