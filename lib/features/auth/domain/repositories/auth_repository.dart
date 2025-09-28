import '../../../profile/domain/entities/user_entity.dart';
import '../../../../core/usecase/usecase.dart';

/// Доменный интерфейс репозитория авторизации
abstract class AuthRepository {
  /// Авторизация пользователя
  Future<Result<UserEntity>> login(String email, String password);

  /// Проверка авторизации
  Future<Result<bool>> isAuthenticated();

  /// Выход из системы
  Future<Result<void>> logout();

  /// Получение роли пользователя
  Future<Result<String>> getUserRole();

  /// Сохранение токена авторизации
  Future<Result<void>> saveAuthToken(String token);

  /// Получение токена авторизации
  Future<Result<String?>> getAuthToken();

  /// Получение текущего пользователя
  Future<Result<UserEntity>> getCurrentUser();
}
