import '../../../../core/usecase/usecase.dart';
import '../entities/order_comment_entity.dart';
import '../repositories/orders_repository.dart';

class UpdateOrderCommentParams {
  final int orderId;
  final int commentId;
  final bool isCompleted;

  const UpdateOrderCommentParams({
    required this.orderId,
    required this.commentId,
    required this.isCompleted,
  });
}

class UpdateOrderCommentUseCase {
  UpdateOrderCommentUseCase({required this.ordersRepository});

  final OrdersRepository ordersRepository;

  Future<Result<OrderCommentEntity>> call(UpdateOrderCommentParams params) async {
    return await ordersRepository.updateOrderComment(
      params.orderId,
      params.commentId,
      params.isCompleted,
    );
  }
}
