import '../../../../core/services/network/response_model.dart';

abstract class ScheduleRepositoryInterface {
  Future<ResponseModel> setSleepHours(String startTime, String endTime);
  Future<ResponseModel> getSleepHours();
}