import '../models/availability_model.dart';
import '../repositories/availability_repository_interface.dart';
import '../../../../core/services/network/response_model.dart';

class UpdateAvailabilityUseCase {
  final AvailabilityRepositoryInterface _repository;

  UpdateAvailabilityUseCase(this._repository);

  Future<ResponseModel> call(List<AvailabilityModel> availability) async {
    return await _repository.updateAvailability(availability);
  }
}
