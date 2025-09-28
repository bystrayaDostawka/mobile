import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use Case для выхода из системы
class LogoutUseCase extends UseCase<Result<void>, NoParams> {
  LogoutUseCase({required this.repository});

  final AuthRepository repository;

  @override
  Future<Result<void>> call(NoParams params) async {
    return await repository.logout();
  }
}
