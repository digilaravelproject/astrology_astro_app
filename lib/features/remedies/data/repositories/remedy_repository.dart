import '../../../../core/services/network/response_model.dart';
import '../../domain/models/remedy_model.dart';
import '../../domain/repositories/remedy_repository_interface.dart';
import '../datasources/remedy_remote_data_source.dart';

class RemedyRepository implements RemedyRepositoryInterface {
  final RemedyRemoteDataSource _remoteDataSource;

  RemedyRepository(this._remoteDataSource);

  @override
  Future<ResponseModel> getRemedies() async {
    return await _remoteDataSource.getRemedies();
  }

  @override
  Future<RemedyModel?> getRemedyDetails(int id) async {
    final response = await _remoteDataSource.getRemedyDetails(id);
    if (response.isSuccess) {
      final data = response.body['remedy'] ?? response.body['data'];
      if (data != null) {
        return RemedyModel.fromJson(data);
      }
    }
    return null;
  }
}
