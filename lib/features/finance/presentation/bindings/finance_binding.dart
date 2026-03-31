import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import '../../data/datasources/finance_remote_data_source.dart';
import '../../data/repositories/finance_repository.dart';
import '../../domain/repositories/finance_repository_interface.dart';
import '../../domain/usecases/add_bank_account_usecase.dart';
import '../../domain/usecases/get_bank_accounts_usecase.dart';
import '../../domain/usecases/set_default_bank_account_usecase.dart';
import '../controllers/finance_controller.dart';

class FinanceBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source
    Get.lazyPut<FinanceRemoteDataSource>(
      () => FinanceRemoteDataSource(Get.find<ApiClient>()),
    );

    // Repository
    Get.lazyPut<FinanceRepositoryInterface>(
      () => FinanceRepository(Get.find<FinanceRemoteDataSource>()),
    );

    // Use Cases
    Get.lazyPut<AddBankAccountUseCase>(
      () => AddBankAccountUseCase(Get.find<FinanceRepositoryInterface>()),
    );

    Get.lazyPut<GetBankAccountsUseCase>(
      () => GetBankAccountsUseCase(Get.find<FinanceRepositoryInterface>()),
    );

    Get.lazyPut<SetDefaultBankAccountUseCase>(
      () => SetDefaultBankAccountUseCase(Get.find<FinanceRepositoryInterface>()),
    );

    // Controller
    Get.lazyPut<FinanceController>(
      () => FinanceController(
        Get.find<AddBankAccountUseCase>(),
        Get.find<GetBankAccountsUseCase>(),
        Get.find<SetDefaultBankAccountUseCase>(),
      ),
    );
  }
}