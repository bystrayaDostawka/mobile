import '../../../../core/usecase/usecase.dart';
import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';
import '../entities/sort_order.dart';

/// Параметры для сортировки заказов
class SortOrdersParams {
  final List<OrderEntity> orders;
  final SortOrder sortOrder;

  const SortOrdersParams({required this.orders, required this.sortOrder});
}

/// Use case для сортировки заказов
class SortOrdersUseCase
    implements UseCase<List<OrderEntity>, SortOrdersParams> {
  @override
  Future<List<OrderEntity>> call(SortOrdersParams params) async {
    try {
      return _sortOrders(params.orders, params.sortOrder);
    } catch (e) {
      throw ServerFailure('Ошибка сортировки заказов: $e');
    }
  }

  /// Сортировка списка заказов по дате доставки
  List<OrderEntity> _sortOrders(List<OrderEntity> orders, SortOrder sortOrder) {
    final sortedOrders = List<OrderEntity>.from(orders);

    switch (sortOrder) {
      case SortOrder.deliveryAtAsc:
        // Сортировка от старого к новому по дате доставки
        sortedOrders.sort((a, b) => a.deliveryAt.compareTo(b.deliveryAt));
        break;
      case SortOrder.deliveryAtDesc:
        // Сортировка от нового к старому по дате доставки
        sortedOrders.sort((a, b) => b.deliveryAt.compareTo(a.deliveryAt));
        break;
    }

    return sortedOrders;
  }
}
