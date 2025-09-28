import 'package:dio/dio.dart';

import '../../features/auth/data/models/auth_login_response_model.dart'
    as auth_models;
import '../../features/profile/data/model/profile_response_model.dart'
    as profile_models;
import '../../features/profile/data/model/update_profile_request_model.dart';
import '../../features/orders/data/models/orders_response_model.dart'
    as orders_models;
import '../../features/orders/data/models/order_details_response_model.dart'
    as order_details_models;
import '../../features/orders/data/models/order_status_model.dart'
    as order_status_models;
import '../../features/orders/data/models/photo_model.dart' as photo_models;
import '../../features/orders/data/models/order_comment_model.dart' as comment_models;

/// Простой API клиент для работы с сервером
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  /// Авторизация пользователя
  Future<auth_models.AuthLoginResponseModel> login(LoginRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/mobile/login',
      data: request.toJson(),
    );
    return auth_models.AuthLoginResponseModel.fromJson(response.data!);
  }

  /// Выход из системы
  Future<Map<String, dynamic>> logout() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/mobile/logout',
    );
    return response.data ?? {};
  }

  /// Получение профиля пользователя
  Future<profile_models.ProfileResponseModel> getUserProfile() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/mobile/profile',
      );

      // Проверяем, что ответ содержит валидные JSON данные
      if (response.data == null) {
        throw Exception('Сервер вернул пустой ответ');
      }

      // Проверяем, что response.data является Map, а не строкой
      if (response.data is! Map<String, dynamic>) {
        // Если это строка (HTML), возможно это ошибка авторизации
        if (response.data is String) {
          throw Exception(
            'Сервер вернул HTML вместо JSON. Возможно, токен истек.',
          );
        }
        throw Exception('Сервер вернул невалидный JSON ответ');
      }

      return profile_models.ProfileResponseModel.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  /// Обновление профиля пользователя
  Future<profile_models.ProfileResponseModel> updateUserProfile(
    UpdateProfileRequestModel request,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/api/mobile/profile',
      data: request.toJson(),
    );
    return profile_models.ProfileResponseModel.fromJson(response.data!);
  }

  /// Получение списка заявок
  Future<List<orders_models.OrderModel>> getOrders(
    Map<String, dynamic> queryParams,
  ) async {
    final response = await _dio.get<List<dynamic>>(
      '/api/mobile/orders',
      queryParameters: queryParams,
    );
    return (response.data ?? [])
        .map((order) => orders_models.OrderModel.fromJson(order))
        .toList();
  }

  /// Получение деталей заказа по ID
  Future<order_details_models.OrderDetailsResponseModel> getOrderById(
    int id,
  ) async {
    print('📋 Запрос: GET /api/mobile/orders/$id');
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/mobile/orders/$id',
    );
    print('📋 Ответ: ${response.data}');
    return order_details_models.OrderDetailsResponseModel.fromJson(
      response.data!,
    );
  }

  /// Получение списка статусов заказов
  Future<List<order_status_models.OrderStatusModel>> getOrderStatuses() async {
    final response = await _dio.get<List<dynamic>>(
      '/api/mobile/order-statuses',
    );
    return (response.data ?? [])
        .map((status) => order_status_models.OrderStatusModel.fromJson(status))
        .toList();
  }

  /// Обновление статуса заказа
  Future<Map<String, dynamic>> updateOrderStatus(
    int orderId,
    UpdateOrderStatusRequest request,
  ) async {
    print('📋 Запрос: PATCH /api/mobile/orders/$orderId/status');
    print('📋 Данные: ${request.toJson()}');
    print('📋 Полные данные запроса: orderId=$orderId, request=$request');

    final response = await _dio.patch<Map<String, dynamic>>(
      '/api/mobile/orders/$orderId/status',
      data: request.toJson(),
      options: Options(headers: {'Accept': 'application/json'}),
    );

    print('📋 Ответ: ${response.data}');
    return response.data ?? {};
  }

  /// Получение фотографий заказа
  Future<List<photo_models.PhotoModel>> getOrderPhotos(int orderId) async {
    print('📡 Запрос: GET /api/mobile/orders/$orderId/photos');
    final response = await _dio.get<List<dynamic>>(
      '/api/mobile/orders/$orderId/photos',
    );
    print('📡 Ответ: ${response.data}');
    return (response.data ?? [])
        .map((photo) => photo_models.PhotoModel.fromJson(photo))
        .toList();
  }


  /// Загрузка нескольких фотографий заказа
  Future<List<photo_models.PhotoModel>> uploadOrderPhotos(
    int orderId,
    List<String> photoPaths,
  ) async {
    print(
      '📤 Запрос: POST /api/mobile/orders/$orderId/photos (${photoPaths.length} фото)',
    );

    final List<MultipartFile> multipartFiles = [];

    for (int i = 0; i < photoPaths.length; i++) {
      final photoPath = photoPaths[i];

      // Определяем MIME тип файла
      String mimeType = 'image/jpeg'; // По умолчанию JPEG
      if (photoPath.toLowerCase().endsWith('.png')) {
        mimeType = 'image/png';
      } else if (photoPath.toLowerCase().endsWith('.jpg') ||
          photoPath.toLowerCase().endsWith('.jpeg')) {
        mimeType = 'image/jpeg';
      }

      // Создаем MultipartFile с правильным MIME типом
      final multipartFile = await MultipartFile.fromFile(
        photoPath,
        filename: 'photo_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
        contentType: DioMediaType.parse(mimeType),
      );

      multipartFiles.add(multipartFile);
    }

    // Формируем FormData правильно для Laravel
    final formData = FormData();
    for (int i = 0; i < multipartFiles.length; i++) {
      formData.files.add(MapEntry('photos[]', multipartFiles[i]));
    }

    print('📤 FormData fields: ${formData.fields}');
    print('📤 FormData files: ${formData.files.map((e) => '${e.key}: ${e.value.filename}').toList()}');

    final response = await _dio.post<Map<String, dynamic>>(
      '/api/mobile/orders/$orderId/photos',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        headers: {'Accept': 'application/json'},
      ),
    );

    print('📤 Ответ: ${response.data}');

    // Обрабатываем ответ - может быть массив или один объект
    final responseData = response.data;
    if (responseData == null) {
      return [];
    }

    // Если ответ содержит массив фотографий
    if (responseData.containsKey('photos') && responseData['photos'] is List) {
      final photosList = responseData['photos'] as List<dynamic>;
      return photosList
          .map(
            (photo) =>
                photo_models.PhotoModel.fromJson(photo as Map<String, dynamic>),
          )
          .toList();
    }
    // Если ответ - массив фотографий
    else if (responseData is List) {
      return (responseData as List<dynamic>)
          .map(
            (photo) =>
                photo_models.PhotoModel.fromJson(photo as Map<String, dynamic>),
          )
          .toList();
    }
    // Если ответ содержит одну фотографию
    else {
      return [photo_models.PhotoModel.fromJson(responseData)];
    }
  }

  /// Удаление фотографии заказа
  Future<Map<String, dynamic>> deleteOrderPhoto(
    int orderId,
    int photoId,
  ) async {
    print('🗑️ Запрос: DELETE /api/mobile/orders/$orderId/photos/$photoId');

    final response = await _dio.delete<Map<String, dynamic>>(
      '/api/mobile/orders/$orderId/photos/$photoId',
      options: Options(headers: {'Accept': 'application/json'}),
    );

    print('🗑️ Ответ: ${response.data}');
    return response.data ?? {};
  }

  /// Получение уведомлений
  Future<List<dynamic>> getNotifications() async {
    final response = await _dio.get<List<dynamic>>('/api/notifications');
    return response.data ?? [];
  }

  /// Отметка уведомления как прочитанного
  Future<void> markNotificationAsRead(String notificationId) async {
    await _dio.put('/api/notifications/$notificationId/read');
  }

  /// Создание заметки курьера
  Future<Map<String, dynamic>> createCourierNote(
    int orderId,
    String courierNote,
  ) async {
    print('📝 Запрос: POST /api/mobile/orders/$orderId/courier-note');
    print('📝 Данные: {"courier_note": "$courierNote"}');

    final response = await _dio.post<Map<String, dynamic>>(
      '/api/mobile/orders/$orderId/courier-note',
      data: {'courier_note': courierNote},
      options: Options(headers: {'Accept': 'application/json'}),
    );

    print('📝 Ответ: ${response.data}');
    return response.data ?? {};
  }

  /// Обновление заметки курьера
  Future<Map<String, dynamic>> updateCourierNote(
    int orderId,
    String courierNote,
  ) async {
    print('📝 Запрос: PATCH /api/mobile/orders/$orderId/courier-note');
    print('📝 Данные: {"courier_note": "$courierNote"}');

    final response = await _dio.patch<Map<String, dynamic>>(
      '/api/mobile/orders/$orderId/courier-note',
      data: {'courier_note': courierNote},
      options: Options(headers: {'Accept': 'application/json'}),
    );

    print('📝 Ответ: ${response.data}');
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> deleteCourierNote(int orderId) async {
    print('🗑️ Запрос: DELETE /api/mobile/orders/$orderId/courier-note');

    final response = await _dio.delete<Map<String, dynamic>>(
      '/api/mobile/orders/$orderId/courier-note',
      options: Options(headers: {'Accept': 'application/json'}),
    );

    print('🗑️ Ответ: ${response.data}');
    return response.data ?? {};
  }
}

