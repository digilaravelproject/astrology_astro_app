import '../repositories/phone_number_repository_interface.dart';
import '../../../../core/services/network/response_model.dart';

class GetPhoneNumbersUseCase {
  final PhoneNumberRepositoryInterface _repository;

  GetPhoneNumbersUseCase(this._repository);

  Future<ResponseModel> call() async {
    return await _repository.getPhoneNumbers();
  }
}
