import '../../../../core/services/network/response_model.dart';

abstract class NoticeServiceInterface {
  Future<ResponseModel> getNotices();
}