class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

/// Запрос обновления статуса заказа
class UpdateOrderStatusRequest {
  const UpdateOrderStatusRequest({
    required this.orderStatusId,
    this.note,
    this.deliveryDate,
  });

  final int orderStatusId;
  final String? note;
  final DateTime? deliveryDate;

  Map<String, dynamic> toJson() {
    final json = {
      'order_status_id': orderStatusId,
      if (note != null) 'declined_reason': note,
    };
    
    if (deliveryDate != null) {
      // Отправляем дату и время в формате ISO 8601
      json['delivery_at'] = deliveryDate!.toIso8601String();
    }
    
    print('📤 UpdateOrderStatusRequest: Отправляем данные: $json');
    return json;
  }
}

/// Запрос загрузки фото
class UploadPhotoRequest {
  const UploadPhotoRequest({required this.photo});

  final String photo; // Base64 encoded image

  Map<String, dynamic> toJson() {
    return {'photo': photo};
  }
}

// Методы для работы с комментариями заказов
extension OrderCommentsApi on ApiClient {
  /// Получение всех комментариев курьера
  Future<List<comment_models.OrderCommentModel>> getCourierComments() async {
    print('🌐 ApiClient: Получаем все комментарии курьера');
    
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/courier/comments',
    );
    
    final commentsData = response.data!['comments'] as List;
    final comments = commentsData
        .map((json) => comment_models.OrderCommentModel.fromJson(json as Map<String, dynamic>))
        .toList();
    
