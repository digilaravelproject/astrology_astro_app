import 'package:astro_astrologer/features/orders/data/repositories/history_repository.dart';
import 'package:astro_astrologer/features/call/data/models/call_session_model.dart';

class GetAstrologerCallSessionsUseCase {
  final HistoryRepository _repository;

  GetAstrologerCallSessionsUseCase(this._repository);

  Future<CallSessionListResponse> execute({int page = 1}) {
    return _repository.getCallSessions(page: page);
  }
}
