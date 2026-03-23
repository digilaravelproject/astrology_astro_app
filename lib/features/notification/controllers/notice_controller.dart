import 'package:get/get.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/utils/logger.dart';
import '../domain/models/notice_model.dart';
import '../domain/services/notice_service_interface.dart';

class NoticeController extends GetxController {
  final GetNoticesUseCase _getNoticesUseCase;

  NoticeController({required GetNoticesUseCase getNoticesUseCase})
      : _getNoticesUseCase = getNoticesUseCase;

  final notices = <NoticeData>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getNotices();
  }

  Future<void> getNotices() async {
    try {
      isLoading.value = true;
      final response = await _getNoticesUseCase.execute();
      
      if (response.isSuccess && response.body != null) {
        final noticeModel = NoticeModel.fromJson(response.body);
        notices.assignAll(noticeModel.notices);
      }
    } catch (e) {
      Logger.e('NoticeController: getNotices error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

class GetNoticesUseCase {
  final NoticeServiceInterface _noticeService;

  GetNoticesUseCase(this._noticeService);

  Future<ResponseModel> execute() async {
    return await _noticeService.getNotices();
  }
}
