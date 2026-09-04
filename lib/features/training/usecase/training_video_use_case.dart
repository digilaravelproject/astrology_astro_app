import 'package:astro_astrologer/core/services/network/response_model.dart';
import 'package:astro_astrologer/features/training/repository/training_video_repository.dart';

class GetTrainingVideosUseCase {
  final TrainingVideoRepository _repository;

  GetTrainingVideosUseCase(this._repository);

  Future<ResponseModel> execute(String type) async {
    return await _repository.getTrainingVideos(type);
  }
}

class GetTrainingVideoDetailUseCase {
  final TrainingVideoRepository _repository;

  GetTrainingVideoDetailUseCase(this._repository);

  Future<ResponseModel> execute(int id) async {
    return await _repository.getTrainingVideoDetail(id);
  }
}
