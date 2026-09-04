import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/services/network/response_model.dart';
import 'package:astro_astrologer/features/notification/domain/repositories/notice_repository_interface.dart';

class NoticeRepository implements NoticeRepositoryInterface {
  final ApiClient _apiClient;

  NoticeRepository(this._apiClient);

  @override
  Future<ResponseModel> getNotices() async {
    return await _apiClient.get(AppUrls.getNotices);
  }
}
