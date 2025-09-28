import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Утилиты для работы со статусами заказов
class OrderStatusUtils {
  /// Получить цвет статуса заказа
  static Color getStatusColor(int statusId) {
    switch (statusId) {
      case 1:
        return AppColors.primary;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.green;
      case 5:
        return Colors.purple;
      case 6:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Получить название статуса на русском
  static String getStatusDisplayName(int statusId) {
    switch (statusId) {
      case 1:
        return 'Новые';
      case 2:
        return 'Принято в работу';
      case 3:
        return 'Ждёт проверку';
      case 4:
        return 'Завершено';
      case 5:
        return 'Перенос';
      case 6:
        return 'Отменено';
      default:
        return 'Неизвестно';
    }
  }

  /// Получить иконку статуса
  static IconData getStatusIcon(int statusId) {
    switch (statusId) {
      case 1:
        return Icons.new_releases;
      case 2:
        return Icons.work;
      case 3:
        return Icons.hourglass_empty;
      case 4:
        return Icons.check_circle;
      case 5:
        return Icons.schedule;
      case 6:
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}
