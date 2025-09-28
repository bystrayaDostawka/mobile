import '../../../../core/usecase/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

/// Use case для получения списка заявок
class GetOrdersUseCase {
  GetOrdersUseCase({required this.ordersRepository});

  final OrdersRepository ordersRepository;

  Future<Result<List<OrderEntity>>> call(GetOrdersParams params) async {
    return await ordersRepository.getOrders(
      search: params.search,
      orderStatusId: params.orderStatusId,
      selectedStatusIds: params.selectedStatusIds,
      deliveryAt: params.deliveryAt,
      dateFrom: params.dateFrom,
      dateTo: params.dateTo,
    );
  }
}

/// Параметры для получения заявок
class GetOrdersParams {
  final String? search;
  final int? orderStatusId;
  final List<int>? selectedStatusIds;
  final String? deliveryAt;
  final String? dateFrom;
  final String? dateTo;

  const GetOrdersParams({
    this.search,
    this.orderStatusId,
    this.selectedStatusIds,
    this.deliveryAt,
    this.dateFrom,
    this.dateTo,
  });
}
