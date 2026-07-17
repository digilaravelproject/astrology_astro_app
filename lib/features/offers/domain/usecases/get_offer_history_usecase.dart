import 'package:astro_astrologer/features/offers/data/repositories/offer_repository.dart';
import 'package:astro_astrologer/features/offers/domain/models/offer_history_model.dart';

class GetOfferHistoryUseCase {
  final OfferRepository repository;

  GetOfferHistoryUseCase(this.repository);

  Future<List<OfferHistoryModel>> call() async {
    return await repository.getOfferHistory();
  }
}
