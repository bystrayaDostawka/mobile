import '../../../../core/usecase/usecase.dart';
import '../entities/order_file_entity.dart';
import '../repositories/orders_repository.dart';

class GetOrderFilesUseCase {
  GetOrderFilesUseCase({required this.repository});

  final OrdersRepository repository;

  Future<Result<List<OrderFileEntity>>> call(GetOrderFilesParams params) async {
    return await repository.getOrderFiles(params.orderId);
  }
}

class GetOrderFilesParams {
  const GetOrderFilesParams({required this.orderId});

  final int orderId;
}
