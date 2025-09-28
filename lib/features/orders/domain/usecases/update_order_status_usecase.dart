import '../../../../core/usecase/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

/// Use case для обновления статуса заказа
class UpdateOrderStatusUseCase {
  const UpdateOrderStatusUseCase({required this.ordersRepository});

  final OrdersRepository ordersRepository;

  Future<Result<OrderDetailsEntity>> call(
    UpdateOrderStatusParams params,
  ) async {
    return await ordersRepository.updateOrderStatus(
      params.orderId,
      params.orderStatusId,
      params.note,
      params.deliveryDate,
    );
  }
}

/// Параметры для обновления статуса заказа
class UpdateOrderStatusParams {
  const UpdateOrderStatusParams({
    required this.orderId,
    required this.orderStatusId,
    this.note,
    this.deliveryDate,
  });

  final int orderId;
  final int orderStatusId;
  final String? note;
  final DateTime? deliveryDate;
}
