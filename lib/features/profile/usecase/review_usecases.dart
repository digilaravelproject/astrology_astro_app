import 'package:astro_astrologer/features/profile/repository/review_repository.dart';
import 'package:astro_astrologer/features/profile/model/review_model.dart';
import 'package:astro_astrologer/core/services/network/response_model.dart';
import '../../../../core/utils/logger.dart';

class GetReviewsUseCase {
  final ReviewRepository repository;

  GetReviewsUseCase({required this.repository});

  Future<List<ReviewModel>> execute(int astrologerId) async {
    try {
      final response = await repository.getReviews(astrologerId);
      if (response.isSuccess) {
        final List<dynamic> reviewsList = response.body['reviews'] ?? [];
        return reviewsList.map((json) => ReviewModel.fromJson(json)).toList();
      } else {
        Logger.e('Failed to fetch reviews: ${response.message}');
        return [];
      }
    } catch (e) {
      Logger.e('Error in GetReviewsUseCase: $e');
      return [];
    }
  }
}

class PostReplyUseCase {
  final ReviewRepository repository;

  PostReplyUseCase({required this.repository});

  Future<ResponseModel> execute(int reviewId, String reply) async {
    try {
      return await repository.postReply(reviewId, reply);
    } catch (e) {
      Logger.e('Error in PostReplyUseCase: $e');
      return ResponseModel(isSuccess: false, message: 'Something went wrong');
    }
  }
}
