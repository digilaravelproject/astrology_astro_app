import 'package:astro_astrologer/features/profile/data/models/availability_model.dart';
import 'package:astro_astrologer/features/profile/domain/repositories/availability_repository_interface.dart';
import 'package:astro_astrologer/core/services/network/response_model.dart';

class UpdateAvailabilityUseCase {
  final AvailabilityRepositoryInterface _repository;

  UpdateAvailabilityUseCase(this._repository);

  Future<ResponseModel> call(List<AvailabilityModel> availability) async {
    return await _repository.updateAvailability(availability);
  }
}
