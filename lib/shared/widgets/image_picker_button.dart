import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';

/// Кнопка для выбора изображения
class ImagePickerButton extends StatelessWidget {
  const ImagePickerButton({
    super.key,
    required this.onImagePicked,
    required this.isLoading,
    this.isEnabled = true,
    this.icon = Icons.camera_alt,
    this.label = 'Сделать фото',
    this.loadingLabel = 'Загрузка...',
    this.disabledLabel,
  });

  final Future<void> Function(ImageSource source) onImagePicked;
  final bool isLoading;
  final bool isEnabled;
  final IconData icon;
  final String label;
  final String loadingLabel;
  final String? disabledLabel;

  @override
  Widget build(BuildContext context) {
    final isDisabled = !isEnabled || isLoading;
    final buttonLabel = isLoading
        ? loadingLabel
        : !isEnabled && disabledLabel != null
        ? disabledLabel!
        : label;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isDisabled ? null : () => onImagePicked(ImageSource.camera),
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.background,
                ),
              )
            : Icon(icon, size: 20),
        label: Text(buttonLabel),
      ),
    );
  }
}
