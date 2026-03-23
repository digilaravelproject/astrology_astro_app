import '../../../../core/services/network/response_model.dart';

abstract class NoticeRepositoryInterface {
  Future<ResponseModel> getNotices();
}
