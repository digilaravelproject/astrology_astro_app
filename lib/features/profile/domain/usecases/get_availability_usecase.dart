import 'package:astro_astrologer/features/profile/domain/repositories/availability_repository_interface.dart';
import 'package:astro_astrologer/core/services/network/response_model.dart';

class GetAvailabilityUseCase {
  final AvailabilityRepositoryInterface _repository;

  GetAvailabilityUseCase(this._repository);

  Future<ResponseModel> call() async {
    return await _repository.getAvailability();
  }
}
