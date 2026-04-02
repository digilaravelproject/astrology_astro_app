import '../repositories/phone_number_repository_interface.dart';
import '../../../../core/services/network/response_model.dart';

class SetDefaultPhoneNumberUseCase {
  final PhoneNumberRepositoryInterface _repository;

  SetDefaultPhoneNumberUseCase(this._repository);

  Future<ResponseModel> call(int id) async {
    return await _repository.setDefaultPhoneNumber(id);
  }
}
