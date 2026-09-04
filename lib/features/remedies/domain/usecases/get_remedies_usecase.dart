import 'package:astro_astrologer/core/services/network/response_model.dart';
import 'package:astro_astrologer/features/remedies/domain/repositories/remedy_repository_interface.dart';

class GetRemediesUseCase {
  final RemedyRepositoryInterface _repository;

  GetRemediesUseCase(this._repository);

  Future<ResponseModel> call() async {
    return await _repository.getRemedies();
  }
}
