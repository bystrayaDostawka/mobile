import 'package:connectivity_plus/connectivity_plus.dart';

/// Сервис для проверки подключения к интернету
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  /// Проверяет, есть ли подключение к интернету
  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();

      // Если нет подключения к сети вообще
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Если есть подключение к сети, но нужно проверить доступность интернета
      // Для мобильных сетей и WiFi это обычно означает наличие интернета
      return connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi ||
          connectivityResult == ConnectivityResult.ethernet;
    } catch (e) {
      return false;
    }
  }

  /// Получает текущий тип подключения
  Future<ConnectivityResult> getConnectionType() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      return ConnectivityResult.none;
    }
  }

  /// Стрим изменений подключения
  Stream<ConnectivityResult> get connectivityStream =>
      _connectivity.onConnectivityChanged;
}
