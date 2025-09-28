import '../../../../core/usecase/usecase.dart';
import '../entities/order_comment_entity.dart';
import '../repositories/orders_repository.dart';

class CreateOrderCommentParams {
  final int orderId;
  final String comment;

  const CreateOrderCommentParams({
    required this.orderId,
    required this.comment,
  });
}

class CreateOrderCommentUseCase {
  CreateOrderCommentUseCase({required this.ordersRepository});

  final OrdersRepository ordersRepository;

  Future<Result<OrderCommentEntity>> call(CreateOrderCommentParams params) async {
    return await ordersRepository.createOrderComment(params.orderId, params.comment);
  }
}
