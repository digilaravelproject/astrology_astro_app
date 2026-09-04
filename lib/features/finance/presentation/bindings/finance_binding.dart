import 'package:get/get.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/features/finance/data/datasources/finance_remote_data_source.dart';
import 'package:astro_astrologer/features/finance/data/repositories/finance_repository.dart';
import 'package:astro_astrologer/features/finance/domain/repositories/finance_repository_interface.dart';
import 'package:astro_astrologer/features/finance/domain/usecases/add_bank_account_usecase.dart';
import 'package:astro_astrologer/features/finance/domain/usecases/get_bank_accounts_usecase.dart';
import 'package:astro_astrologer/features/finance/domain/usecases/set_default_bank_account_usecase.dart';
import 'package:astro_astrologer/features/finance/presentation/controllers/finance_controller.dart';

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
      () =>
          SetDefaultBankAccountUseCase(Get.find<FinanceRepositoryInterface>()),
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
