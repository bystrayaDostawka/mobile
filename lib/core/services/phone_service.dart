import 'package:url_launcher/url_launcher.dart';

/// Сервис для работы с телефонными звонками
class PhoneService {
  /// Совершить звонок на указанный номер
  static Future<void> makeCall(String phoneNumber) async {
    try {
      // Очищаем номер от лишних символов
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Создаем URL для звонка
      final phoneUrl = Uri.parse('tel:$cleanPhone');

      // Проверяем, можно ли открыть URL
      if (await canLaunchUrl(phoneUrl)) {
        await launchUrl(phoneUrl);
      } else {
        throw Exception('Не удалось совершить звонок на номер: $phoneNumber');
      }
    } catch (e) {
      throw Exception('Ошибка при совершении звонка: $e');
    }
  }

  /// Проверяет, можно ли совершить звонок
  static Future<bool> canMakeCall() async {
    try {
      final phoneUrl = Uri.parse('tel:123456789');
      return await canLaunchUrl(phoneUrl);
    } catch (e) {
      return false;
    }
  }

  /// Нормализует номер телефона
  static String normalizePhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
  }
}
