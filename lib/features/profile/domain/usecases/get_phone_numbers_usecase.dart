import 'package:astro_astrologer/features/profile/domain/repositories/phone_number_repository_interface.dart';
import 'package:astro_astrologer/core/services/network/response_model.dart';

class GetPhoneNumbersUseCase {
  final PhoneNumberRepositoryInterface _repository;

  GetPhoneNumbersUseCase(this._repository);

  Future<ResponseModel> call() async {
    return await _repository.getPhoneNumbers();
  }
}
