import '../repositories/phone_number_repository_interface.dart';
import '../../../../core/services/network/response_model.dart';

class AddPhoneNumberUseCase {
  final PhoneNumberRepositoryInterface _repository;

  AddPhoneNumberUseCase(this._repository);

  Future<ResponseModel> call(String countryCode, String phone) async {
    return await _repository.addPhoneNumber(countryCode, phone);
  }
}
