import '../models/kundli_request_model.dart';
import '../models/kundli_response_model.dart';
import '../models/create_kundli_request_model.dart';
import '../models/create_kundli_response_model.dart';
import '../models/kundli_list_response_model.dart';
import '../models/kundli_detail_response_model.dart';

abstract class KundliRepository {
  Future<KundliResponseModel> getBirthChart(KundliRequestModel request);
  Future<CreateKundliResponseModel> createKundli(CreateKundliRequestModel request);
  Future<KundliListResponseModel> getKundliList({int perPage = 15});
  Future<KundliDetailResponseModel> getKundliById(int id);
  Future<CreateKundliResponseModel> updateKundli(int id, CreateKundliRequestModel request);
  Future<void> deleteKundli(int id);
}
