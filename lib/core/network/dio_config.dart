import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../error/failures.dart';
import '../../shared/constants/app_constants.dart';
import '../services/auth_service.dart';
import '../services/connectivity_service.dart';

/// Конфигурация Dio для HTTP клиента
class DioConfig {
  static Dio createDio() {
    final dio = Dio();

    // Базовые настройки
    dio.options.baseUrl = AppConstants.baseUrl;
    dio.options.connectTimeout = AppConstants.connectionTimeout;
    dio.options.receiveTimeout = AppConstants.receiveTimeout;
    dio.options.contentType = Headers.jsonContentType;

    // Интерцепторы
    dio.interceptors.addAll([
      _LoggingInterceptor(),
      _AuthInterceptor(),
      _ErrorInterceptor(),
    ]);

    return dio;
  }
}

/// Интерцептор для логирования
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('REQUEST[${options.method}] => PATH: ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );
    super.onError(err, handler);
  }
}

/// Интерцептор для авторизации
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Добавляем токен к запросам, кроме авторизации
    if (!options.path.contains('/login')) {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: AppConstants.authTokenKey);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    super.onRequest(options, handler);
  }
}

/// Интерцептор для обработки ошибок
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        handler.next(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            type: err.type,
            error: const NetworkFailure('Таймаут соединения'),
          ),
        );
        return;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        switch (statusCode) {
          case 401:
            _handleTokenExpiry();
            handler.next(
              DioException(
                requestOptions: err.requestOptions,
                response: err.response,
                type: DioExceptionType.badResponse,
                error: const AuthFailure(
                  'Сессия истекла. Необходимо войти заново',
                ),
              ),
            );
            return;
          case 403:
            _handleTokenExpiry();
            handler.next(
              DioException(
                requestOptions: err.requestOptions,
                response: err.response,
                type: DioExceptionType.badResponse,
                error: const AuthFailure(
                  'Доступ запрещен. Необходимо войти заново',
                ),
              ),
            );
            return;
          case 404:
            handler.next(
              DioException(
                requestOptions: err.requestOptions,
                response: err.response,
                type: DioExceptionType.badResponse,
                error: const ServerFailure('Ресурс не найден'),
              ),
            );
            return;
          case 409:
            // Ошибка конфликта - получаем детали из ответа
            print('❌ Ошибка конфликта $statusCode: ${err.response?.data}');
            final responseData = err.response?.data;
            String errorMessage = 'Конфликт данных';

            if (responseData is Map<String, dynamic>) {
              if (responseData.containsKey('message')) {
                errorMessage = responseData['message'].toString();
              } else if (responseData.containsKey('error')) {
                errorMessage = responseData['error'].toString();
              }
            } else if (responseData is String) {
              errorMessage = responseData;
            }

            handler.next(
              DioException(
                requestOptions: err.requestOptions,
                response: err.response,
                type: DioExceptionType.badResponse,
                error: ServerFailure('Конфликт: $errorMessage'),
              ),
            );
            return;
          case 422:
            // Ошибка валидации - получаем детали из ответа
            print('❌ Ошибка валидации $statusCode: ${err.response?.data}');
            final responseData = err.response?.data;
            String errorMessage = 'Ошибка валидации данных';

            if (responseData is Map<String, dynamic>) {
              // Пытаемся извлечь сообщение об ошибке
              if (responseData.containsKey('message')) {
                errorMessage = responseData['message'].toString();
              } else if (responseData.containsKey('error')) {
                errorMessage = responseData['error'].toString();
              } else if (responseData.containsKey('errors')) {
                // Если есть массив ошибок валидации
                final errors = responseData['errors'];
                if (errors is Map<String, dynamic>) {
                  final errorList = errors.values
                      .expand((e) => e is List ? e : [e])
                      .toList();
                  errorMessage = errorList.join(', ');
                } else if (errors is List) {
                  errorMessage = errors.join(', ');
                }
              }
            } else if (responseData is String) {
              errorMessage = responseData;
            }

            handler.next(
              DioException(
                requestOptions: err.requestOptions,
                response: err.response,
                type: DioExceptionType.badResponse,
                error: ServerFailure('Ошибка валидации: $errorMessage'),
              ),
            );
            return;
          case 500:
            // Проверяем, не является ли это ошибкой авторизации
            final responseData = err.response?.data;
            if (responseData is String) {
              // Если сервер возвращает HTML вместо JSON, возможно токен истек
              if (responseData.contains('<!DOCTYPE html>') ||
                  responseData.contains('Server Error') ||
                  responseData.contains('token') ||
                  responseData.contains('expired') ||
                  responseData.contains('unauthorized')) {
                _handleTokenExpiry();
                throw const AuthFailure(
                  'Сессия истекла. Необходимо войти заново',
                );
              }
            }
            // Попробуем получить детали ошибки из ответа
            print('❌ Ошибка сервера $statusCode: ${err.response?.data}');
            final errorMessage =
                err.response?.data?['message'] ??
                err.response?.data?['error'] ??
                'Внутренняя ошибка сервера';
            handler.next(
              DioException(
                requestOptions: err.requestOptions,
                response: err.response,
                type: DioExceptionType.badResponse,
                error: ServerFailure('Ошибка сервера: $errorMessage'),
              ),
            );
            return;
          default:
            handler.next(
              DioException(
                requestOptions: err.requestOptions,
                response: err.response,
                type: DioExceptionType.badResponse,
                error: ServerFailure('Ошибка сервера: $statusCode'),
              ),
            );
            return;
        }
      case DioExceptionType.cancel:
        handler.next(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            type: DioExceptionType.cancel,
            error: const ServerFailure('Запрос отменен'),
          ),
        );
        return;
      case DioExceptionType.connectionError:
        handler.next(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            type: DioExceptionType.connectionError,
            error: const NetworkFailure('Ошибка подключения'),
          ),
        );
        return;
      case DioExceptionType.badCertificate:
        handler.next(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            type: DioExceptionType.badCertificate,
            error: const ServerFailure('Ошибка сертификата'),
          ),
        );
        return;
      case DioExceptionType.unknown:
        // Проверяем подключение к интернету
        final hasInternet = await ConnectivityService().hasInternetConnection();
        if (!hasInternet) {
          handler.next(
            DioException(
              requestOptions: err.requestOptions,
              response: err.response,
              type: DioExceptionType.unknown,
              error: const NetworkFailure('Нет подключения к интернету'),
            ),
          );
          return;
        }

        // Если есть интернет, но ошибка unknown - это другая проблема
        if (err.message == null || err.message!.isEmpty) {
          handler.next(
            DioException(
              requestOptions: err.requestOptions,
              response: err.response,
              type: DioExceptionType.unknown,
              error: const NetworkFailure('Ошибка сети: неизвестная причина'),
            ),
          );
          return;
        }
        handler.next(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            type: DioExceptionType.unknown,
            error: NetworkFailure('Ошибка сети: ${err.message}'),
          ),
        );
        return;
    }
  }

  /// Обработка истечения токена
  void _handleTokenExpiry() async {
    try {
      // Используем AuthService для обработки истечения токена
      await authService.handleTokenExpiry();
    } catch (e) {
      // Игнорируем ошибки при обработке токена
    }
  }
}
