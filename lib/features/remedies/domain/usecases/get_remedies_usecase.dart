import '../../../../core/services/network/response_model.dart';
import '../repositories/remedy_repository_interface.dart';

class GetRemediesUseCase {
  final RemedyRepositoryInterface _repository;

  GetRemediesUseCase(this._repository);

  Future<ResponseModel> call() async {
    return await _repository.getRemedies();
  }
}
