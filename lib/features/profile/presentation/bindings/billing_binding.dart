import 'package:get/get.dart';
import 'package:astro_astrologer/features/profile/data/datasources/billing_remote_data_source.dart';
import 'package:astro_astrologer/features/profile/data/repositories/billing_repository.dart';
import 'package:astro_astrologer/features/profile/domain/usecases/get_billing_address_usecase.dart';
import 'package:astro_astrologer/features/profile/domain/usecases/update_billing_address_usecase.dart';
import 'package:astro_astrologer/features/profile/presentation/controllers/billing_controller.dart';

class BillingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BillingRemoteDataSourceInterface>(
      () => BillingRemoteDataSource(apiClient: Get.find()),
    );
    Get.lazyPut(() => BillingRepository(dataSource: Get.find()));
    Get.lazyPut(() => GetBillingAddressUseCase(Get.find<BillingRepository>()));
    Get.lazyPut(
      () => UpdateBillingAddressUseCase(Get.find<BillingRepository>()),
    );
    Get.put(BillingController(Get.find(), Get.find()));
  }
}
