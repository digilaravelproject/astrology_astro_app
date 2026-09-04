import 'package:astro_astrologer/features/remedies/data/models/remedy_model.dart';
import 'package:astro_astrologer/features/remedies/domain/repositories/remedy_repository_interface.dart';

class GetRemedyDetailsUseCase {
  final RemedyRepositoryInterface _repository;

  GetRemedyDetailsUseCase(this._repository);

  Future<RemedyModel?> execute(int id) async {
    return await _repository.getRemedyDetails(id);
  }
}
