import '../../domain/repositories/schedule_repository_interface.dart';
import '../datasources/schedule_remote_data_source.dart';
import '../../../../core/services/network/response_model.dart';

class ScheduleRepository implements ScheduleRepositoryInterface {
  final ScheduleRemoteDataSource _remoteDataSource;

  ScheduleRepository(this._remoteDataSource);

  @override
  Future<ResponseModel> setSleepHours(String startTime, String endTime) async {
    return await _remoteDataSource.setSleepHours(startTime, endTime);
  }

  @override
  Future<ResponseModel> getSleepHours() async {
    return await _remoteDataSource.getSleepHours();
  }
}