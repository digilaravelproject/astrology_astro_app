import 'dart:async';
import 'package:astro_astrologer/core/services/websocket/websocket_service.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';

class AssistantChatListController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final RxList<dynamic> activeSessions = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;

  // Search and Filter variables
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'All'.obs; // 'All', 'Unread', 'Read'

  StreamSubscription? _msgSub;

  @override
  void onInit() {
    super.onInit();
    fetchSessions();

    // Listen to incoming messages to auto-update list data in real-time
    _msgSub = WebSocketService.incomingMessages.listen((_) {
      fetchSessions();
    });
  }

  @override
  void onClose() {
    _msgSub?.cancel();
    super.onClose();
  }

  Future<void> fetchSessions() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final response = await _apiClient.get(AppUrls.chatAssistanceSessions);
      if (response.isSuccess) {
        final data = response.body['data'] as List;
        activeSessions.assignAll(data);
      } else {
        hasError.value = true;
      }
    } catch (e) {
      hasError.value = true;
      print('Error fetching assistant chat sessions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<dynamic> get filteredSessions {
    return activeSessions.where((session) {
      final consumer = session['consumer'] ?? {};
      final latestMessage = session['latest_message'] ?? {};
      final name = (consumer['name'] ?? '').toString().toLowerCase();
      final query = searchQuery.value.toLowerCase();

      final matchesQuery = name.contains(query);
      if (!matchesQuery) return false;

      final consumerId = session['consumer_id'];
      final isUnread =
          latestMessage['sender_id'] == consumerId &&
          latestMessage['is_read'] == false;

      if (selectedFilter.value == 'Unread') {
        return isUnread;
      } else if (selectedFilter.value == 'Read') {
        return !isUnread;
      }

      return true;
    }).toList();
  }
}
