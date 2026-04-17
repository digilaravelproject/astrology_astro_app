import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/services/network/response_model.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';

class ReviewRepository {
  final ApiClient apiClient;

  ReviewRepository({required this.apiClient});

  Future<ResponseModel> getReviews(int astrologerId) async {
    return await apiClient.get('${AppUrls.reviewList}?astrologer_id=$astrologerId');
  }

  Future<ResponseModel> postReply(int reviewId, String reply) async {
    return await apiClient.post(AppUrls.replyReview(reviewId), data: {'reply': reply});
  }
}
