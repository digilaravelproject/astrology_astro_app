import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/network/api_checker.dart';
import '../../../../core/utils/custom_snackbar.dart';
import '../../domain/usecases/get_billing_address_usecase.dart';
import '../../domain/usecases/update_billing_address_usecase.dart';

class BillingController extends GetxController {
  final GetBillingAddressUseCase _getBillingAddressUseCase;
  final UpdateBillingAddressUseCase _updateBillingAddressUseCase;

  BillingController(this._getBillingAddressUseCase, this._updateBillingAddressUseCase);

  final RxBool isLoading = false.obs;
  final RxBool isInitialLoading = false.obs;
  
  // Controllers
  final addressController = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final nameController = TextEditingController();
  final pincodeController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchBillingAddress();
  }

  Future<void> fetchBillingAddress() async {
    try {
      isInitialLoading.value = true;
      final result = await _getBillingAddressUseCase.call();
      
      if (result.isSuccess && result.body != null) {
        final data = result.body['billing_address'];
        if (data != null) {
          addressController.text = data['address_line1']?.toString() ?? '';
          addressLine2Controller.text = data['address_line2']?.toString() ?? '';
          nameController.text = data['invoice_name']?.toString() ?? '';
          pincodeController.text = data['postal_code']?.toString() ?? '';
          cityController.text = data['city']?.toString() ?? '';
          stateController.text = data['state']?.toString() ?? '';
          countryController.text = data['country']?.toString() ?? '';
        }
      }
    } catch (e) {
      print('[BILLING] Fetch Exception: $e');
    } finally {
      isInitialLoading.value = false;
    }
  }

  Future<void> updateAddress() async {
    try {
      if (addressController.text.trim().isEmpty ||
          nameController.text.trim().isEmpty ||
          pincodeController.text.trim().isEmpty ||
          cityController.text.trim().isEmpty ||
          stateController.text.trim().isEmpty ||
          countryController.text.trim().isEmpty) {
        CustomSnackBar.showError('All fields are required');
        return;
      }

      isLoading.value = true;
      
      final data = {
        'address_line1': addressController.text,
        'address_line2': addressLine2Controller.text.isEmpty ? 'N/A' : addressLine2Controller.text,
        'city': cityController.text,
        'state': stateController.text,
        'postal_code': pincodeController.text,
        'country': countryController.text,
        'invoice_name': nameController.text,
      };

      final result = await _updateBillingAddressUseCase.call(data);
      
      if (result.isSuccess) {
        ApiChecker.handleResponse(result, showSuccess: true);
        Get.back(); // Close bottom sheet
      } else {
        ApiChecker.handleResponse(result);
      }
    } catch (e) {
      print('[BILLING] Exception: $e');
      CustomSnackBar.showError('Something went wrong: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    addressController.dispose();
    addressLine2Controller.dispose();
    nameController.dispose();
    pincodeController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    super.onClose();
  }
}
