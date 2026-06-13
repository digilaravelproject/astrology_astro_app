import '../../../../core/services/network/response_model.dart';
import '../../domain/repositories/billing_repository_interface.dart';
import '../datasources/billing_remote_data_source.dart';

class BillingRepository implements BillingRepositoryInterface {
  final BillingRemoteDataSourceInterface dataSource;

  BillingRepository({required this.dataSource});
  
  @override
  Future<ResponseModel> getBillingAddress() async {
    return await dataSource.getBillingAddress();
  }

  @override
  Future<ResponseModel> updateBillingAddress(Map<String, dynamic> data) async {
    return await dataSource.updateBillingAddress(data);
  }
}
