import '../../../../core/usecase/usecase.dart';
import '../repositories/orders_repository.dart';

/// Use case для удаления заметки курьера
class DeleteCourierNoteUseCase {
  DeleteCourierNoteUseCase({required this.ordersRepository});

  final OrdersRepository ordersRepository;

  Future<Result<Map<String, dynamic>>> call(
    DeleteCourierNoteParams params,
  ) async {
    return await ordersRepository.deleteCourierNote(params.orderId);
  }
}

/// Параметры для удаления заметки курьера
class DeleteCourierNoteParams {
  final int orderId;

  const DeleteCourierNoteParams({required this.orderId});
}
