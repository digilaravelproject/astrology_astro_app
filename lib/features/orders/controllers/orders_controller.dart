import 'package:get/get.dart';
import 'package:astro_astrologer/features/chat/domain/models/chat_session_model.dart';
import 'package:astro_astrologer/features/chat/domain/usecases/get_chat_sessions_usecase.dart';

class OrdersController extends GetxController {
  final GetChatSessionsUseCase _getChatSessionsUseCase;

  OrdersController({required GetChatSessionsUseCase getChatSessionsUseCase})
      : _getChatSessionsUseCase = getChatSessionsUseCase;

  final RxList<ChatSessionModel> chatSessions = <ChatSessionModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void onInit() {
    super.onInit();
    fetchChatSessions();
  }

  Future<void> fetchChatSessions({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasMore = true;
      chatSessions.clear();
      error.value = '';
    }

    if (!_hasMore || isLoading.value) return;

    try {
      isLoading.value = true;
      final response = await _getChatSessionsUseCase.execute(page: _currentPage);
      
      if (response.data.isNotEmpty) {
        chatSessions.addAll(response.data);
        _currentPage++;
      } else {
        _hasMore = false;
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
