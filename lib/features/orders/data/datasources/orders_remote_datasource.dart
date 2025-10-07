import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/orders_response_model.dart';
import '../models/order_details_response_model.dart';
import '../models/order_status_model.dart';
import '../models/photo_model.dart';
import '../models/order_file_model.dart';
import '../models/order_comment_model.dart';
import '../models/create_order_request.dart';

/// Абстрактный интерфейс для работы с удаленными данными заявок
abstract class OrdersRemoteDataSource {
  /// Получение списка заявок для курьера
  Future<List<OrderModel>> getOrders({
    String? search,
    int? orderStatusId,
    List<int>? selectedStatusIds,
    String? deliveryAt,
    String? dateFrom,
    String? dateTo,
  });

  /// Получение деталей заказа по ID
  Future<OrderDetailsResponseModel> getOrderDetails(int orderId);

  /// Создание нового заказа
  Future<OrderDetailsResponseModel> createOrder({
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
  Future<List<OrderStatusModel>> getOrderStatuses();

  /// Обновление статуса заказа
  Future<OrderDetailsResponseModel> updateOrderStatus(
    int orderId,
    int orderStatusId,
    String? note,
    DateTime? deliveryDate,
    {String? deliveryTimeRange}
  );

  /// Получение фотографий заказа
  Future<List<PhotoModel>> getOrderPhotos(int orderId);


  /// Загрузка нескольких фотографий заказа
  Future<List<PhotoModel>> uploadOrderPhotos(
    int orderId,
    List<String> photoPaths,
  );

  /// Удаление фотографии заказа
  Future<Map<String, dynamic>> deleteOrderPhoto(int orderId, int photoId);

  /// Создание заметки курьера
  Future<Map<String, dynamic>> createCourierNote(
    int orderId,
    String courierNote,
  );

  /// Обновление заметки курьера
  Future<Map<String, dynamic>> updateCourierNote(
    int orderId,
    String courierNote,
  );

  /// Удаление заметки курьера
  Future<Map<String, dynamic>> deleteCourierNote(int orderId);

  /// Получение комментариев заказа
  Future<List<OrderCommentModel>> getOrderComments(int orderId);

  /// Получение всех комментариев курьера
  Future<List<OrderCommentModel>> getCourierComments();

  /// Создание комментария заказа
  Future<OrderCommentModel> createOrderComment(int orderId, String comment);

  /// Обновление статуса комментария
  Future<OrderCommentModel> updateOrderComment(
    int orderId,
    int commentId,
    bool isCompleted,
  );

  /// Удаление комментария
  Future<void> deleteOrderComment(int orderId, int commentId);

  /// Получение файлов заказа
  Future<List<OrderFileModel>> getOrderFiles(int orderId);

  /// Получение информации о файле заказа
  Future<OrderFileModel> getOrderFile(int orderId, int fileId);

  /// Скачивание файла заказа
  Future<Response<List<int>>> downloadOrderFile(int orderId, int fileId);
}

/// Реализация удаленного источника данных заявок
class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  OrdersRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<List<OrderModel>> getOrders({
    String? search,
    int? orderStatusId,
    List<int>? selectedStatusIds,
    String? deliveryAt,
    String? dateFrom,
    String? dateTo,
  }) async {
    print('🌐 OrdersRemoteDataSource: Получаем заявки');

    // Строим query параметры
    final queryParams = <String, dynamic>{};

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (orderStatusId != null) {
      queryParams['order_status_id'] = orderStatusId;
    }
    // Поддержка множественного выбора статусов
    if (selectedStatusIds != null && selectedStatusIds.isNotEmpty) {
      queryParams['order_status_ids'] = selectedStatusIds.join(',');
      print('🌐 OrdersRemoteDataSource: Добавляем order_status_ids: ${selectedStatusIds.join(',')}');
    }
    if (deliveryAt != null && deliveryAt.isNotEmpty) {
      queryParams['delivery_at'] = deliveryAt;
    }
    if (dateFrom != null && dateFrom.isNotEmpty) {
      queryParams['date_from'] = dateFrom;
    }
    if (dateTo != null && dateTo.isNotEmpty) {
      queryParams['date_to'] = dateTo;
    }

    print(
      '🌐 OrdersRemoteDataSource: Итоговые параметры запроса: $queryParams',
    );
    final response = await apiClient.getOrders(queryParams);
    return response;
  }

  @override
  Future<OrderDetailsResponseModel> getOrderDetails(int orderId) async {
    print('🌐 OrdersRemoteDataSource: Получаем детали заказа $orderId');
    return await apiClient.getOrderById(orderId);
  }

  @override
  Future<OrderDetailsResponseModel> createOrder({
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
  }) async {
    print('🌐 OrdersRemoteDataSource: Создаем новый заказ');
    
    final request = CreateOrderRequest(
      bankId: bankId,
      product: product,
      name: name,
      surname: surname,
      patronymic: patronymic,
      phone: phone,
      address: address,
      deliveryDate: deliveryDate,
      deliveryTimeRange: deliveryTimeRange,
      courierId: courierId,
      note: note,
    );
    
    final response = await apiClient.createOrder(request);
    return OrderDetailsResponseModel.fromJson(response);
  }

  @override
  Future<List<OrderStatusModel>> getOrderStatuses() async {
    print('🌐 OrdersRemoteDataSource: Получаем статусы заказов');
    return await apiClient.getOrderStatuses();
  }

  @override
  Future<OrderDetailsResponseModel> updateOrderStatus(
    int orderId,
    int orderStatusId,
    String? note,
    DateTime? deliveryDate,
    {String? deliveryTimeRange}
  ) async {
    print('🌐 OrdersRemoteDataSource: Обновляем статус заказа $orderId');
    print('🌐 OrdersRemoteDataSource: Статус: $orderStatusId, Причина: $note, Дата: $deliveryDate');
    
    final request = UpdateOrderStatusRequest(
      orderStatusId: orderStatusId,
      note: note,
      deliveryDate: deliveryDate,
      deliveryTimeRange: deliveryTimeRange,
    );
    final response = await apiClient.updateOrderStatus(orderId, request);

    print('🌐 OrdersRemoteDataSource: Ответ от сервера: $response');

    // Преобразуем ответ в OrderDetailsResponseModel
    return OrderDetailsResponseModel.fromJson(response);
  }

  @override
  Future<List<PhotoModel>> getOrderPhotos(int orderId) async {
    print('🌐 OrdersRemoteDataSource: Получаем фотографии заказа $orderId');
    return await apiClient.getOrderPhotos(orderId);
  }


  @override
  Future<List<PhotoModel>> uploadOrderPhotos(
    int orderId,
    List<String> photoPaths,
  ) async {
    print(
      '🌐 OrdersRemoteDataSource: Загружаем ${photoPaths.length} фотографий для заказа $orderId',
    );
    return await apiClient.uploadOrderPhotos(orderId, photoPaths);
  }

  @override
  Future<Map<String, dynamic>> deleteOrderPhoto(
    int orderId,
    int photoId,
  ) async {
    print(
      '🌐 OrdersRemoteDataSource: Удаляем фотографию $photoId для заказа $orderId',
    );
    return await apiClient.deleteOrderPhoto(orderId, photoId);
  }

  @override
  Future<Map<String, dynamic>> createCourierNote(
    int orderId,
    String courierNote,
  ) async {
    print(
      '🌐 OrdersRemoteDataSource: Создаем заметку курьера для заказа $orderId',
    );
    return await apiClient.createCourierNote(orderId, courierNote);
  }

  @override
  Future<Map<String, dynamic>> updateCourierNote(
    int orderId,
    String courierNote,
  ) async {
    print(
      '🌐 OrdersRemoteDataSource: Обновляем заметку курьера для заказа $orderId',
    );
    return await apiClient.updateCourierNote(orderId, courierNote);
  }

  @override
  Future<Map<String, dynamic>> deleteCourierNote(int orderId) async {
    print(
      '🌐 OrdersRemoteDataSource: Удаляем заметку курьера для заказа $orderId',
    );
    return await apiClient.deleteCourierNote(orderId);
  }

  @override
  Future<List<OrderCommentModel>> getOrderComments(int orderId) async {
    print('🌐 OrdersRemoteDataSource: Получаем комментарии для заказа $orderId');
    return await apiClient.getOrderComments(orderId);
  }

  @override
  Future<List<OrderCommentModel>> getCourierComments() async {
    print('🌐 OrdersRemoteDataSource: Получаем все комментарии курьера');
    return await apiClient.getCourierComments();
  }

  @override
  Future<OrderCommentModel> createOrderComment(int orderId, String comment) async {
    print('🌐 OrdersRemoteDataSource: Создаем комментарий для заказа $orderId');
    return await apiClient.createOrderComment(orderId, comment);
  }

  @override
  Future<OrderCommentModel> updateOrderComment(
    int orderId,
    int commentId,
    bool isCompleted,
  ) async {
    print('🌐 OrdersRemoteDataSource: Обновляем статус комментария $commentId');
    return await apiClient.updateOrderComment(orderId, commentId, isCompleted);
  }

  @override
  Future<void> deleteOrderComment(int orderId, int commentId) async {
    print('🌐 OrdersRemoteDataSource: Удаляем комментарий $commentId');
    return await apiClient.deleteOrderComment(orderId, commentId);
  }

  @override
  Future<List<OrderFileModel>> getOrderFiles(int orderId) async {
    print('🌐 OrdersRemoteDataSource: Получаем файлы для заказа $orderId');
    return await apiClient.getOrderFiles(orderId);
  }

  @override
  Future<OrderFileModel> getOrderFile(int orderId, int fileId) async {
    print('🌐 OrdersRemoteDataSource: Получаем файл $fileId для заказа $orderId');
    return await apiClient.getOrderFile(orderId, fileId);
  }

  @override
  Future<Response<List<int>>> downloadOrderFile(int orderId, int fileId) async {
    print('🌐 OrdersRemoteDataSource: Скачиваем файл $fileId для заказа $orderId');
    return await apiClient.downloadOrderFile(orderId, fileId);
  }
}
