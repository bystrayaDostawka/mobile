import '../../../../core/error/failures.dart' as failures;
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_status_entity.dart';
import '../../domain/entities/order_comment_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_datasource.dart';
import '../models/orders_response_model.dart';
import '../models/order_details_response_model.dart';
import '../models/order_status_model.dart';
import '../mappers/order_comment_mapper.dart';

/// Реализация репозитория заявок
class OrdersRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl({required this.remoteDataSource});

  final OrdersRemoteDataSource remoteDataSource;

  @override
  Future<Result<List<OrderEntity>>> getOrders({
    String? search,
    int? orderStatusId,
    List<int>? selectedStatusIds,
    String? deliveryAt,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final orders = await remoteDataSource.getOrders(
        search: search,
        orderStatusId: orderStatusId,
        selectedStatusIds: selectedStatusIds,
        deliveryAt: deliveryAt,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

      // Преобразуем модели в доменные сущности
      final orderEntities = orders.map((order) => _mapToEntity(order)).toList();

      return Result.success(orderEntities);
    } catch (e) {
      if (e is failures.Failure) {
        return Result.failure(e);
      }
      return Result.failure(
        const failures.ServerFailure('Ошибка получения заявок'),
      );
    }
  }

  @override
  Future<Result<OrderDetailsEntity>> getOrderDetails(int orderId) async {
    try {
      final orderDetails = await remoteDataSource.getOrderDetails(orderId);
      final orderDetailsEntity = _mapToDetailsEntity(orderDetails);
      return Result.success(orderDetailsEntity);
    } catch (e) {
      if (e is failures.Failure) {
        return Result.failure(e);
      }
      return Result.failure(
        const failures.ServerFailure('Ошибка получения деталей заказа'),
      );
    }
  }

  @override
  Future<Result<List<OrderStatusEntity>>> getOrderStatuses() async {
    try {
      final statuses = await remoteDataSource.getOrderStatuses();
      final statusEntities = statuses
          .map((status) => _mapToStatusEntity(status))
          .toList();
      return Result.success(statusEntities);
    } catch (e) {
      if (e is failures.Failure) {
        return Result.failure(e);
      }
      return Result.failure(
        const failures.ServerFailure('Ошибка получения статусов заказов'),
      );
    }
  }

  @override
  Future<Result<OrderDetailsEntity>> updateOrderStatus(
    int orderId,
    int orderStatusId,
    String? note,
    DateTime? deliveryDate,
  ) async {
    try {
      final updatedOrder = await remoteDataSource.updateOrderStatus(
        orderId,
        orderStatusId,
        note,
        deliveryDate,
      );
      final orderDetailsEntity = _mapToDetailsEntity(updatedOrder);
      return Result.success(orderDetailsEntity);
    } catch (e) {
      if (e is failures.Failure) {
        return Result.failure(e);
      }
      return Result.failure(
        const failures.ServerFailure('Ошибка обновления статуса заказа'),
      );
    }
  }

  /// Преобразование модели в доменную сущность
  OrderEntity _mapToEntity(OrderModel model) {
    return OrderEntity(
      id: model.id,
      orderNumber: model.orderNumber,
      bankId: model.bankId,
      product: model.product,
      name: model.name,
      surname: model.surname,
      patronymic: model.patronymic,
      phone: model.phone,
      address: model.address,
      deliveryAt: DateTime.parse(model.deliveryAt),
      deliveredAt: model.deliveredAt != null
          ? DateTime.parse(model.deliveredAt!)
          : null,
      orderStatusId: model.orderStatusId,
      note: model.note,
      declinedReason: model.declinedReason,
      createdAt: DateTime.parse(model.createdAt),
      updatedAt: DateTime.parse(model.updatedAt),
      bankName: model.bank.name,
      courierName: model.courier.name,
      commentsCount: model.commentsCount,
      uncompletedCommentsCount: model.uncompletedCommentsCount,
    );
  }

  /// Преобразование модели статуса в доменную сущность
  OrderStatusEntity _mapToStatusEntity(OrderStatusModel model) {
    return OrderStatusEntity(
      id: model.id,
      title: model.title,
      color: model.color,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  OrderDetailsEntity _mapToDetailsEntity(OrderDetailsResponseModel model) {
    return OrderDetailsEntity(
      id: model.id ?? 0,
      bankId: model.bankId ?? 0,
      product: model.product ?? '',
      name: model.name ?? '',
      surname: model.surname ?? '',
      patronymic: model.patronymic ?? '',
      phone: model.phone ?? '',
      address: model.address ?? '',
      deliveryAt: model.deliveryAt,
      deliveredAt: model.deliveredAt,
      courierId: model.courierId,
      orderStatusId: model.orderStatusId ?? 0,
      note: model.note,
      declinedReason: model.declinedReason,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      bankName: model.bank?.name ?? 'Не указан',
      photos: (model.photos ?? [])
          .map(
            (photo) => PhotoEntity(
              id: photo.id ?? 0,
              orderId: photo.orderId ?? 0,
              filePath: photo.filePath,
              url: photo.url,
              createdAt: photo.createdAt,
              updatedAt: photo.updatedAt,
            ),
          )
          .toList(),
      courierComment: model.courierComment,
    );
  }

  @override
  Future<Result<List<PhotoEntity>>> getOrderPhotos(int orderId) async {
    try {
      final photos = await remoteDataSource.getOrderPhotos(orderId);

      // Преобразуем модели в доменные сущности
      final photoEntities = photos
          .map(
            (photo) => PhotoEntity(
              id: photo.id ?? 0,
              orderId: photo.orderId ?? 0,
              filePath: photo.filePath,
              url: photo.url,
              createdAt: photo.createdAt,
              updatedAt: photo.updatedAt,
            ),
          )
          .toList();

      return Result.success(photoEntities);
    } catch (e) {
      if (e is failures.Failure) {
        return Result.failure(e);
      }
      return Result.failure(
        const failures.ServerFailure('Ошибка получения фотографий'),
      );
    }
  }


  @override
  Future<Result<List<PhotoEntity>>> uploadOrderPhotos(
    int orderId,
    List<String> photoPaths,
  ) async {
    try {
      final photos = await remoteDataSource.uploadOrderPhotos(
        orderId,
        photoPaths,
      );

      // Преобразуем модели в доменные сущности
      final photoEntities = photos
          .map(
            (photo) => PhotoEntity(
              id: photo.id ?? 0,
              orderId: photo.orderId ?? 0,
              filePath: photo.filePath,
              url: photo.url,
              createdAt: photo.createdAt,
              updatedAt: photo.updatedAt,
            ),
          )
          .toList();

      return Result.success(photoEntities);
    } catch (e) {
      if (e is failures.Failure) {
        return Result.failure(e);
      }
      return Result.failure(
        const failures.ServerFailure('Ошибка загрузки фотографий'),
      );
    }
  }

  @override
  Future<Result<void>> deleteOrderPhoto(int orderId, int photoId) async {
    try {
      await remoteDataSource.deleteOrderPhoto(orderId, photoId);

      return Result.success(null);
    } catch (e) {
      if (e is failures.Failure) {
        return Result.failure(e);
      }
      return Result.failure(
        const failures.ServerFailure('Ошибка удаления фотографии'),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> createCourierNote(
    int orderId,
    String courierNote,
  ) async {
    try {
      final result = await remoteDataSource.createCourierNote(
        orderId,
        courierNote,
      );

      return Result.success(result);
    } catch (e) {
      if (e is failures.Failure) {
        return Result.failure(e);
      }
      return Result.failure(
        const failures.ServerFailure('Ошибка создания заметки курьера'),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> updateCourierNote(
    int orderId,
    String courierNote,
  ) async {
    try {
      final result = await remoteDataSource.updateCourierNote(
        orderId,
        courierNote,
      );

      return Result.success(result);
    } catch (e) {
      if (e is failures.Failure) {
        return Result.failure(e);
      }
      return Result.failure(
        const failures.ServerFailure('Ошибка обновления заметки курьера'),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> deleteCourierNote(int orderId) async {
    try {
      final result = await remoteDataSource.deleteCourierNote(orderId);

      return Result.success(result);
    } catch (e) {
      if (e is failures.Failure) {
        return Result.failure(e);
      }
      return Result.failure(
        const failures.ServerFailure('Ошибка удаления заметки курьера'),
      );
    }
  }

  @override
  Future<Result<List<OrderCommentEntity>>> getOrderComments(int orderId) async {
    try {
      final comments = await remoteDataSource.getOrderComments(orderId);
      final entities = comments
          .map((model) => OrderCommentMapper.toEntity(model))
          .toList();
      return Result.success(entities);
    } catch (e) {
      if (e is failures.Failure) {
        return Result.failure(e);
      }
      return Result.failure(
        const failures.ServerFailure('Ошибка получения комментариев'),
      );
    }
  }

  @override
  Future<Result<List<OrderCommentEntity>>> getCourierComments() async {
    try {
      final comments = await remoteDataSource.getCourierComments();
      final entities = comments
          .map((model) => OrderCommentMapper.toEntity(model))
          .toList();
      return Result.success(entities);
    } catch (e) {
      if (e is failures.Failure) {
        return Result.failure(e);
      }
      return Result.failure(
        const failures.ServerFailure('Ошибка получения комментариев курьера'),
      );
    }
  }

  @override
  Future<Result<OrderCommentEntity>> createOrderComment(int orderId, String comment) async {
    try {
      final commentModel = await remoteDataSource.createOrderComment(orderId, comment);
      final entity = OrderCommentMapper.toEntity(commentModel);
      return Result.success(entity);
    } catch (e) {
      if (e is failures.Failure) {
        return Result.failure(e);
      }
      return Result.failure(
        const failures.ServerFailure('Ошибка создания комментария'),
      );
    }
  }

  @override
  Future<Result<OrderCommentEntity>> updateOrderComment(
    int orderId,
    int commentId,
    bool isCompleted,
  ) async {
    try {
      final commentModel = await remoteDataSource.updateOrderComment(orderId, commentId, isCompleted);
      final entity = OrderCommentMapper.toEntity(commentModel);
      return Result.success(entity);
    } catch (e) {
      if (e is failures.Failure) {
        return Result.failure(e);
      }
      return Result.failure(
        const failures.ServerFailure('Ошибка обновления комментария'),
      );
    }
  }

  @override
  Future<Result<void>> deleteOrderComment(int orderId, int commentId) async {
    try {
      await remoteDataSource.deleteOrderComment(orderId, commentId);
      return Result.success(null);
    } catch (e) {
      if (e is failures.Failure) {
        return Result.failure(e);
      }
      return Result.failure(
        const failures.ServerFailure('Ошибка удаления комментария'),
      );
    }
  }
}
