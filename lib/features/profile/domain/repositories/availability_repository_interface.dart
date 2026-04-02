import '../../../../core/services/network/response_model.dart';
import '../models/availability_model.dart';

abstract class AvailabilityRepositoryInterface {
  Future<ResponseModel> getAvailability();
  Future<ResponseModel> updateAvailability(List<AvailabilityModel> availability);
}
