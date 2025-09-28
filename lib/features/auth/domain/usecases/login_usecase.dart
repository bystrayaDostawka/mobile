import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../profile/domain/entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use Case для авторизации пользователя
class LoginUseCase extends UseCase<Result<UserEntity>, LoginParams> {
  LoginUseCase({required this.repository});

  final AuthRepository repository;

  @override
  Future<Result<UserEntity>> call(LoginParams params) async {
    return await repository.login(params.email, params.password);
  }
}

/// Параметры для авторизации
class LoginParams extends Equatable {
  const LoginParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}
