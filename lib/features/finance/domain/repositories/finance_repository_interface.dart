import 'dart:io';
import '../../../../core/services/network/response_model.dart';

abstract class FinanceRepositoryInterface {
  Future<ResponseModel> addBankAccount({
    required String accountHolderName,
    required String bankName,
    required String accountNumber,
    required String ifscCode,
    File? passbookDocument,
  });
  
  Future<ResponseModel> getBankAccounts();
  Future<ResponseModel> updateBankAccount(int id, Map<String, dynamic> data);
  Future<ResponseModel> deleteBankAccount(int id);
  Future<ResponseModel> setDefaultBankAccount(int id);
}