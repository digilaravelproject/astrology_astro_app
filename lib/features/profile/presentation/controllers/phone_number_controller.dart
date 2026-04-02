import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        Get.snackbar(
          'Error',
          result.message ?? 'Failed to fetch phone numbers',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      print('[PHONE] Exception in getPhoneNumbers: $e');
      Get.snackbar(
        'Error',
        'Something went wrong: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
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
        Get.snackbar(
          'Success',
          result.message ?? 'Phone number added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
        await getPhoneNumbers();
      } else {
        print('[PHONE] Failed to add: ${result.message}');
        Get.snackbar(
          'Error',
          result.message ?? 'Failed to add phone number',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      print('[PHONE] Exception in addPhoneNumber: $e');
      Get.snackbar(
        'Error',
        'Something went wrong: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
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
        Get.snackbar(
          'Success',
          result.message ?? 'Default phone number set successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
        await getPhoneNumbers();
      } else {
        print('[PHONE] Failed to set default: ${result.message}');
        Get.snackbar(
          'Error',
          result.message ?? 'Failed to set default',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      print('[PHONE] Exception in setDefaultPhoneNumber: $e');
      Get.snackbar(
        'Error',
        'Something went wrong: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }
}
