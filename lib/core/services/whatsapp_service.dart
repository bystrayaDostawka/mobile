import 'package:url_launcher/url_launcher.dart';

/// Сервис для работы с WhatsApp
class WhatsAppService {
  /// Открыть чат с контактом в WhatsApp
  /// Возвращает true, если WhatsApp был открыт, false если не удалось открыть
  static Future<bool> openChat(String phoneNumber) async {
    try {
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final whatsappUrl = Uri.parse('whatsapp://send?phone=$cleanPhone');

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        return true;
      } else {
        return await _openWebWhatsApp(cleanPhone);
      }
    } catch (e) {
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
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
}
