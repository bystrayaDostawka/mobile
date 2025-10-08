import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Сервис для работы с телефонными звонками
class PhoneService {
  /// Совершить звонок на указанный номер
  /// Возвращает true, если звонок был инициирован, false если номер был скопирован
  static Future<bool> makeCall(String phoneNumber) async {
    try {
      // Очищаем номер от лишних символов
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Создаем URL для звонка
      final phoneUrl = Uri.parse('tel:$cleanPhone');

      // Проверяем, можно ли открыть URL
      if (await canLaunchUrl(phoneUrl)) {
        await launchUrl(phoneUrl);
        return true;
      } else {
        // Fallback - копируем номер в буфер обмена
        await _copyToClipboard(phoneNumber);
        return false;
      }
    } catch (e) {
      // В случае любой ошибки копируем номер в буфер обмена
      try {
        await _copyToClipboard(phoneNumber);
        return false;
      } catch (clipboardError) {
        throw Exception(
          'Не удалось совершить звонок и скопировать номер: $clipboardError',
        );
      }
    }
  }

  /// Копирует номер телефона в буфер обмена
  static Future<void> _copyToClipboard(String phoneNumber) async {
    await Clipboard.setData(ClipboardData(text: phoneNumber));
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
