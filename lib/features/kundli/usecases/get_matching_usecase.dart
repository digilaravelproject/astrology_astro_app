import 'package:astro_astrologer/features/kundli/data/models/matching_request_model.dart';
import 'package:astro_astrologer/features/kundli/data/models/matching_response_model.dart';
import 'package:astro_astrologer/features/kundli/repositories/matching_repository.dart';

class GetMatchingUseCase {
  final MatchingRepository repository;

  GetMatchingUseCase({required this.repository});

  Future<MatchingResponseModel> call(MatchingRequestModel request) async {
    return await repository.getMatching(request);
  }
}
