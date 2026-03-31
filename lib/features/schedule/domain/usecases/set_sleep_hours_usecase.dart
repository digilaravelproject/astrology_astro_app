import '../repositories/schedule_repository_interface.dart';
import '../../../../core/services/network/response_model.dart';

class SetSleepHoursUseCase {
  final ScheduleRepositoryInterface _repository;

  SetSleepHoursUseCase(this._repository);

  Future<ResponseModel> execute(String startTime, String endTime) async {
    return await _repository.setSleepHours(startTime, endTime);
  }
}