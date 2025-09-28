import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Сервис для работы с цветами статусов
class StatusColorService {
  static final StatusColorService _instance = StatusColorService._internal();
  factory StatusColorService() => _instance;
  StatusColorService._internal();

  /// Парсинг цвета из строки
  Color parseColor(String colorString) {
    try {
      String cleanColor = colorString.replaceAll('#', '');

      if (cleanColor.length == 6) {
        return Color(int.parse('FF$cleanColor', radix: 16));
      }

      if (cleanColor.length == 8) {
        return Color(int.parse(cleanColor, radix: 16));
      }

      return AppColors.primary;
    } catch (e) {
      return AppColors.primary;
    }
  }

  /// Получить цвет с прозрачностью
  Color getColorWithOpacity(String colorString, double opacity) {
    return parseColor(colorString).withValues(alpha: opacity);
  }
}
