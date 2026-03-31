import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/bank_account_model.dart';
import '../../domain/usecases/add_bank_account_usecase.dart';
import '../../domain/usecases/get_bank_accounts_usecase.dart';
import '../../domain/usecases/set_default_bank_account_usecase.dart';

class FinanceController extends GetxController {
  final AddBankAccountUseCase _addBankAccountUseCase;
  final GetBankAccountsUseCase _getBankAccountsUseCase;
  final SetDefaultBankAccountUseCase _setDefaultBankAccountUseCase;

  FinanceController(
    this._addBankAccountUseCase,
    this._getBankAccountsUseCase,
    this._setDefaultBankAccountUseCase,
  );

  final RxList<BankAccountModel> bankAccounts = <BankAccountModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isAddingAccount = false.obs;

  @override
  void onInit() {
    super.onInit();
    getBankAccounts();
  }

  Future<void> getBankAccounts() async {
    try {
      isLoading.value = true;
      print('[FINANCE] Getting bank accounts...');
      final result = await _getBankAccountsUseCase.call();
      print('[FINANCE] Get bank accounts result: ${result.toString()}');
      
      if (result.isSuccess) {
        final List<dynamic> data = result.body['bank_accounts'] ?? [];
        print('[FINANCE] Bank accounts data: $data');
        bankAccounts.value = data.map((json) => BankAccountModel.fromJson(json)).toList();
        print('[FINANCE] Parsed ${bankAccounts.length} bank accounts');
      } else {
        print('[FINANCE] Failed to get bank accounts: ${result.message}');
        Get.snackbar(
          'Error',
          result.message ?? 'Failed to fetch bank accounts',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('[FINANCE] Exception in getBankAccounts: $e');
      Get.snackbar(
        'Error',
        'Something went wrong: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addBankAccount({
    required String accountHolderName,
    required String bankName,
    required String accountNumber,
    required String ifscCode,
    File? passbookDocument,
  }) async {
    try {
      isAddingAccount.value = true;
      print('[FINANCE] Adding bank account...');
      print('[FINANCE] Account details: $accountHolderName, $bankName, $accountNumber, $ifscCode');
      
      final result = await _addBankAccountUseCase.call(
        accountHolderName: accountHolderName,
        bankName: bankName,
        accountNumber: accountNumber,
        ifscCode: ifscCode,
        passbookDocument: passbookDocument,
      );

      print('[FINANCE] Add bank account result: ${result.toString()}');

      if (result.isSuccess) {
        print('[FINANCE] Bank account added successfully');
        
        // Add the new account to the list
        final newAccount = BankAccountModel.fromJson(result.body['bank_account']);
        bankAccounts.add(newAccount);
        
        // Navigate back with success result
        Get.back(result: true);
        
        // Show snackbar after navigation
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.snackbar(
            'Success',
            result.message ?? 'Bank account added successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
          );
        });
      } else {
        print('[FINANCE] Failed to add bank account: ${result.message}');
        Get.snackbar(
          'Error',
          result.message ?? 'Failed to add bank account',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      print('[FINANCE] Exception in addBankAccount: $e');
      Get.snackbar(
        'Error',
        'Something went wrong: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isAddingAccount.value = false;
    }
  }

  void clearForm() {
    // This method can be used to clear form data if needed
  }

  Future<void> setDefaultBankAccount(int id) async {
    try {
      print('[FINANCE] Setting default bank account: $id');
      final result = await _setDefaultBankAccountUseCase.call(id);
      print('[FINANCE] Set default result: ${result.toString()}');

      if (result.isSuccess) {
        print('[FINANCE] Default bank account set successfully');
        
        // Update the local list
        for (var account in bankAccounts) {
          account.isDefault = (account.id == id);
        }
        bankAccounts.refresh();
        
        Get.snackbar(
          'Success',
          result.message ?? 'Default bank account set successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
      } else {
        print('[FINANCE] Failed to set default: ${result.message}');
        Get.snackbar(
          'Error',
          result.message ?? 'Failed to set default bank account',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      print('[FINANCE] Exception in setDefaultBankAccount: $e');
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