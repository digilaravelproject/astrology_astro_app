import '../models/remedy_model.dart';
import '../../data/repositories/remedy_repository.dart';

class GetRemediesUseCase {
  final RemedyRepositoryInterface _repository;

  GetRemediesUseCase(this._repository);

  Future<List<RemedyModel>> execute() async {
    return await _repository.getRemedies();
  }
}
