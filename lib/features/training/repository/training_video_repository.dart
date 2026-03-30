import '../dataSource/training_video_data_source.dart';
import '../../../core/services/network/response_model.dart';

class TrainingVideoRepository {
  final TrainingVideoRemoteDataSource _remoteDataSource;

  TrainingVideoRepository(this._remoteDataSource);

  Future<ResponseModel> getTrainingVideos(String type) async {
    return await _remoteDataSource.getTrainingVideos(type);
  }

  Future<ResponseModel> getTrainingVideoDetail(int id) async {
    return await _remoteDataSource.getTrainingVideoDetail(id);
  }
}