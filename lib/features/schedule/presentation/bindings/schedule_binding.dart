import 'package:get/get.dart';
import '../controllers/schedule_controller.dart';
import '../../domain/usecases/set_sleep_hours_usecase.dart';
import '../../domain/usecases/get_sleep_hours_usecase.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../data/datasources/schedule_remote_data_source.dart';
import '../../../../core/services/network/api_client.dart';

class ScheduleBinding extends Bindings {
  @override
  void dependencies() {
    final apiClient = Get.find<ApiClient>();
    
    final dataSource = ScheduleRemoteDataSource(apiClient);
    final repository = ScheduleRepository(dataSource);
    
    final setSleepHoursUseCase = SetSleepHoursUseCase(repository);
    final getSleepHoursUseCase = GetSleepHoursUseCase(repository);
    
    Get.lazyPut(() => ScheduleController(setSleepHoursUseCase, getSleepHoursUseCase), fenix: true);
  }
}