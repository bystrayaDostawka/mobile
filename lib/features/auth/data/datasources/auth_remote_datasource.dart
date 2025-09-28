import '../../../../core/network/api_client.dart';
import '../models/auth_login_response_model.dart' as auth_models;
import '../../../profile/data/model/profile_response_model.dart'
    as profile_models;

/// Абстрактный интерфейс для работы с удаленными данными авторизации
abstract class AuthRemoteDataSource {
  /// Авторизация пользователя
  Future<auth_models.AuthLoginResponseModel> login(
    String email,
    String password,
  );

  /// Выход из системы
  Future<Map<String, dynamic>> logout();

  /// Получение профиля пользователя
  Future<profile_models.ProfileResponseModel> getUserProfile();
}

/// Реализация удаленного источника данных авторизации
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<auth_models.AuthLoginResponseModel> login(
    String email,
    String password,
  ) async {
    final request = LoginRequest(email: email, password: password);
    return apiClient.login(request);
  }

  @override
  Future<Map<String, dynamic>> logout() async {
    return apiClient.logout();
  }

  @override
  Future<profile_models.ProfileResponseModel> getUserProfile() async {
    try {
      return await apiClient.getUserProfile();
    } catch (e) {
      rethrow;
    }
  }
}
