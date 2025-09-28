import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/map_service.dart';
import '../../core/theme/app_colors.dart';

/// Переиспользуемый виджет с кнопками действий для заказа
class ActionButtonsRow extends StatelessWidget {
  const ActionButtonsRow({
    super.key,
    required this.phoneNumber,
    required this.address,
    this.onPhoneCall,
    this.onMapOpen,
  });

  final String phoneNumber;
  final String address;
  final VoidCallback? onPhoneCall;
  final VoidCallback? onMapOpen;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPhoneCall ?? () => _makePhoneCall(phoneNumber),
            icon: const Icon(Icons.phone, size: 16),
            label: const Text('Позвонить'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onMapOpen ?? () => _openAddressInMap(address),
            icon: const Icon(Icons.map, size: 16),
            label: const Text('На карте'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  /// Совершить звонок
  static Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      // Очищаем номер от лишних символов
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Создаем URL для звонка
      final phoneUrl = Uri.parse('tel:$cleanPhone');

      // Проверяем, можно ли открыть URL
      if (await canLaunchUrl(phoneUrl)) {
        await launchUrl(phoneUrl);
      }
    } catch (e) {
      // Ошибка обрабатывается в UI
    }
  }

  /// Открыть адрес в картографическом приложении
  static Future<void> _openAddressInMap(String address) async {
    try {
      await MapService.openAddress(address);
    } catch (e) {
      // Ошибка обрабатывается в UI
    }
  }
}




