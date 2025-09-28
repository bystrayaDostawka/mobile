import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

/// Тема приложения
class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',

      // AppBar
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
      ),

      // Card
      cardTheme: CardThemeData(
        elevation: 2,

        color: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: EdgeInsets.zero,
      ),

      // Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        hintStyle: AppTextStyles.h5.copyWith(color: AppColors.textHint),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.background,
        elevation: 8,
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 4,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.textSecondary,
        selectedColor: AppColors.primary,
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.surface,
        ),
        checkmarkColor: AppColors.surface,
        showCheckmark: true,
        selectedShadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadius),
      ),
    );
  }

  static BoxDecoration get boxDecoration {
    return BoxDecoration(
      color: AppColors.background,
      borderRadius: borderRadius,
      boxShadow: [boxShadow],
    );
  }

  static EdgeInsets get edgeInsets {
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  }

  static BorderRadius get borderRadius {
    return BorderRadius.circular(12);
  }

  static BoxShadow get boxShadow {
    return BoxShadow(
      color: AppColors.shadow,
      blurRadius: 10,
      offset: const Offset(0, 10),
    );
  }

  static const double spacing16 = 16;
  static const double spacing12 = 12;
  static const double spacing8 = 8;
  static const double spacing4 = 4;
}
