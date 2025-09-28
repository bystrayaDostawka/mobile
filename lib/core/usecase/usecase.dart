import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Базовый класс для всех UseCase в приложении
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Базовый класс для UseCase без параметров
abstract class UseCaseNoParams<Type> {
  Future<Type> call();
}

/// Класс для UseCase без параметров
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Результат выполнения UseCase
class Result<T> {
  const Result._();

  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = FailureResult<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  T? get data => isSuccess ? (this as Success<T>).data : null;
  Failure? get failure => isFailure ? (this as FailureResult<T>).failure : null;
}

class Success<T> extends Result<T> {
  const Success(this.data) : super._();
  final T data;
}

class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure) : super._();
  final Failure failure;
}
