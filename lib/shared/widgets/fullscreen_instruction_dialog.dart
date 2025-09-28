import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';

/// Полноэкранный диалог с инструкцией
class FullscreenInstructionDialog extends StatelessWidget {
  const FullscreenInstructionDialog({
    super.key,
    required this.title,
    required this.imageAsset,
  });

  final String title;
  final String imageAsset;

  /// Показать полноэкранный диалог с инструкцией
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String imageAsset,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          FullscreenInstructionDialog(title: title, imageAsset: imageAsset),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Инструкция"),
        automaticallyImplyLeading: false,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close,
              color: AppColors.textSecondary,
              size: 24,
            ),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceVariant,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Expanded(child: _buildImage())],
        ),
      ),
    );
  }

  /// Изображение инструкции
  Widget _buildImage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Image.asset(
        imageAsset,
        fit: BoxFit.fitWidth,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColors.surfaceVariant,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Ошибка загрузки изображения',
                  style: AppTextStyles.h6.copyWith(color: AppColors.error),
                ),
                const SizedBox(height: 8),
                Text(
                  'Файл инструкции не найден',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
