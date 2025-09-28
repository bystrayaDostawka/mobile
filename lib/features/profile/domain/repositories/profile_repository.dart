import '../../../../core/usecase/usecase.dart';
import '../../data/model/profile_response_model.dart';
import '../../data/model/update_profile_request_model.dart';

/// Доменный интерфейс репозитория профиля
abstract class ProfileRepository {
  /// Получение профиля пользователя
  Future<Result<ProfileResponseModel>> getProfile();

  /// Обновление профиля пользователя
  Future<Result<ProfileResponseModel>> updateProfile(
    UpdateProfileRequestModel request,
  );
}
