import '../../../../core/services/network/response_model.dart';
import '../repositories/support_repository.dart';

class SubmitFeedbackUseCase {
  final SupportRepository repository;

  SubmitFeedbackUseCase({required this.repository});

  Future<ResponseModel> execute(int rating, String comment) async {
    return await repository.submitFeedback(rating, comment);
  }
}
