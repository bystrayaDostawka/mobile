import '../../../../core/network/api_client.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/model/profile_response_model.dart';
import '../../data/model/update_profile_request_model.dart';

/// Реализация репозитория профиля
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<Result<ProfileResponseModel>> getProfile() async {
    try {
      print('🌐 ProfileRepository: Получаем профиль пользователя');
      final profileData = await apiClient.getUserProfile();
      return Result.success(profileData);
    } catch (e) {
      print('❌ ProfileRepository: Ошибка получения профиля: $e');
      return Result.failure(ServerFailure('Ошибка получения профиля: $e'));
    }
  }

  @override
  Future<Result<ProfileResponseModel>> updateProfile(
    UpdateProfileRequestModel request,
  ) async {
    try {
      print('🌐 ProfileRepository: Обновляем профиль пользователя');
      final updatedProfile = await apiClient.updateUserProfile(request);
      return Result.success(updatedProfile);
    } catch (e) {
      print('❌ ProfileRepository: Ошибка обновления профиля: $e');
      return Result.failure(ServerFailure('Ошибка обновления профиля: $e'));
    }
  }
}
