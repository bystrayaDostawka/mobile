import '../../../../core/usecase/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

/// Параметры для загрузки нескольких фотографий заказа
class UploadOrderPhotosParams {
  final int orderId;
  final List<String> photoPaths;

  const UploadOrderPhotosParams({
    required this.orderId,
    required this.photoPaths,
  });
}

/// Use case для загрузки нескольких фотографий заказа
class UploadOrderPhotosUseCase
    extends UseCase<Result<List<PhotoEntity>>, UploadOrderPhotosParams> {
  UploadOrderPhotosUseCase({required this.repository});

  final OrdersRepository repository;

  @override
  Future<Result<List<PhotoEntity>>> call(UploadOrderPhotosParams params) async {
    return await repository.uploadOrderPhotos(
      params.orderId,
      params.photoPaths,
    );
  }
}
