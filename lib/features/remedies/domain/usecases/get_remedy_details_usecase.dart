import '../models/remedy_model.dart';
import '../repositories/remedy_repository_interface.dart';

class GetRemedyDetailsUseCase {
  final RemedyRepositoryInterface _repository;

  GetRemedyDetailsUseCase(this._repository);

  Future<RemedyModel?> execute(int id) async {
    return await _repository.getRemedyDetails(id);
  }
}
