import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/features/offers/domain/models/offer_model.dart';
import 'package:astro_astrologer/features/offers/domain/models/offer_history_model.dart';

abstract class OfferRepository {
  Future<List<OfferModel>> getOffers();
  Future<bool> toggleOffer(int id);
  Future<List<OfferHistoryModel>> getOfferHistory();
}

class OfferRepositoryImpl implements OfferRepository {
  final ApiClient apiClient;

  OfferRepositoryImpl({required this.apiClient});

  @override
  Future<List<OfferModel>> getOffers() async {
    final response = await apiClient.get(AppUrls.astrologerOffers);
    if (response.isSuccess) {
      final data = response.body;
      final List<dynamic> listData = data is List ? data : (data is Map ? data['data'] ?? [] : []);
      return listData.map((json) => OfferModel.fromJson(json)).toList();
    } else {
      throw Exception(response.message ?? "Failed to fetch offers");
    }
  }

  @override
  Future<bool> toggleOffer(int id) async {
    final response = await apiClient.post(AppUrls.activateOffer(id), data: {});
    if (response.isSuccess) {
      final data = response.body;
      final status = data is Map ? data['status'] : null;
      return status == 'active';
    } else {
      throw Exception(response.message ?? "Failed to toggle offer");
    }
  }

  @override
  Future<List<OfferHistoryModel>> getOfferHistory() async {
    final response = await apiClient.get(AppUrls.offerHistory);
    if (response.isSuccess) {
      final data = response.body;
      final List<dynamic> listData = data is List ? data : (data is Map ? data['data'] ?? [] : []);
      return listData.map((json) => OfferHistoryModel.fromJson(json)).toList();
    } else {
      throw Exception(response.message ?? "Failed to fetch offer history");
    }
  }
}
