import '../../../../core/usecase/usecase.dart';
import '../repositories/orders_repository.dart';

/// Параметры для удаления фотографии заказа
class DeleteOrderPhotoParams {
  final int orderId;
  final int photoId;

  const DeleteOrderPhotoParams({required this.orderId, required this.photoId});
}

/// Use case для удаления фотографии заказа
class DeleteOrderPhotoUseCase implements UseCase<void, DeleteOrderPhotoParams> {
  DeleteOrderPhotoUseCase({required this.repository});

  final OrdersRepository repository;

  @override
  Future<Result<void>> call(DeleteOrderPhotoParams params) async {
    return await repository.deleteOrderPhoto(params.orderId, params.photoId);
  }
}
