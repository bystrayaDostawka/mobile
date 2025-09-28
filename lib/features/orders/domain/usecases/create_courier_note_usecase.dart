import '../../../../core/usecase/usecase.dart';
import '../repositories/orders_repository.dart';

/// Use case для создания заметки курьера
class CreateCourierNoteUseCase {
  CreateCourierNoteUseCase({required this.ordersRepository});

  final OrdersRepository ordersRepository;

  Future<Result<Map<String, dynamic>>> call(
    CreateCourierNoteParams params,
  ) async {
    return await ordersRepository.createCourierNote(
      params.orderId,
      params.courierNote,
    );
  }
}

/// Параметры для создания заметки курьера
class CreateCourierNoteParams {
  final int orderId;
  final String courierNote;

  const CreateCourierNoteParams({
    required this.orderId,
    required this.courierNote,
  });
}
