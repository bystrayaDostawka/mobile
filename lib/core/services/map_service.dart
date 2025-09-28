import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

/// Сервис для работы с картографическими приложениями
class MapService {
  /// Открывает маршрут к адресу в картографическом приложении
  /// Приоритет: Яндекс.Карты > 2ГИС > Google Maps
  static Future<void> openAddress(String address) async {
    try {
      // Получаем список доступных карт
      final availableMaps = await MapLauncher.installedMaps;

      // Ищем Яндекс.Карты
      final yandexMap = availableMaps.firstWhere(
        (map) => map.mapType == MapType.yandexMaps,
        orElse: () => throw StateError('Yandex Maps not found'),
      );

      // Открываем маршрут в Яндекс.Картах
      await MapLauncher.showDirections(
        mapType: yandexMap.mapType,
        destination: Coords(0, 0), // Координаты будут найдены по адресу
        destinationTitle: address,
        directionsMode: DirectionsMode.driving,
      );
      return;
    } catch (e) {
      // Яндекс.Карты недоступны, пробуем 2ГИС
    }

    try {
      // Получаем список доступных карт
      final availableMaps = await MapLauncher.installedMaps;

      // Ищем 2ГИС
      final twoGisMap = availableMaps.firstWhere(
        (map) => map.mapType == MapType.doubleGis,
        orElse: () => throw StateError('2GIS not found'),
      );

      // Открываем маршрут в 2ГИС
      await MapLauncher.showDirections(
        mapType: twoGisMap.mapType,
        destination: Coords(0, 0),
        destinationTitle: address,
        directionsMode: DirectionsMode.driving,
      );
      return;
    } catch (e) {
      // 2ГИС недоступен, пробуем Google Maps
    }

    try {
      // Получаем список доступных карт
      final availableMaps = await MapLauncher.installedMaps;

      // Ищем Google Maps
      final googleMap = availableMaps.firstWhere(
        (map) => map.mapType == MapType.google,
        orElse: () => throw StateError('Google Maps not found'),
      );

      // Открываем маршрут в Google Maps
      await MapLauncher.showDirections(
        mapType: googleMap.mapType,
        destination: Coords(0, 0),
        destinationTitle: address,
        directionsMode: DirectionsMode.driving,
      );
      return;
    } catch (e) {
      // Google Maps недоступен, используем fallback
    }

    // Fallback - используем URL-схемы
    await _openWithUrlSchemes(address);
  }

  /// Fallback метод для открытия через URL-схемы
  static Future<void> _openWithUrlSchemes(String address) async {
    final encodedAddress = Uri.encodeComponent(address);

    try {
      // Пробуем открыть маршрут в Яндекс.Картах через URL-схему
      final yandexUrl =
          'yandexmaps://build_route_on_map?lat_to=0&lon_to=0&text_to=$encodedAddress';
      if (await canLaunchUrl(Uri.parse(yandexUrl))) {
        await launchUrl(
          Uri.parse(yandexUrl),
          mode: LaunchMode.externalApplication,
        );
        return;
      }
    } catch (e) {
      // Игнорируем ошибку
    }

    try {
      // Пробуем открыть маршрут в 2ГИС через URL-схему
      final twoGisUrl = '2gis://route/to/$encodedAddress';
      if (await canLaunchUrl(Uri.parse(twoGisUrl))) {
        await launchUrl(
          Uri.parse(twoGisUrl),
          mode: LaunchMode.externalApplication,
        );
        return;
      }
    } catch (e) {
      // Игнорируем ошибку
    }

    try {
      // Пробуем открыть в Google Maps через браузер
      final googleUrl =
          'https://maps.google.com/maps/dir/?api=1&destination=$encodedAddress';
      if (await canLaunchUrl(Uri.parse(googleUrl))) {
        await launchUrl(
          Uri.parse(googleUrl),
          mode: LaunchMode.externalApplication,
        );
        return;
      }
    } catch (e) {
      // Игнорируем ошибку
    }

    throw Exception('Не удалось открыть ни одно картографическое приложение');
  }

  /// Проверяет, установлены ли Яндекс.Карты
  static Future<bool> isYandexMapsInstalled() async {
    try {
      final availableMaps = await MapLauncher.installedMaps;
      return availableMaps.any((map) => map.mapType == MapType.yandexMaps);
    } catch (e) {
      return false;
    }
  }

  /// Проверяет, установлен ли 2ГИС
  static Future<bool> isTwoGisInstalled() async {
    try {
      final availableMaps = await MapLauncher.installedMaps;
      return availableMaps.any((map) => map.mapType == MapType.doubleGis);
    } catch (e) {
      return false;
    }
  }

  /// Получает список доступных картографических приложений
  static Future<List<String>> getAvailableMaps() async {
    try {
      final availableMaps = await MapLauncher.installedMaps;
      return availableMaps.map((map) => map.mapName).toList();
    } catch (e) {
      return ['Системные карты'];
    }
  }
}
