import '../../../../core/usecase/usecase.dart';
import '../entities/order_comment_entity.dart';
import '../repositories/orders_repository.dart';

class GetOrderCommentsUseCase {
  GetOrderCommentsUseCase({required this.ordersRepository});

  final OrdersRepository ordersRepository;

  Future<Result<List<OrderCommentEntity>>> call(int orderId) async {
    return await ordersRepository.getOrderComments(orderId);
  }
}
