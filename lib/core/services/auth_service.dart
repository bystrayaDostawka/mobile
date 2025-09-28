import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../shared/constants/app_constants.dart';

/// Глобальный сервис для управления состоянием авторизации
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // StreamController для уведомления об изменениях состояния авторизации
  final StreamController<bool> _authStateController =
      StreamController<bool>.broadcast();

  /// Stream для отслеживания состояния авторизации
  Stream<bool> get authStateStream => _authStateController.stream;

  /// Текущее состояние авторизации
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  /// Инициализация сервиса
  Future<void> initialize() async {
    await _checkAuthStatus();
  }

  /// Проверка статуса авторизации
  Future<bool> _checkAuthStatus() async {
    try {
      final token = await _storage.read(key: AppConstants.authTokenKey);
      _isAuthenticated = token != null && token.isNotEmpty;
      _authStateController.add(_isAuthenticated);
      return _isAuthenticated;
    } catch (e) {
      _isAuthenticated = false;
      _authStateController.add(false);
      return false;
    }
  }

  /// Обработка истечения токена
  Future<void> handleTokenExpiry() async {
    try {
      // Очищаем все данные авторизации
      await _storage.delete(key: AppConstants.authTokenKey);
      await _storage.delete(key: AppConstants.userRoleKey);

      // Обновляем состояние
      _isAuthenticated = false;
      _authStateController.add(false);
    } catch (e) {
      // Ошибка при очистке токена
    }
  }

  /// Принудительный выход из системы
  Future<void> logout() async {
    await handleTokenExpiry();
  }

  /// Обновление состояния авторизации
  void updateAuthState(bool isAuthenticated) {
    _isAuthenticated = isAuthenticated;
    _authStateController.add(isAuthenticated);
  }

  /// Освобождение ресурсов
  void dispose() {
    _authStateController.close();
  }
}

/// Глобальный экземпляр сервиса
final AuthService authService = AuthService();
