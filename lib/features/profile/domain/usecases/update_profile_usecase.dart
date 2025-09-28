import '../../../../core/usecase/usecase.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/model/update_profile_request_model.dart';
import '../../data/model/profile_response_model.dart';

/// Use case для обновления профиля пользователя
class UpdateProfileUseCase {
  UpdateProfileUseCase({required this.profileRepository});

  final ProfileRepository profileRepository;

  /// Выполнение обновления профиля
  Future<Result<ProfileResponseModel>> call(
    UpdateProfileRequestModel request,
  ) async {
    try {
      print('🎯 UpdateProfileUseCase: Начинаем обновление профиля');

      // Валидация данных
      if (request.name?.trim().isEmpty == true) {
        return Result.failure(ValidationFailure('Имя не может быть пустым'));
      }

      if (request.phone?.trim().isEmpty == true) {
        return Result.failure(
          ValidationFailure('Телефон не может быть пустым'),
        );
      }

      // Проверяем формат телефона (базовая валидация)
      if (request.phone != null &&
          !RegExp(
            r'^\+?[1-9]\d{1,14}$',
          ).hasMatch(request.phone!.replaceAll(' ', ''))) {
        return Result.failure(ValidationFailure('Неверный формат телефона'));
      }

      final result = await profileRepository.updateProfile(request);

      if (result is Success<ProfileResponseModel>) {
        print('✅ UpdateProfileUseCase: Профиль успешно обновлен');
        return result;
      } else if (result is FailureResult<ProfileResponseModel>) {
        print(
          '❌ UpdateProfileUseCase: Ошибка обновления профиля: ${result.failure}',
        );
        return result;
      }

      return Result.failure(ServerFailure('Неизвестная ошибка'));
    } catch (e) {
      print('❌ UpdateProfileUseCase: Исключение при обновлении профиля: $e');
      return Result.failure(ServerFailure('Ошибка обновления профиля: $e'));
    }
  }
}
