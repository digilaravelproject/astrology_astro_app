import 'dart:io';
import 'package:dio/dio.dart' as dio;
import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/constants/app_urls.dart';

class FinanceRemoteDataSource {
  final ApiClient _apiClient;

  FinanceRemoteDataSource(this._apiClient);

  Future<ResponseModel> addBankAccount({
    required String accountHolderName,
    required String bankName,
    required String accountNumber,
    required String ifscCode,
    File? passbookDocument,
  }) async {
    print('[FINANCE_DS] Adding bank account with data: $accountHolderName, $bankName, $accountNumber, $ifscCode');
    
    final formData = dio.FormData.fromMap({
      'account_holder_name': accountHolderName,
      'bank_name': bankName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
    });

    if (passbookDocument != null) {
      print('[FINANCE_DS] Adding passbook document: ${passbookDocument.path}');
      formData.files.add(MapEntry(
        'passbook_document',
        await dio.MultipartFile.fromFile(passbookDocument.path),
      ));
    }

    print('[FINANCE_DS] Making API call to: ${AppUrls.bankAccounts}');
    final result = await _apiClient.post(AppUrls.bankAccounts, data: formData);
    print('[FINANCE_DS] API response: ${result.toString()}');
    return result;
  }

  Future<ResponseModel> getBankAccounts() async {
    print('[FINANCE_DS] Getting bank accounts from: ${AppUrls.bankAccounts}');
    final result = await _apiClient.get(AppUrls.bankAccounts);
    print('[FINANCE_DS] Get bank accounts response: ${result.toString()}');
    return result;
  }

  Future<ResponseModel> updateBankAccount(int id, Map<String, dynamic> data) async {
    return await _apiClient.put('${AppUrls.bankAccounts}/$id', data: data);
  }

  Future<ResponseModel> deleteBankAccount(int id) async {
    return await _apiClient.delete('${AppUrls.bankAccounts}/$id');
  }

  Future<ResponseModel> setDefaultBankAccount(int id) async {
    print('[FINANCE_DS] Setting default bank account: $id');
    final result = await _apiClient.post(AppUrls.setDefaultBankAccount(id));
    print('[FINANCE_DS] Set default response: ${result.toString()}');
    return result;
  }
}