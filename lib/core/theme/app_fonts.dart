import 'package:flutter/material.dart';

/// Типографика приложения
class AppFonts {
  // Размеры шрифтов
  static const double fontSize10 = 10.0;
  static const double fontSize12 = 12.0;
  static const double fontSize14 = 14.0;
  static const double fontSize16 = 16.0;
  static const double fontSize18 = 18.0;
  static const double fontSize20 = 20.0;
  static const double fontSize24 = 24.0;
  static const double fontSize28 = 28.0;
  static const double fontSize32 = 32.0;
  static const double fontSize36 = 36.0;
  static const double fontSize48 = 48.0;

  // Веса шрифтов
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  static const FontWeight fontWeightExtraBold = FontWeight.w800;

  // Высота строк
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.6;
  static const double lineHeightLoose = 1.8;

  // Межбуквенные интервалы
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;
  static const double letterSpacingWider = 1.0;
}

/// Стили текста приложения
class AppTextStyles {
  // Заголовки
  static const TextStyle h1 = TextStyle(
    fontSize: AppFonts.fontSize32,
    fontWeight: AppFonts.fontWeightBold,
    height: AppFonts.lineHeightTight,
    letterSpacing: AppFonts.letterSpacingTight,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: AppFonts.fontSize28,
    fontWeight: AppFonts.fontWeightBold,
    height: AppFonts.lineHeightTight,
    letterSpacing: AppFonts.letterSpacingTight,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: AppFonts.fontSize24,
    fontWeight: AppFonts.fontWeightSemiBold,
    height: AppFonts.lineHeightNormal,
    letterSpacing: AppFonts.letterSpacingNormal,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: AppFonts.fontSize20,
    fontWeight: AppFonts.fontWeightSemiBold,
    height: AppFonts.lineHeightNormal,
    letterSpacing: AppFonts.letterSpacingNormal,
  );

  static const TextStyle h5 = TextStyle(
    fontSize: AppFonts.fontSize18,
    fontWeight: AppFonts.fontWeightMedium,
    height: AppFonts.lineHeightNormal,
    letterSpacing: AppFonts.letterSpacingNormal,
  );

  static const TextStyle h6 = TextStyle(
    fontSize: AppFonts.fontSize16,
    fontWeight: AppFonts.fontWeightMedium,
    height: AppFonts.lineHeightNormal,
    letterSpacing: AppFonts.letterSpacingNormal,
  );

  // Основной текст
  static const TextStyle bodyLarge = TextStyle(
    fontSize: AppFonts.fontSize16,
    fontWeight: AppFonts.fontWeightRegular,
    height: AppFonts.lineHeightRelaxed,
    letterSpacing: AppFonts.letterSpacingNormal,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: AppFonts.fontSize14,
    fontWeight: AppFonts.fontWeightRegular,
    height: AppFonts.lineHeightRelaxed,
    letterSpacing: AppFonts.letterSpacingNormal,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: AppFonts.fontSize12,
    fontWeight: AppFonts.fontWeightRegular,
    height: AppFonts.lineHeightNormal,
    letterSpacing: AppFonts.letterSpacingNormal,
  );

  // Кнопки
  static const TextStyle buttonLarge = TextStyle(
    fontSize: AppFonts.fontSize16,
    fontWeight: AppFonts.fontWeightMedium,
    height: AppFonts.lineHeightTight,
    letterSpacing: AppFonts.letterSpacingWide,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: AppFonts.fontSize14,
    fontWeight: AppFonts.fontWeightMedium,
    height: AppFonts.lineHeightTight,
    letterSpacing: AppFonts.letterSpacingWide,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: AppFonts.fontSize12,
    fontWeight: AppFonts.fontWeightMedium,
    height: AppFonts.lineHeightTight,
    letterSpacing: AppFonts.letterSpacingWide,
  );

  // Подписи и метки
  static const TextStyle labelLarge = TextStyle(
    fontSize: AppFonts.fontSize14,
    fontWeight: AppFonts.fontWeightMedium,
    height: AppFonts.lineHeightNormal,
    letterSpacing: AppFonts.letterSpacingWide,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: AppFonts.fontSize12,
    fontWeight: AppFonts.fontWeightMedium,
    height: AppFonts.lineHeightNormal,
    letterSpacing: AppFonts.letterSpacingWide,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: AppFonts.fontSize10,
    fontWeight: AppFonts.fontWeightMedium,
    height: AppFonts.lineHeightNormal,
    letterSpacing: AppFonts.letterSpacingWide,
  );

  // Caption и overline
  static const TextStyle caption = TextStyle(
    fontSize: AppFonts.fontSize12,
    fontWeight: AppFonts.fontWeightRegular,
    height: AppFonts.lineHeightNormal,
    letterSpacing: AppFonts.letterSpacingWide,
  );

  static const TextStyle overline = TextStyle(
    fontSize: AppFonts.fontSize10,
    fontWeight: AppFonts.fontWeightMedium,
    height: AppFonts.lineHeightNormal,
    letterSpacing: AppFonts.letterSpacingWider,
  );

  // Специальные стили для заказов
  static const TextStyle orderStatus = TextStyle(
    fontSize: AppFonts.fontSize12,
    fontWeight: AppFonts.fontWeightSemiBold,
    height: AppFonts.lineHeightTight,
    letterSpacing: AppFonts.letterSpacingWide,
  );

  static const TextStyle orderNumber = TextStyle(
    fontSize: AppFonts.fontSize14,
    fontWeight: AppFonts.fontWeightBold,
    height: AppFonts.lineHeightTight,
    letterSpacing: AppFonts.letterSpacingTight,
  );

  static const TextStyle orderPrice = TextStyle(
    fontSize: AppFonts.fontSize16,
    fontWeight: AppFonts.fontWeightBold,
    height: AppFonts.lineHeightTight,
    letterSpacing: AppFonts.letterSpacingTight,
  );
}
