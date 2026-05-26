import '../../../../core/services/network/response_model.dart';
import '../../data/repositories/remedy_repository.dart';

class GetRemediesUseCase {
  final RemedyRepository _repository;

  GetRemediesUseCase(this._repository);

  Future<ResponseModel> call() async {
    return await _repository.getRemedies();
  }
}
