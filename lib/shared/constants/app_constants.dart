/// Роли пользователей в системе
enum UserRole {
  courier('courier', 'Курьер');

  const UserRole(this.value, this.displayName);

  final String value;
  final String displayName;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.courier,
    );
  }
}

/// Статусы заявок
enum OrderStatus {
  assigned('assigned', 'Назначена'),
  inProgress('in_progress', 'В работе'),
  sent('sent', 'Отправлена'),
  accepted('accepted', 'Принята'),
  rejected('rejected', 'Отклонена');

  const OrderStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.assigned,
    );
  }
}

/// Константы приложения
class AppConstants {
  static const String appName = 'Быстрая доставка';
  static const String appVersion = '1.1.0';

  // API
  static const String baseUrl = 'https://admin.bystrayadostavka.ru';
  // static const String baseUrl = 'http://192.168.0.103';
  static const String apiVersion = '/api/v1';

  // OneSignal
  static const String oneSignalAppId = 'b4334469-2b6b-475f-aaa7-ccdf5a2a4a14';

  // Storage keys
  static const String authTokenKey = 'auth_token';
  static const String userRoleKey = 'user_role';
  static const String privateKeyKey = 'private_key';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;

  // File sizes
  static const int maxImageSize = 5 * 1024 * 1024;
}

/// Пути для роутинга
class AppRoutes {
  // Splash
  static const String splash = '/splash';

  // Auth
  static const String login = '/login';
  static const String importKey = '/import-key';

  // Main tabs
  static const String orders = '/orders';
  static const String comments = '/comments';
  static const String notifications = '/notifications';
  static const String profile = '/profile';

  // Order details
  static const String orderDetails = '/order/:id';
  static const String orderComments = '/order/:id/comments';

  // Deep links
  static const String deepLinkOrder = '/order';
}

/// Сообщения об ошибках
class ErrorMessages {
  static const String networkError = 'Нет подключения к интернету';
  static const String serverError = 'Ошибка сервера';
  static const String authError = 'Ошибка авторизации';
  static const String validationError = 'Ошибка валидации';
  static const String unknownError = 'Неизвестная ошибка';
  static const String cameraPermissionDenied = 'Нет разрешения на камеру';
}
