import 'package:get/get.dart';
import 'package:astro_astrologer/features/schedule/presentation/controllers/schedule_controller.dart';
import 'package:astro_astrologer/features/schedule/domain/usecases/set_sleep_hours_usecase.dart';
import 'package:astro_astrologer/features/schedule/domain/usecases/get_sleep_hours_usecase.dart';
import 'package:astro_astrologer/features/schedule/data/repositories/schedule_repository.dart';
import 'package:astro_astrologer/features/schedule/data/datasources/schedule_remote_data_source.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';

class ScheduleBinding extends Bindings {
  @override
  void dependencies() {
    final apiClient = Get.find<ApiClient>();

    final dataSource = ScheduleRemoteDataSource(apiClient);
    final repository = ScheduleRepository(dataSource);

    final setSleepHoursUseCase = SetSleepHoursUseCase(repository);
    final getSleepHoursUseCase = GetSleepHoursUseCase(repository);

    Get.lazyPut(
      () => ScheduleController(setSleepHoursUseCase, getSleepHoursUseCase),
      fenix: true,
    );
  }
}
