import 'dart:io';
import '../../domain/repositories/finance_repository_interface.dart';
import '../datasources/finance_remote_data_source.dart';
import '../../../../core/services/network/response_model.dart';

class FinanceRepository implements FinanceRepositoryInterface {
  final FinanceRemoteDataSource _remoteDataSource;

  FinanceRepository(this._remoteDataSource);

  @override
  Future<ResponseModel> addBankAccount({
    required String accountHolderName,
    required String bankName,
    required String accountNumber,
    required String ifscCode,
    File? passbookDocument,
  }) async {
    return await _remoteDataSource.addBankAccount(
      accountHolderName: accountHolderName,
      bankName: bankName,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
      passbookDocument: passbookDocument,
    );
  }

  @override
  Future<ResponseModel> getBankAccounts() async {
    return await _remoteDataSource.getBankAccounts();
  }

  @override
  Future<ResponseModel> updateBankAccount(int id, Map<String, dynamic> data) async {
    return await _remoteDataSource.updateBankAccount(id, data);
  }

  @override
  Future<ResponseModel> deleteBankAccount(int id) async {
    return await _remoteDataSource.deleteBankAccount(id);
  }

  @override
  Future<ResponseModel> setDefaultBankAccount(int id) async {
    return await _remoteDataSource.setDefaultBankAccount(id);
  }
}