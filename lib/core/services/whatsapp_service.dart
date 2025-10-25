import 'package:url_launcher/url_launcher.dart';

/// Сервис для работы с WhatsApp
class WhatsAppService {
  /// Открыть чат с контактом в WhatsApp
  /// Возвращает true, если WhatsApp был открыт, false если не удалось открыть
  static Future<bool> openChat(String phoneNumber) async {
    try {
      final cleanPhone = _normalizePhoneForWhatsApp(phoneNumber);
      final whatsappUrl = Uri.parse('whatsapp://send?phone=$cleanPhone');

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        return true;
      } else {
        return await _openWebWhatsApp(cleanPhone);
      }
    } catch (e) {
      final cleanPhone = _normalizePhoneForWhatsApp(phoneNumber);
      return await _openWebWhatsApp(cleanPhone);
    }
  }

  /// Открыть чат через веб-версию WhatsApp
  static Future<bool> _openWebWhatsApp(String cleanPhone) async {
    final whatsappWebUrl = Uri.parse('https://wa.me/$cleanPhone');

    try {
      await launchUrl(whatsappWebUrl, mode: LaunchMode.externalApplication);
      return true;
    } catch (e1) {
      // Игнорируем
    }

    try {
      await launchUrl(whatsappWebUrl, mode: LaunchMode.platformDefault);
      return true;
    } catch (e2) {
      // Игнорируем
    }

    try {
      if (await canLaunchUrl(whatsappWebUrl)) {
        await launchUrl(whatsappWebUrl);
        return true;
      }
    } catch (e3) {
      // Игнорируем
    }

    return false;
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

  /// Нормализует номер телефона для WhatsApp
  /// Добавляет код страны если отсутствует
  static String _normalizePhoneForWhatsApp(String phoneNumber) {
    // Удаляем все символы кроме цифр и +
    var cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Если номер начинается с +, оставляем как есть
    if (cleanPhone.startsWith('+')) {
      return cleanPhone;
    }
    
    // Если номер начинается с 8, заменяем на +7 (Россия/Казахстан)
    if (cleanPhone.startsWith('8')) {
      cleanPhone = '+7${cleanPhone.substring(1)}';
      return cleanPhone;
    }
    
    // Если номер начинается с 7, добавляем +
    if (cleanPhone.startsWith('7')) {
      return '+$cleanPhone';
    }
    
    // По умолчанию добавляем +7 (российский номер)
    return '+7$cleanPhone';
  }
}
