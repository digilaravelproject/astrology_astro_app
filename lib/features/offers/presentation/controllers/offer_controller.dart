import 'package:get/get.dart';
import 'package:astro_astrologer/features/offers/domain/usecases/get_offers_usecase.dart';
import 'package:astro_astrologer/features/offers/domain/usecases/toggle_offer_usecase.dart';
import 'package:astro_astrologer/features/offers/domain/usecases/get_offer_history_usecase.dart';
import 'package:astro_astrologer/features/offers/data/models/offer_model.dart';
import 'package:astro_astrologer/features/offers/data/models/offer_history_model.dart';
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';

class OfferController extends GetxController {
  final GetOffersUseCase getOffersUseCase;
  final ToggleOfferUseCase toggleOfferUseCase;
  final GetOfferHistoryUseCase getOfferHistoryUseCase;

  OfferController({
    required this.getOffersUseCase,
    required this.toggleOfferUseCase,
    required this.getOfferHistoryUseCase,
  });

  var offers = <OfferModel>[].obs;
  var history = <OfferHistoryModel>[].obs;

  var isLoadingOffers = false.obs;
  var isLoadingHistory = false.obs;

  // Track IDs of offers currently being toggled to show loading state on specific switches
  var togglingOfferIds = <int>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchOffers();
    fetchHistory();
  }

  Future<void> fetchOffers() async {
    try {
      isLoadingOffers.value = true;
      final result = await getOffersUseCase();
      offers.assignAll(result);
    } catch (e) {
      CustomSnackBar.disabledSnackbar('Error', e.toString());
    } finally {
      isLoadingOffers.value = false;
    }
  }

  Future<void> fetchOffersSilently() async {
    try {
      final result = await getOffersUseCase();
      offers.assignAll(result);
    } catch (e) {
      // Silently ignore or handle error
    }
  }

  Future<void> fetchHistory() async {
    try {
      isLoadingHistory.value = true;
      final result = await getOfferHistoryUseCase();
      history.assignAll(result);
    } catch (e) {
      CustomSnackBar.disabledSnackbar('Error', e.toString());
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<void> fetchHistorySilently() async {
    try {
      final result = await getOfferHistoryUseCase();
      history.assignAll(result);
    } catch (e) {
      // Silently ignore or handle error
    }
  }

  Future<void> toggleOffer(int offerId) async {
    if (togglingOfferIds.contains(offerId)) return;

    try {
      togglingOfferIds.add(offerId);
      await toggleOfferUseCase(offerId);

      // Refresh both offers and history silently after toggling
      await fetchOffersSilently();
      fetchHistorySilently(); // No need to await history to update UI faster
    } catch (e) {
      CustomSnackBar.disabledSnackbar('Error', e.toString());
    } finally {
      togglingOfferIds.remove(offerId);
    }
  }
}
