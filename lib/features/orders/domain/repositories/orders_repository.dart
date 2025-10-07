import 'package:dio/dio.dart';

import '../../../../core/usecase/usecase.dart';
import '../entities/order_entity.dart';
import '../entities/order_status_entity.dart';
import '../entities/order_comment_entity.dart';
import '../entities/order_file_entity.dart';

/// Абстрактный интерфейс репозитория заявок в доменном слое
abstract class OrdersRepository {
  /// Получение списка заявок для курьера
  Future<Result<List<OrderEntity>>> getOrders({
    String? search,
    int? orderStatusId,
    List<int>? selectedStatusIds,
    String? deliveryAt,
    String? dateFrom,
    String? dateTo,
  });

  /// Получение деталей заказа по ID
  Future<Result<OrderDetailsEntity>> getOrderDetails(int orderId);

  /// Создание нового заказа
  Future<Result<OrderDetailsEntity>> createOrder({
    required int bankId,
    required String product,
    required String name,
    required String surname,
    required String patronymic,
    required String phone,
    required String address,
    required DateTime deliveryDate,
    String? deliveryTimeRange,
    int? courierId,
    String? note,
  });

  /// Получение списка статусов заказов
  Future<Result<List<OrderStatusEntity>>> getOrderStatuses();

  /// Обновление статуса заказа
  Future<Result<OrderDetailsEntity>> updateOrderStatus(
    int orderId,
    int orderStatusId,
    String? note,
    DateTime? deliveryDate,
    {String? deliveryTimeRange}
  );

  /// Получение фотографий заказа
  Future<Result<List<PhotoEntity>>> getOrderPhotos(int orderId);


  /// Загрузка нескольких фотографий заказа
  Future<Result<List<PhotoEntity>>> uploadOrderPhotos(
    int orderId,
    List<String> photoPaths,
  );

  /// Удаление фотографии заказа
  Future<Result<void>> deleteOrderPhoto(int orderId, int photoId);

  /// Создание заметки курьера
  Future<Result<Map<String, dynamic>>> createCourierNote(
    int orderId,
    String courierNote,
  );

  /// Обновление заметки курьера
  Future<Result<Map<String, dynamic>>> updateCourierNote(
    int orderId,
    String courierNote,
  );

  /// Удаление заметки курьера
  Future<Result<Map<String, dynamic>>> deleteCourierNote(int orderId);

  /// Получение комментариев заказа
  Future<Result<List<OrderCommentEntity>>> getOrderComments(int orderId);

  /// Получение всех комментариев курьера
  Future<Result<List<OrderCommentEntity>>> getCourierComments();

  /// Создание комментария заказа
  Future<Result<OrderCommentEntity>> createOrderComment(int orderId, String comment);

  /// Обновление статуса комментария
  Future<Result<OrderCommentEntity>> updateOrderComment(
    int orderId,
    int commentId,
    bool isCompleted,
  );

  /// Удаление комментария
  Future<Result<void>> deleteOrderComment(int orderId, int commentId);

  /// Получение файлов заказа
  Future<Result<List<OrderFileEntity>>> getOrderFiles(int orderId);

  /// Скачивание файла заказа
  Future<Result<Response<List<int>>>> downloadOrderFile(int orderId, int fileId);
}
