import 'package:flutter/material.dart';

/// Цветовая палитра приложения (на основе сайта)
class AppColors {
  // Основные акцентные цвета
  static const Color primary = Color(0xFFFFDE73); // жёлтая кнопка
  static const Color primaryDark = Color(0xFFF3C742);
  static const Color primaryLight = Color(0xFFFFE799);

  // Фоновые цвета
  static const Color background = Color(0xFF252422); // почти чёрный фон
  static const Color surface = Color(0xFF31302D); // тёмный серый блок
  static const Color surfaceVariant = Color(0xFF2A2A2A);

  // Текстовые цвета
  static const Color textPrimary = Color(0xFFD9D7CD); // белый
  static const Color textSecondary = Color(0xFFFBF9ED); // серый текст
  static const Color textHint = Color(0xFF7A7A7A);
  static const Color textDisabled = Color(0xFF4D4D4D);

  // Нейтральные цвета
  static const Color white = Color(0xFFD9D7CD); // Заменяем белый на цвет текста
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF808080);
  static const Color greyLight = Color(0xFFCCCCCC);
  static const Color greyDark = Color(0xFF333333);

  // Статусные цвета
  static const Color success = Color(0xFF4CAF50); // зелёный
  static const Color warning = Color(0xFFFFC107); // жёлтый
  static const Color error = Color(0xFFF44336); // красный
  static const Color info = Color(0xFF2196F3); // синий

  // Границы и разделители
  static const Color border = Color(0xFF2E2E2E);
  static const Color divider = Color(0xFF2E2E2E);

  // Тени
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);

  // Цвета для заказов (пример)
  static const Color orderPending = Color(0xFFFFC107);
  static const Color orderConfirmed = Color(0xFF2196F3);
  static const Color orderInProgress = Color(
    0xFF9C27B0,
  ); // фиолетовый — в работе/проверка
  static const Color orderCompleted = Color(0xFF4CAF50);
  static const Color orderCancelled = Color(0xFFF44336);
  static const Color orderDeferred = Color(
    0xFF03A9F4,
  ); // голубой — перенос/отложено
  static const Color orderAll = Color(0xFF9E9E9E);
}
