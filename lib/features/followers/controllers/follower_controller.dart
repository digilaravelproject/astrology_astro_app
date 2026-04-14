import 'dart:async';
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

  // Pagination state
  final followerCurrentPage = 1.obs;
  final followerLastPage = 1.obs;
  final isFollowerMoreLoading = false.obs;

  final favoriteCurrentPage = 1.obs;
  final favoriteLastPage = 1.obs;
  final isFavoriteMoreLoading = false.obs;

  final perPage = 10;

  // Search
  final searchQuery = ''.obs;
  Timer? _searchTimer;

  @override
  void onInit() {
    super.onInit();
    getAllData();
  }

  Future<void> getAllData() async {
    await Future.wait([
      getFollowers(reset: true),
      getFavorites(reset: true),
    ]);
  }

  Future<void> getFollowers({bool showLoading = true, bool reset = false}) async {
    if (reset) {
      followerCurrentPage.value = 1;
    }

    try {
      if (showLoading && followers.isEmpty) isLoading.value = true;
      final response = await _getFollowersUseCase.execute(
        query: searchQuery.value,
        page: followerCurrentPage.value,
        perPage: perPage,
      );
      if (response != null) {
        if (reset) {
          followers.value = response.followers;
        } else {
          followers.addAll(response.followers);
        }
        followerCount.value = response.total;
        followerLastPage.value = response.lastPage;
      }
    } catch (e) {
      print('FollowerController: getFollowers error: $e');
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  Future<void> loadMoreFollowers() async {
    if (isFollowerMoreLoading.value || followerCurrentPage.value >= followerLastPage.value) return;

    try {
      isFollowerMoreLoading.value = true;
      followerCurrentPage.value++;
      await getFollowers(showLoading: false, reset: false);
    } catch (e) {
      print('FollowerController: loadMoreFollowers error: $e');
    } finally {
      isFollowerMoreLoading.value = false;
    }
  }

  Future<void> getFavorites({bool showLoading = true, bool reset = false}) async {
    if (reset) {
      favoriteCurrentPage.value = 1;
    }

    try {
      if (showLoading && favorites.isEmpty) isLoading.value = true;
      final response = await _getFavoritesUseCase.execute(
        query: searchQuery.value,
        page: favoriteCurrentPage.value,
        perPage: perPage,
      );
      if (response != null) {
        if (reset) {
          favorites.value = response.followers;
        } else {
          favorites.addAll(response.followers);
        }
        favoriteCount.value = response.total;
        favoriteLastPage.value = response.lastPage;
      }
    } catch (e) {
      print('FollowerController: getFavorites error: $e');
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  Future<void> loadMoreFavorites() async {
    if (isFavoriteMoreLoading.value || favoriteCurrentPage.value >= favoriteLastPage.value) return;

    try {
      isFavoriteMoreLoading.value = true;
      favoriteCurrentPage.value++;
      await getFavorites(showLoading: false, reset: false);
    } catch (e) {
      print('FollowerController: loadMoreFavorites error: $e');
    } finally {
      isFavoriteMoreLoading.value = false;
    }
  }

  Future<void> toggleLike(int userId) async {
    final index = followers.indexWhere((f) => f.userId == userId);
    if (index != -1) {
      final follower = followers[index];
      followers[index] = follower.copyWith(isLiked: !follower.isLiked);
      followers.refresh();
    }

    try {
      final success = await _toggleLikeUseCase.execute(userId);
      if (success) {
        await getFavorites(showLoading: false, reset: true);
      } else {
        if (index != -1) {
          final follower = followers[index];
          followers[index] = follower.copyWith(isLiked: !follower.isLiked);
          followers.refresh();
        }
      }
    } catch (e) {
      print('FollowerController: toggleLike error: $e');
      if (index != -1) {
        final follower = followers[index];
        followers[index] = follower.copyWith(isLiked: !follower.isLiked);
        followers.refresh();
      }
    }
  }

  void updateSearch(String query) {
    if (searchQuery.value == query) return;
    searchQuery.value = query;
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      getAllData();
    });
  }

  @override
  void onClose() {
    _searchTimer?.cancel();
    super.onClose();
  }
}
