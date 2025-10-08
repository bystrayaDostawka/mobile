import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Сервис для работы с WhatsApp
class WhatsAppService {
  /// Открыть чат с контактом в WhatsApp
  /// Возвращает true, если WhatsApp был открыт, false если номер был скопирован
  static Future<bool> openChat(String phoneNumber) async {
    try {
      // Очищаем номер от лишних символов (оставляем только цифры и +)
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Создаем URL для WhatsApp
      final whatsappUrl = Uri.parse('whatsapp://send?phone=$cleanPhone');

      // Проверяем, можно ли открыть URL
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        return true;
      } else {
        // Fallback - пробуем открыть веб-версию WhatsApp
        return await _openWebWhatsApp(cleanPhone, phoneNumber);
      }
    } catch (e) {
      // Если не удалось открыть приложение, пробуем веб-версию
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      return await _openWebWhatsApp(cleanPhone, phoneNumber);
    }
  }

  /// Открыть чат через веб-версию WhatsApp
  static Future<bool> _openWebWhatsApp(
    String cleanPhone,
    String originalPhone,
  ) async {
    try {
      final whatsappWebUrl = Uri.parse('https://wa.me/$cleanPhone');

      if (await canLaunchUrl(whatsappWebUrl)) {
        await launchUrl(whatsappWebUrl, mode: LaunchMode.externalApplication);
        return true;
      } else {
        // Fallback - копируем номер в буфер обмена
        await _copyToClipboard(originalPhone);
        return false;
      }
    } catch (e) {
      // В случае любой ошибки копируем номер в буфер обмена
      try {
        await _copyToClipboard(originalPhone);
        return false;
      } catch (clipboardError) {
        throw Exception(
          'Не удалось открыть WhatsApp и скопировать номер: $clipboardError',
        );
      }
    }
  }

  /// Копирует номер телефона в буфер обмена
  static Future<void> _copyToClipboard(String phoneNumber) async {
    await Clipboard.setData(ClipboardData(text: phoneNumber));
  }

  /// Проверяет, установлен ли WhatsApp
  static Future<bool> isWhatsAppInstalled() async {
    try {
      final whatsappUrl = Uri.parse('whatsapp://send');
      return await canLaunchUrl(whatsappUrl);
    } catch (e) {
      return false;
    }
  }

  /// Нормализует номер телефона для WhatsApp
  static String normalizePhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
  }
}
