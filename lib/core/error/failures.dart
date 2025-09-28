import 'package:equatable/equatable.dart';

/// Базовый класс для всех ошибок в приложении
abstract class Failure extends Equatable {
  const Failure([this.message = 'Произошла ошибка']);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Ошибка сервера
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Ошибка сервера']);
}

/// Ошибка сети
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Нет подключения к интернету']);
}

/// Ошибка авторизации
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Ошибка авторизации']);
}

/// Ошибка валидации
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Ошибка валидации']);
}

/// Ошибка хранилища
class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Ошибка хранилища']);
}

/// Ошибка камеры
class CameraFailure extends Failure {
  const CameraFailure([super.message = 'Ошибка камеры']);
}

/// Ошибка разрешений
class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Недостаточно разрешений']);
}
