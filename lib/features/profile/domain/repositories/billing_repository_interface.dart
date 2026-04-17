import '../../../../core/services/network/response_model.dart';

abstract class BillingRepositoryInterface {
  Future<ResponseModel> getBillingAddress();
  Future<ResponseModel> updateBillingAddress(Map<String, dynamic> data);
}
