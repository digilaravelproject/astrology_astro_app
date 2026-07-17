import 'package:get/get.dart';
import '../../data/datasources/billing_remote_data_source.dart';
import '../../data/repositories/billing_repository.dart';
import '../../domain/usecases/get_billing_address_usecase.dart';
import '../../domain/usecases/update_billing_address_usecase.dart';
import '../controllers/billing_controller.dart';

class BillingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BillingRemoteDataSourceInterface>(() => BillingRemoteDataSource(apiClient: Get.find()));
    Get.lazyPut(() => BillingRepository(dataSource: Get.find()));
    Get.lazyPut(() => GetBillingAddressUseCase(Get.find<BillingRepository>()));
    Get.lazyPut(() => UpdateBillingAddressUseCase(Get.find<BillingRepository>()));
    Get.put(BillingController(Get.find(), Get.find()));
  }
}
