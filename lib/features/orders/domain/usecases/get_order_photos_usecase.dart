import '../../../../core/usecase/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

/// Use case для получения фотографий заказа
class GetOrderPhotosUseCase {
  GetOrderPhotosUseCase({required this.ordersRepository});

  final OrdersRepository ordersRepository;

  Future<Result<List<PhotoEntity>>> call(GetOrderPhotosParams params) async {
    return await ordersRepository.getOrderPhotos(params.orderId);
  }
}

/// Параметры для получения фотографий заказа
class GetOrderPhotosParams {
  final int orderId;

  const GetOrderPhotosParams({required this.orderId});
}
