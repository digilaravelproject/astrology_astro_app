import 'package:get/get.dart';
import 'package:astro_astrologer/features/call/domain/models/call_session_model.dart';
import 'package:astro_astrologer/features/orders/domain/usecases/get_astrologer_call_sessions_usecase.dart';

class HistoryController extends GetxController {
  final GetAstrologerCallSessionsUseCase _getAstrologerCallSessionsUseCase;

  HistoryController({
    required GetAstrologerCallSessionsUseCase getAstrologerCallSessionsUseCase,
  }) : _getAstrologerCallSessionsUseCase = getAstrologerCallSessionsUseCase;

  final RxList<CallSessionModel> callSessions = <CallSessionModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  int _currentPage = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  @override
  void onInit() {
    super.onInit();
    fetchCallSessions();
  }

  Future<void> fetchCallSessions({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasMore = true;
      callSessions.clear();
      error.value = '';
    }

    if (!_hasMore || isLoading.value) return;

    try {
      isLoading.value = true;
      final response = await _getAstrologerCallSessionsUseCase.execute(
        page: _currentPage,
      );

      if (response.data.isNotEmpty) {
        callSessions.addAll(response.data);
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
