import 'package:get/get.dart';
import '../domain/models/follower_model.dart';
import '../domain/services/follower_service.dart';

class FollowerController extends GetxController {
  final GetFollowersUseCase _getFollowersUseCase;
  final GetFavoritesUseCase _getFavoritesUseCase;
  final ToggleLikeUseCase _toggleLikeUseCase;

  FollowerController({
    required GetFollowersUseCase getFollowersUseCase,
    required GetFavoritesUseCase getFavoritesUseCase,
    required ToggleLikeUseCase toggleLikeUseCase,
  })  : _getFollowersUseCase = getFollowersUseCase,
        _getFavoritesUseCase = getFavoritesUseCase,
        _toggleLikeUseCase = toggleLikeUseCase;

  final isLoading = false.obs;
  final followers = <FollowerModel>[].obs;
  final favorites = <FollowerModel>[].obs;
  final followerCount = 0.obs;
  final favoriteCount = 0.obs;

  // Search
  final searchQuery = ''.obs;

  List<FollowerModel> get filteredFollowers {
    if (searchQuery.isEmpty) return followers;
    return followers
        .where((f) => f.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  List<FollowerModel> get filteredFavorites {
    if (searchQuery.isEmpty) return favorites;
    return favorites
        .where((f) => f.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    getAllData();
  }

  Future<void> getAllData() async {
    await Future.wait([
      getFollowers(),
      getFavorites(),
    ]);
  }

  Future<void> getFollowers() async {
    try {
      isLoading.value = true;
      final response = await _getFollowersUseCase.execute();
      if (response != null) {
        followers.value = response.followers;
        followerCount.value = response.count;
      }
    } catch (e) {
      print('FollowerController: getFollowers error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getFavorites() async {
    try {
      isLoading.value = true;
      final response = await _getFavoritesUseCase.execute();
      if (response != null) {
        favorites.value = response.followers;
        favoriteCount.value = response.count;
      }
    } catch (e) {
      print('FollowerController: getFavorites error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleLike(int userId) async {
    // Optimistic update for the followers list
    final index = followers.indexWhere((f) => f.userId == userId);
    if (index != -1) {
      final follower = followers[index];
      followers[index] = follower.copyWith(isLiked: !follower.isLiked);
      followers.refresh();
    }

    try {
      final success = await _toggleLikeUseCase.execute(userId);
      if (success) {
        // Refresh favorites list to show/remove the user
        await getFavorites();
      } else {
        // Revert optimistic update if failed
        if (index != -1) {
          final follower = followers[index];
          followers[index] = follower.copyWith(isLiked: !follower.isLiked);
          followers.refresh();
        }
      }
    } catch (e) {
      print('FollowerController: toggleLike error: $e');
      // Revert optimistic update if error
      if (index != -1) {
        final follower = followers[index];
        followers[index] = follower.copyWith(isLiked: !follower.isLiked);
        followers.refresh();
      }
    }
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }
}
