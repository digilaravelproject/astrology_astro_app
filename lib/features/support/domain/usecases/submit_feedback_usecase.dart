import 'package:astro_astrologer/core/services/network/response_model.dart';
import 'package:astro_astrologer/features/support/domain/repositories/support_repository.dart';

class SubmitFeedbackUseCase {
  final SupportRepository repository;

  SubmitFeedbackUseCase({required this.repository});

  Future<ResponseModel> execute(int rating, String comment) async {
    return await repository.submitFeedback(rating, comment);
  }
}
