import '../../../../core/services/network/response_model.dart';
import '../../data/repositories/follower_repository.dart';
import '../models/follower_model.dart';

class FollowerService {
  final FollowerRepository _followerRepository;

  FollowerService(this._followerRepository);

  Future<FollowerResponse?> getFollowers() async {
    final response = await _followerRepository.getFollowers();
    if (response.isSuccess && response.body != null) {
      return FollowerResponse.fromJson(response.body);
    }
    return null;
  }

  Future<FollowerResponse?> getFavorites() async {
    final response = await _followerRepository.getFavorites();
    if (response.isSuccess && response.body != null) {
      return FollowerResponse.fromJson(response.body);
    }
    return null;
  }

  Future<bool> toggleLike(int id) async {
    final response = await _followerRepository.toggleLike(id);
    return response.isSuccess;
  }
}

class GetFollowersUseCase {
  final FollowerService _followerService;

  GetFollowersUseCase(this._followerService);

  Future<FollowerResponse?> execute() async {
    return await _followerService.getFollowers();
  }
}

class GetFavoritesUseCase {
  final FollowerService _followerService;

  GetFavoritesUseCase(this._followerService);

  Future<FollowerResponse?> execute() async {
    return await _followerService.getFavorites();
  }
}

class ToggleLikeUseCase {
  final FollowerService _followerService;

  ToggleLikeUseCase(this._followerService);

  Future<bool> execute(int id) async {
    return await _followerService.toggleLike(id);
  }
}