    print('🌐 ApiClient: Получено ${comments.length} комментариев курьера');
    return comments;
  }

  /// Получение комментариев заказа
  Future<List<comment_models.OrderCommentModel>> getOrderComments(int orderId) async {
    print('🌐 ApiClient: Получаем комментарии для заказа $orderId');
    
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/orders/$orderId/comments',
    );
    
    final commentsData = response.data!['comments'] as List;
    final comments = commentsData
        .map((json) => comment_models.OrderCommentModel.fromJson(json as Map<String, dynamic>))
        .toList();
    
    print('🌐 ApiClient: Получено ${comments.length} комментариев');
    return comments;
  }

  /// Создание комментария
  Future<comment_models.OrderCommentModel> createOrderComment(
    int orderId,
    String comment,
  ) async {
    print('🌐 ApiClient: Создаем комментарий для заказа $orderId');
    
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/orders/$orderId/comments',
      data: {'comment': comment},
    );
    
    final commentModel = comment_models.OrderCommentModel.fromJson(
      response.data!['comment'] as Map<String, dynamic>,
    );
    
    print('🌐 ApiClient: Комментарий создан с ID ${commentModel.id}');
    return commentModel;
  }

  /// Обновление статуса комментария
  Future<comment_models.OrderCommentModel> updateOrderComment(
    int orderId,
    int commentId,
    bool isCompleted,
  ) async {
    print('🌐 ApiClient: Обновляем статус комментария $commentId');
    
    final response = await _dio.patch<Map<String, dynamic>>(
      '/api/orders/$orderId/comments/$commentId',
      data: {'is_completed': isCompleted},
    );
    
    final commentModel = comment_models.OrderCommentModel.fromJson(
      response.data!['comment'] as Map<String, dynamic>,
    );
    
    print('🌐 ApiClient: Статус комментария обновлен');
    return commentModel;
  }

  /// Удаление комментария
  Future<void> deleteOrderComment(int orderId, int commentId) async {
    print('🌐 ApiClient: Удаляем комментарий $commentId');
    
    await _dio.delete('/api/orders/$orderId/comments/$commentId');
    
    print('🌐 ApiClient: Комментарий удален');
  }
}
