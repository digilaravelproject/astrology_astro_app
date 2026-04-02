import '../../domain/models/availability_model.dart';
import '../../domain/repositories/availability_repository_interface.dart';
import '../datasources/availability_remote_data_source.dart';
import '../../../../core/services/network/response_model.dart';

class AvailabilityRepository implements AvailabilityRepositoryInterface {
  final AvailabilityRemoteDataSource _remoteDataSource;

  AvailabilityRepository(this._remoteDataSource);

  @override
  Future<ResponseModel> getAvailability() async {
    return await _remoteDataSource.getAvailability();
  }

  @override
  Future<ResponseModel> updateAvailability(List<AvailabilityModel> availability) async {
    return await _remoteDataSource.updateAvailability(availability);
  }
}
