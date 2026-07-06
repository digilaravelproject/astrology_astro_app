import 'package:astro_astrologer/features/offers/data/repositories/offer_repository.dart';
import 'package:astro_astrologer/features/offers/domain/models/offer_model.dart';

class GetOffersUseCase {
  final OfferRepository repository;

  GetOffersUseCase(this.repository);

  Future<List<OfferModel>> call() async {
    return await repository.getOffers();
  }
}
