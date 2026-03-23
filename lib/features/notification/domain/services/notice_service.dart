import '../../../../core/services/network/response_model.dart';
import '../repositories/notice_repository_interface.dart';
import 'notice_service_interface.dart';

class NoticeService implements NoticeServiceInterface {
  final NoticeRepositoryInterface _noticeRepository;

  NoticeService(this._noticeRepository);

  @override
  Future<ResponseModel> getNotices() async {
    return await _noticeRepository.getNotices();
  }
}
