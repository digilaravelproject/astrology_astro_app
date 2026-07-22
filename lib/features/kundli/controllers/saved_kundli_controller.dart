import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import '../models/create_kundli_request_model.dart';
import '../models/create_kundli_response_model.dart';
import '../models/kundli_list_response_model.dart';
import '../models/kundli_detail_response_model.dart';
import '../repositories/saved_kundli_repository.dart';
import '../repositories/saved_kundli_repository_impl.dart';

class SavedKundliController extends GetxController {
  final KundliRepository _repository = KundliRepositoryImpl(
    apiClient: Get.find<ApiClient>(),
  );

  final RxList<KundliItem> kundliList = <KundliItem>[].obs;
  final RxBool isLoadingList = false.obs;
  final RxBool isLoadingAction = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchKundliList();
  }

  Future<void> fetchKundliList() async {
    try {
      isLoadingList.value = true;
      error.value = '';
      final response = await _repository.getKundliList(perPage: 100);
      kundliList.value = response.data;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoadingList.value = false;
    }
  }

  Future<CreateKundliResponseModel?> createKundli({
    required String name,
    required String gender,
    required String birthDate,
    required String birthTime,
    required String latitude,
    required String longitude,
    required String datetime,
    String? place,
  }) async {
    try {
      isLoadingAction.value = true;
      error.value = '';
      final request = CreateKundliRequestModel(
        name: name,
        gender: gender,
        birthDate: birthDate,
        birthTime: birthTime,
        latitude: latitude,
        longitude: longitude,
        datetime: datetime,
        place: place,
      );
      final response = await _repository.createKundli(request);
      await fetchKundliList();
      return response;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return null;
    } finally {
      isLoadingAction.value = false;
    }
  }

  Future<CreateKundliResponseModel?> updateKundli({
    required int id,
    required String name,
    required String gender,
    required String birthDate,
    required String birthTime,
    required String latitude,
    required String longitude,
    required String datetime,
    String? place,
  }) async {
    try {
      isLoadingAction.value = true;
      error.value = '';
      final request = CreateKundliRequestModel(
        name: name,
        gender: gender,
        birthDate: birthDate,
        birthTime: birthTime,
        latitude: latitude,
        longitude: longitude,
        datetime: datetime,
        place: place,
      );
      final response = await _repository.updateKundli(id, request);
      await fetchKundliList();
      return response;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return null;
    } finally {
      isLoadingAction.value = false;
    }
  }

  Future<bool> deleteKundli(int id) async {
    try {
      isLoadingAction.value = true;
      error.value = '';
      await _repository.deleteKundli(id);
      kundliList.removeWhere((item) => item.id == id);
      return true;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoadingAction.value = false;
    }
  }
}
