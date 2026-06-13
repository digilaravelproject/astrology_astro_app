import '../models/astrologer_order_model.dart';
import '../repositories/i_orders_repository.dart';

class GetAstrologerOrdersUseCase {
  final IOrdersRepository _repository;

  GetAstrologerOrdersUseCase(this._repository);

  Future<List<AstrologerOrderModel>> execute({
    String? status,
    String? type,
    int page = 1,
    int perPage = 15,
  }) {
    return _repository.getOrders(
      status: status,
      type: type,
      page: page,
      perPage: perPage,
    );
  }
}
