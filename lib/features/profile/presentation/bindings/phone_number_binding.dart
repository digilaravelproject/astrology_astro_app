import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import '../../data/datasources/phone_number_remote_data_source.dart';
import '../../data/repositories/phone_number_repository.dart';
import '../../domain/repositories/phone_number_repository_interface.dart';
import '../../domain/usecases/get_phone_numbers_usecase.dart';
import '../../domain/usecases/add_phone_number_usecase.dart';
import '../../domain/usecases/set_default_phone_number_usecase.dart';
import '../../domain/usecases/verify_phone_number_usecase.dart';
import '../controllers/phone_number_controller.dart';

class PhoneNumberBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source
    Get.lazyPut<PhoneNumberRemoteDataSource>(
      () => PhoneNumberRemoteDataSource(Get.find<ApiClient>()),
    );

    // Repository
    Get.lazyPut<PhoneNumberRepositoryInterface>(
      () => PhoneNumberRepository(Get.find<PhoneNumberRemoteDataSource>()),
    );

    // Use Cases
    Get.lazyPut<GetPhoneNumbersUseCase>(
      () => GetPhoneNumbersUseCase(Get.find<PhoneNumberRepositoryInterface>()),
    );

    Get.lazyPut<AddPhoneNumberUseCase>(
      () => AddPhoneNumberUseCase(Get.find<PhoneNumberRepositoryInterface>()),
    );

    Get.lazyPut<SetDefaultPhoneNumberUseCase>(
      () => SetDefaultPhoneNumberUseCase(Get.find<PhoneNumberRepositoryInterface>()),
    );

    Get.lazyPut<VerifyPhoneNumberUseCase>(
      () => VerifyPhoneNumberUseCase(Get.find<PhoneNumberRepositoryInterface>()),
    );

    // Controller
    Get.lazyPut<PhoneNumberController>(
      () => PhoneNumberController(
        Get.find<GetPhoneNumbersUseCase>(),
        Get.find<AddPhoneNumberUseCase>(),
        Get.find<SetDefaultPhoneNumberUseCase>(),
        Get.find<VerifyPhoneNumberUseCase>(),
      ),
    );
  }
}
