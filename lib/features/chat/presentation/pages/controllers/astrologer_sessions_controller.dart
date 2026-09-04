import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/features/chat/data/models/chat_session_model.dart';

class AstrologerSessionsController extends GetxController {
  final ApiClient _apiClient;
  AstrologerSessionsController(this._apiClient);

  final RxList<ChatSessionModel> sessions = <ChatSessionModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString error = ''.obs;

  int _currentPage = 1;
  int _lastPage = 1;
  bool _isFetching = false;

  late final ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    fetchSessions(refresh: true);
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadMore();
    }
  }

  Future<void> fetchSessions({bool refresh = false}) async {
    if (_isFetching) return;
    _isFetching = true;

    if (refresh) {
      _currentPage = 1;
      _lastPage = 1;
      error.value = '';
      isLoading.value = true;
    }

    try {
      final response = await _apiClient.get(
        AppUrls.astrologerChatSessions,
        queryParameters: {'page': _currentPage},
      );

      if (response.isSuccess) {
        final body = response.body;
        final responseObj = ChatSessionListResponse.fromJson(
          body is Map<String, dynamic> ? body : <String, dynamic>{},
        );
        _lastPage = responseObj.lastPage;

        if (refresh) {
          sessions.assignAll(responseObj.data);
        } else {
          sessions.addAll(responseObj.data);
        }
      } else {
        error.value = response.message;
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
      _isFetching = false;
    }
  }

  Future<void> loadMore() async {
    if (_isFetching || _currentPage >= _lastPage) return;
    _currentPage++;
    isLoadingMore.value = true;
    await fetchSessions();
  }

  Future<void> refresh() async {
    await fetchSessions(refresh: true);
  }
}
