import 'package:get/get.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';

class AssistantChatListController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final RxList<dynamic> activeSessions = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSessions();
  }

  Future<void> fetchSessions() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final response = await _apiClient.get(AppUrls.chatAssistanceSessions);
      if (response.isSuccess) {
        final data = response.body['data']['data'] as List;
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
}
