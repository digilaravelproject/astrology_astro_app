import '../../../../core/services/network/response_model.dart';
import '../models/remedy_model.dart';

abstract class RemedyRepositoryInterface {
  Future<ResponseModel> getRemedies();
  Future<RemedyModel?> getRemedyDetails(int id);
}
