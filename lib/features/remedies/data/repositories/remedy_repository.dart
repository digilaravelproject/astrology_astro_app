import 'package:astro_astrologer/core/services/network/response_model.dart';
import 'package:astro_astrologer/features/remedies/data/models/remedy_model.dart';
import 'package:astro_astrologer/features/remedies/domain/repositories/remedy_repository_interface.dart';
import 'package:astro_astrologer/features/remedies/data/datasources/remedy_remote_data_source.dart';

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
