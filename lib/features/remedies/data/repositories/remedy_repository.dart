import '../datasources/remedy_remote_data_source.dart';
import '../../domain/models/remedy_model.dart';

abstract class RemedyRepositoryInterface {
  Future<List<RemedyModel>> getRemedies();
  Future<RemedyModel?> getRemedyDetails(int id);
}

class RemedyRepository implements RemedyRepositoryInterface {
  final RemedyRemoteDataSourceInterface _remoteDataSource;

  RemedyRepository({required RemedyRemoteDataSourceInterface remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<RemedyModel>> getRemedies() async {
    return await _remoteDataSource.getRemedies();
  }

  @override
  Future<RemedyModel?> getRemedyDetails(int id) async {
    return await _remoteDataSource.getRemedyDetails(id);
  }
}
