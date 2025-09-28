import '../../../../core/usecase/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

/// Use case для получения деталей заказа
class GetOrderDetailsUseCase {
  GetOrderDetailsUseCase({required this.ordersRepository});

  final OrdersRepository ordersRepository;

  Future<Result<OrderDetailsEntity>> call(GetOrderDetailsParams params) async {
    return await ordersRepository.getOrderDetails(params.orderId);
  }
}

/// Параметры для получения деталей заказа
class GetOrderDetailsParams {
  final int orderId;

  const GetOrderDetailsParams({required this.orderId});
}
