import '../repositories/availability_repository_interface.dart';
import '../../../../core/services/network/response_model.dart';

class GetAvailabilityUseCase {
  final AvailabilityRepositoryInterface _repository;

  GetAvailabilityUseCase(this._repository);

  Future<ResponseModel> call() async {
    return await _repository.getAvailability();
  }
}
