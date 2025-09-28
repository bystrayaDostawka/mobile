import '../../../../core/usecase/usecase.dart';
import '../entities/order_status_entity.dart';
import '../repositories/orders_repository.dart';

/// Use case для получения списка статусов заказов
class GetOrderStatusesUseCase {
  const GetOrderStatusesUseCase({required this.ordersRepository});

  final OrdersRepository ordersRepository;

  Future<Result<List<OrderStatusEntity>>> call() async {
    return await ordersRepository.getOrderStatuses();
  }
}
