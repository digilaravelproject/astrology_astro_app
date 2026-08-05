import '../models/matching_request_model.dart';
import '../models/matching_response_model.dart';

abstract class MatchingRepository {
  Future<MatchingResponseModel> getMatching(MatchingRequestModel request);
}
