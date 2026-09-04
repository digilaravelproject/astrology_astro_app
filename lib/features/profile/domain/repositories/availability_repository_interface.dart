import 'package:astro_astrologer/core/services/network/response_model.dart';
import 'package:astro_astrologer/features/profile/data/models/availability_model.dart';

abstract class AvailabilityRepositoryInterface {
  Future<ResponseModel> getAvailability();
  Future<ResponseModel> updateAvailability(
    List<AvailabilityModel> availability,
  );
}
