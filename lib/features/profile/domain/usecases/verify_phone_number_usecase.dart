import 'package:astro_astrologer/core/services/network/response_model.dart';
import 'package:astro_astrologer/features/profile/domain/repositories/phone_number_repository_interface.dart';

class VerifyPhoneNumberUseCase {
  final PhoneNumberRepositoryInterface _repository;

  VerifyPhoneNumberUseCase(this._repository);

  Future<ResponseModel> call(int id, String otp) async {
    return await _repository.verifyPhoneNumber(id, otp);
  }
}
