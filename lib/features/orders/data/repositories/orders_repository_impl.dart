import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/features/orders/data/models/astrologer_order_model.dart';
import 'package:astro_astrologer/features/orders/domain/repositories/i_orders_repository.dart';

class OrdersRepositoryImpl implements IOrdersRepository {
  final ApiClient _apiClient;

  OrdersRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<AstrologerOrderModel>> getOrders({
    String? status,
    String? type,
    int page = 1,
    int perPage = 15,
  }) async {
    final queryParams = {
      if (status != null) 'status': status,
      if (type != null) 'type': type,
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    final response = await _apiClient.get(
      AppUrls.astrologerOrders,
      queryParameters: queryParams,
    );

    if (response.isSuccess) {
      final List<dynamic> data = response.body?['orders'] ?? [];
      return data.map((e) => AstrologerOrderModel.fromJson(e)).toList();
    } else {
      throw Exception(response.message);
    }
  }
}
