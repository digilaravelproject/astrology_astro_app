import '../../../../core/constants/app_urls.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../domain/repositories/notice_repository_interface.dart';

class NoticeRepository implements NoticeRepositoryInterface {
  final ApiClient _apiClient;

  NoticeRepository(this._apiClient);

  @override
  Future<ResponseModel> getNotices() async {
    return await _apiClient.get(AppUrls.getNotices);
  }
}
