import '../../../../core/usecase/usecase.dart';
import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

/// Use case для загрузки одной фотографии заказа (использует множественную загрузку внутри)
class UploadOrderPhotoUseCase {
  UploadOrderPhotoUseCase({required this.ordersRepository});

  final OrdersRepository ordersRepository;

  Future<Result<PhotoEntity>> call(UploadOrderPhotoParams params) async {
    // Используем множественную загрузку для одной фотографии
    final result = await ordersRepository.uploadOrderPhotos(
      params.orderId,
      [params.photoPath],
    );

    // Если успешно, возвращаем первую (и единственную) фотографию
    if (result is Success<List<PhotoEntity>> && result.data.isNotEmpty) {
      return Result.success(result.data.first);
    } else if (result is FailureResult<List<PhotoEntity>>) {
      return Result.failure(result.failure);
    } else {
      return Result.failure(const ServerFailure('Не удалось загрузить фотографию'));
    }
  }
}

/// Параметры для загрузки фотографии заказа
class UploadOrderPhotoParams {
  final int orderId;
  final String photoPath;

  const UploadOrderPhotoParams({
    required this.orderId,
    required this.photoPath,
  });
}
