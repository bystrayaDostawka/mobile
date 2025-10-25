import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../shared/constants/app_constants.dart';

/// Сервис для работы с OneSignal пуш-уведомлениями
class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  bool _initialized = false;
  String? _playerId;

  /// Инициализация OneSignal
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Настройка OneSignal
      OneSignal.initialize(AppConstants.oneSignalAppId);

      // Запрос разрешения на уведомления
      OneSignal.Notifications.requestPermission(true);

      // Обработчик получения уведомления когда приложение открыто
      OneSignal.Notifications.addClickListener((event) {
        _handleNotificationClicked(event);
      });

      // Обработчик получения уведомления в фоне
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        print('📬 Получено уведомление (foreground): ${event.notification}');
      });

      // Небольшая задержка для получения Player ID
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Получение Player ID (уникальный ID устройства)
      final subscription = OneSignal.User.pushSubscription;
      _playerId = subscription.id;
      print('✅ OneSignal инициализирован. Player ID: $_playerId');

      // Слушаем изменения Player ID
      OneSignal.User.pushSubscription.addObserver((subscriptionChangedState) {
        final newId = subscriptionChangedState.current.id;
        if (newId != null && newId != _playerId) {
          _playerId = newId;
          print('🔄 Player ID обновлен: $_playerId');
          
          // Отправляем обновленный Player ID на сервер
          sendPlayerIdToServer(_playerId!);
        }
      });

      _initialized = true;
    } catch (e) {
      print('❌ Ошибка инициализации OneSignal: $e');
    }
  }

  /// Обработка клика по уведомлению
  void _handleNotificationClicked(OSNotificationClickEvent event) {
    print('📬 Клик по уведомлению: ${event.notification}');
    
    // Здесь можно добавить логику перехода на конкретный экран
    // Например, открыть детали заявки по ID
    final additionalData = event.notification.additionalData;
    if (additionalData != null && additionalData.containsKey('order_id')) {
      final orderId = additionalData['order_id'];
      print('Переход к заявке: $orderId');
      // TODO: Навигация к деталям заявки
    }
  }

  /// Получить Player ID устройства
  String? get playerId => _playerId;

  /// Получить статус подписки
  bool get isSubscribed {
    final subscription = OneSignal.User.pushSubscription;
    return subscription.optedIn ?? false;
  }

  /// Отправить Player ID на сервер для связывания с пользователем
  Future<void> sendPlayerIdToServer(String playerId) async {
    try {
      // Получаем токен из secure storage
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: AppConstants.authTokenKey);
      
      if (token == null) {
        print('⚠️ Токен не найден, пропускаем отправку Player ID');
        return;
      }
      
      final dio = Dio();
      
      dio.options.baseUrl = AppConstants.baseUrl;
      dio.options.headers['Authorization'] = 'Bearer $token';
      
      print('📤 Отправка Player ID на сервер: $playerId');
      
      final response = await dio.post(
        '/api/mobile/push-token',
        data: {'player_id': playerId},
      );
      
      print('✅ Player ID успешно отправлен на сервер: ${response.data}');
    } catch (e) {
      print('❌ Ошибка отправки Player ID на сервер: $e');
    }
  }

  /// Установить теги для пользователя (для сегментации уведомлений)
  Future<void> setUserTags(Map<String, String> tags) async {
    try {
      await OneSignal.User.addTags(tags);
      print('Теги установлены: $tags');
    } catch (e) {
      print('❌ Ошибка установки тегов: $e');
    }
  }

  /// Установить тег роли пользователя
  Future<void> setUserRole(String role) async {
    await setUserTags({'user_role': role});
  }

  /// Логин пользователя (связывает устройство с пользователем)
  Future<void> login(String userId) async {
    try {
      await OneSignal.login(userId);
      print('Пользователь залогинен в OneSignal: $userId');
    } catch (e) {
      print('❌ Ошибка логина в OneSignal: $e');
    }
  }

  /// Выход пользователя
  Future<void> logout() async {
    try {
      await OneSignal.logout();
      print('Пользователь вышел из OneSignal');
    } catch (e) {
      print('❌ Ошибка выхода из OneSignal: $e');
    }
  }
}

// Глобальный экземпляр сервиса
final oneSignalService = OneSignalService();

