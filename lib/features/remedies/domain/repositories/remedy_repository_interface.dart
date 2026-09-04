import 'package:astro_astrologer/core/services/network/response_model.dart';
import 'package:astro_astrologer/features/remedies/data/models/remedy_model.dart';

abstract class RemedyRepositoryInterface {
  Future<ResponseModel> getRemedies();
  Future<RemedyModel?> getRemedyDetails(int id);
}
