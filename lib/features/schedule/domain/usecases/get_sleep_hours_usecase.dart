import 'package:astro_astrologer/features/schedule/domain/repositories/schedule_repository_interface.dart';
import 'package:astro_astrologer/core/services/network/response_model.dart';

class GetSleepHoursUseCase {
  final ScheduleRepositoryInterface _repository;

  GetSleepHoursUseCase(this._repository);

  Future<ResponseModel> execute() async {
    return await _repository.getSleepHours();
  }
}
