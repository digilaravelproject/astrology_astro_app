import 'package:astro_astrologer/features/orders/data/models/astrologer_order_model.dart';

abstract class IOrdersRepository {
  Future<List<AstrologerOrderModel>> getOrders({
    String? status,
    String? type,
    int page = 1,
    int perPage = 15,
  });
}
