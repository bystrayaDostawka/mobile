import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/error/failures.dart' as failures;
import '../../../../core/usecase/usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../profile/domain/entities/user_entity.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../../../shared/constants/app_constants.dart';

/// Реализация репозитория авторизации
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  @override
  Future<Result<UserEntity>> login(String email, String password) async {
    try {
      final authResponse = await remoteDataSource.login(email, password);

      // Сохраняем токен
      if (authResponse.token != null) {
        await secureStorage.write(
          key: AppConstants.authTokenKey,
          value: authResponse.token!,
        );
      }

      // Сохраняем роль пользователя
      if (authResponse.user?.role != null) {
        await secureStorage.write(
          key: AppConstants.userRoleKey,
          value: authResponse.user!.role!,
        );
      }

      // Преобразуем в доменную сущность
      final userEntity = authResponse.toEntity();
      if (userEntity == null) {
        return Result.failure(
          const failures.AuthFailure('Данные пользователя не найдены'),
        );
      }

      return Result.success(userEntity);
    } catch (e) {
      if (e is failures.Failure) {
        return Result.failure(e);
      }
      return Result.failure(const failures.AuthFailure('Ошибка авторизации'));
    }
  }

  @override
  Future<Result<bool>> isAuthenticated() async {
    try {
      final token = await secureStorage.read(key: AppConstants.authTokenKey);
      return Result.success(token != null);
    } catch (e) {
      return Result.failure(
        const failures.StorageFailure('Ошибка проверки авторизации'),
      );
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      // Вызываем API для выхода
      await remoteDataSource.logout();

      // Удаляем локальные данные
      await secureStorage.delete(key: AppConstants.authTokenKey);
      await secureStorage.delete(key: AppConstants.userRoleKey);

      return const Result.success(null);
    } catch (e) {
      // Даже если API вызов не удался, удаляем локальные данные
      await secureStorage.delete(key: AppConstants.authTokenKey);
      await secureStorage.delete(key: AppConstants.userRoleKey);

      return const Result.success(null);
    }
  }

  @override
  Future<Result<String>> getUserRole() async {
    try {
      final role = await secureStorage.read(key: AppConstants.userRoleKey);
      if (role != null) {
        return Result.success(role);
      }
      return Result.failure(
        const failures.AuthFailure('Роль пользователя не найдена'),
      );
    } catch (e) {
      return Result.failure(
        const failures.StorageFailure('Ошибка получения роли'),
      );
    }
  }

  @override
  Future<Result<void>> saveAuthToken(String token) async {
    try {
      await secureStorage.write(key: AppConstants.authTokenKey, value: token);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        const failures.StorageFailure('Ошибка сохранения токена'),
      );
    }
  }

  @override
  Future<Result<String?>> getAuthToken() async {
    try {
      final token = await secureStorage.read(key: AppConstants.authTokenKey);
      return Result.success(token);
    } catch (e) {
      return Result.failure(
        const failures.StorageFailure('Ошибка получения токена'),
      );
    }
  }

  @override
  Future<Result<UserEntity>> getCurrentUser() async {
    try {
      // Получаем токен
      final tokenResult = await getAuthToken();
      if (tokenResult is! Success<String?>) {
        return Result.failure(
          const failures.AuthFailure('Пользователь не авторизован'),
        );
      }

      final token = tokenResult.data;
      if (token == null) {
        return Result.failure(const failures.AuthFailure('Токен не найден'));
      }

      // Получаем профиль пользователя через API
      final userProfile = await remoteDataSource.getUserProfile();
      return Result.success(userProfile.toEntity());
    } catch (e) {
      if (e is failures.Failure) {
        return Result.failure(e);
      }
      return Result.failure(
        failures.ServerFailure('Ошибка получения профиля пользователя: $e'),
      );
    }
  }
}
