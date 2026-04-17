import 'package:get/get.dart';
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';
import '../../domain/models/phone_number_model.dart';
import '../../domain/usecases/get_phone_numbers_usecase.dart';
import '../../domain/usecases/add_phone_number_usecase.dart';
import '../../domain/usecases/set_default_phone_number_usecase.dart';

class PhoneNumberController extends GetxController {
  final GetPhoneNumbersUseCase _getPhoneNumbersUseCase;
  final AddPhoneNumberUseCase _addPhoneNumberUseCase;
  final SetDefaultPhoneNumberUseCase _setDefaultPhoneNumberUseCase;

  PhoneNumberController(
    this._getPhoneNumbersUseCase,
    this._addPhoneNumberUseCase,
    this._setDefaultPhoneNumberUseCase,
  );

  final RxList<PhoneNumberModel> phoneNumbers = <PhoneNumberModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isAdding = false.obs;

  @override
  void onInit() {
    super.onInit();
    getPhoneNumbers();
  }

  Future<void> getPhoneNumbers() async {
    try {
      isLoading.value = true;
      print('[PHONE] Getting phone numbers...');
      final result = await _getPhoneNumbersUseCase.call();
      print('[PHONE] Get phone numbers result: ${result.toString()}');

      if (result.isSuccess) {
        final List<dynamic> data = result.body['numbers'] ?? [];
        phoneNumbers.value = data.map((json) => PhoneNumberModel.fromJson(json)).toList();
        print('[PHONE] Loaded ${phoneNumbers.length} phone numbers');
      } else {
        print('[PHONE] Failed to get phone numbers: ${result.message}');
        CustomSnackBar.showError(result.message ?? 'Failed to fetch phone numbers');
      }
    } catch (e) {
      print('[PHONE] Exception in getPhoneNumbers: $e');
      CustomSnackBar.showError('Something went wrong: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addPhoneNumber(String countryCode, String phone) async {
    try {
      isAdding.value = true;
      print('[PHONE] Adding phone number: $countryCode $phone');
      final result = await _addPhoneNumberUseCase.call(countryCode, phone);
      print('[PHONE] Add phone number result: ${result.toString()}');

      if (result.isSuccess) {
        print('[PHONE] Phone number added successfully');
        CustomSnackBar.showSuccess(result.message ?? 'Phone number added successfully');
        await getPhoneNumbers();
      } else {
        print('[PHONE] Failed to add: ${result.message}');
        CustomSnackBar.showError(result.message ?? 'Failed to add phone number');
      }
    } catch (e) {
      print('[PHONE] Exception in addPhoneNumber: $e');
      CustomSnackBar.showError('Something went wrong: ${e.toString()}');
    } finally {
      isAdding.value = false;
    }
  }

  Future<void> setDefaultPhoneNumber(int id) async {
    try {
      print('[PHONE] Setting default phone number: $id');
      final result = await _setDefaultPhoneNumberUseCase.call(id);
      print('[PHONE] Set default result: ${result.toString()}');

      if (result.isSuccess) {
        print('[PHONE] Default phone number set successfully');
        CustomSnackBar.showSuccess(result.message ?? 'Default phone number set successfully');
        await getPhoneNumbers();
      } else {
        print('[PHONE] Failed to set default: ${result.message}');
        CustomSnackBar.showError(result.message ?? 'Failed to set default');
      }
    } catch (e) {
      print('[PHONE] Exception in setDefaultPhoneNumber: $e');
      CustomSnackBar.showError('Something went wrong: ${e.toString()}');
    }
  }
}
