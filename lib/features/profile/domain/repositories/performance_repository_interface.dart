import 'package:astro_astrologer/core/services/network/response_model.dart';

abstract class PerformanceRepositoryInterface {
  Future<ResponseModel> getPerformanceData();
}
