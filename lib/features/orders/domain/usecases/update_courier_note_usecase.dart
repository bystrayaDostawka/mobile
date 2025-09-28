import '../../../../core/usecase/usecase.dart';
import '../repositories/orders_repository.dart';

/// Use case для обновления заметки курьера
class UpdateCourierNoteUseCase {
  UpdateCourierNoteUseCase({required this.ordersRepository});

  final OrdersRepository ordersRepository;

  Future<Result<Map<String, dynamic>>> call(
    UpdateCourierNoteParams params,
  ) async {
    return await ordersRepository.updateCourierNote(
      params.orderId,
      params.courierNote,
    );
  }
}

/// Параметры для обновления заметки курьера
class UpdateCourierNoteParams {
  final int orderId;
  final String courierNote;

  const UpdateCourierNoteParams({
    required this.orderId,
    required this.courierNote,
  });
}
