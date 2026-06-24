import 'package:astro_astrologer/features/offers/data/repositories/offer_repository.dart';

class ToggleOfferUseCase {
  final OfferRepository repository;

  ToggleOfferUseCase(this.repository);

  Future<bool> call(int id) async {
    return await repository.toggleOffer(id);
  }
}
