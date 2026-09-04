import 'package:get/get.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage/shared_prefs.dart';
import 'package:astro_astrologer/features/notification/data/models/notice_model.dart';
import 'package:astro_astrologer/features/notification/data/datasources/notice_service_interface.dart';

class NoticeController extends GetxController {
  final GetNoticesUseCase _getNoticesUseCase;

  NoticeController({required GetNoticesUseCase getNoticesUseCase})
    : _getNoticesUseCase = getNoticesUseCase;

  final notices = <NoticeData>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;
    if (isLoggedIn) {
      getNotices();
    }
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
