import '../../../../core/services/network/response_model.dart';
import '../datasources/remedy_remote_data_source.dart';

class RemedyRepository {
  final RemedyRemoteDataSource _remoteDataSource;

  RemedyRepository(this._remoteDataSource);

  Future<ResponseModel> getRemedies() async {
    return await _remoteDataSource.getRemedies();
  }
}
