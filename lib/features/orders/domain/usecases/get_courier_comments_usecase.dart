import '../../../../core/usecase/usecase.dart';
import '../entities/order_comment_entity.dart';
import '../repositories/orders_repository.dart';

class GetCourierCommentsUseCase {
  GetCourierCommentsUseCase({required this.ordersRepository});

  final OrdersRepository ordersRepository;

  Future<Result<List<OrderCommentEntity>>> call() async {
    return await ordersRepository.getCourierComments();
  }
}
