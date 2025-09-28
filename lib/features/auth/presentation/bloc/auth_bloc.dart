import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../../profile/domain/entities/user_entity.dart';
import '../../../../core/usecase/usecase.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  const LoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

class TokenExpired extends AuthEvent {
  const TokenExpired();
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  const AuthSuccess({required this.user});

  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

class AuthFailure extends AuthState {
  const AuthFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<TokenExpired>(_onTokenExpired);
  }

  final AuthRepository _authRepository;

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔐 AuthBloc: Начинаем авторизацию для ${event.email}');
    emit(AuthLoading());

    try {
      final result = await _authRepository.login(event.email, event.password);
      print('🔐 AuthBloc: Получен результат: $result');

      if (result is Success<UserEntity>) {
        print('🔐 AuthBloc: Успешная авторизация для ${result.data.name}');
        emit(AuthSuccess(user: result.data));
      } else if (result is FailureResult<UserEntity>) {
        print('🔐 AuthBloc: Ошибка авторизации: ${result.failure}');
        emit(AuthFailure(message: 'Ошибка авторизации'));
      }
    } catch (e) {
      print('🔐 AuthBloc: Исключение: $e');
      emit(AuthFailure(message: 'Ошибка авторизации: $e'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.logout();

    if (result.isSuccess) {
      emit(AuthInitial());
    } else {
      emit(AuthFailure(message: 'Ошибка выхода'));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    print('🔐 AuthBloc: Проверяем статус авторизации');
    emit(AuthLoading());

    try {
      final result = await _authRepository.isAuthenticated();
      print('🔐 AuthBloc: Результат проверки авторизации: $result');

      if (result is Success<bool> && result.data == true) {
        print('🔐 AuthBloc: Пользователь авторизован');
        // Получаем роль пользователя для создания UserEntity
        final roleResult = await _authRepository.getUserRole();
        if (roleResult is Success<String>) {
          // Создаем временную UserEntity для успешной авторизации
          final userEntity = UserEntity(
            id: 1, // Временный ID
            name: 'Пользователь',
            email: 'user@example.com',
            role: roleResult.data,
          );
          emit(AuthSuccess(user: userEntity));
        } else {
          emit(AuthInitial());
        }
      } else {
        print('🔐 AuthBloc: Пользователь не авторизован');
        emit(AuthInitial());
      }
    } catch (e) {
      print('🔐 AuthBloc: Ошибка проверки авторизации: $e');
      emit(AuthInitial());
    }
  }

  Future<void> _onTokenExpired(
    TokenExpired event,
    Emitter<AuthState> emit,
  ) async {
    print('🔐 AuthBloc: Обрабатываем истечение токена');
    emit(AuthFailure(message: 'Сессия истекла. Необходимо войти заново'));
  }
}
