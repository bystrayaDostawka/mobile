import '../../../../core/usecase/usecase.dart';
import '../repositories/orders_repository.dart';

class DeleteOrderCommentParams {
  final int orderId;
  final int commentId;

  const DeleteOrderCommentParams({
    required this.orderId,
    required this.commentId,
  });
}

class DeleteOrderCommentUseCase {
  DeleteOrderCommentUseCase({required this.ordersRepository});

  final OrdersRepository ordersRepository;

  Future<Result<void>> call(DeleteOrderCommentParams params) async {
    return await ordersRepository.deleteOrderComment(params.orderId, params.commentId);
  }
}
