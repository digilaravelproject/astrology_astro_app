import '../../domain/models/phone_number_model.dart';
import '../../domain/repositories/phone_number_repository_interface.dart';
import '../datasources/phone_number_remote_data_source.dart';
import '../../../../core/services/network/response_model.dart';

class PhoneNumberRepository implements PhoneNumberRepositoryInterface {
  final PhoneNumberRemoteDataSource _remoteDataSource;

  PhoneNumberRepository(this._remoteDataSource);

  @override
  Future<ResponseModel> getPhoneNumbers() async {
    return await _remoteDataSource.getPhoneNumbers();
  }

  @override
  Future<ResponseModel> addPhoneNumber(String countryCode, String phone) async {
    return await _remoteDataSource.addPhoneNumber(countryCode, phone);
  }

  @override
  Future<ResponseModel> verifyPhoneNumber(int id, String otp) async {
    return await _remoteDataSource.verifyPhoneNumber(id, otp);
  }

  @override
  Future<ResponseModel> setDefaultPhoneNumber(int id) async {
    return await _remoteDataSource.setDefaultPhoneNumber(id);
  }

  @override
  Future<ResponseModel> deletePhoneNumber(int id) async {
    return await _remoteDataSource.deletePhoneNumber(id);
  }
}
