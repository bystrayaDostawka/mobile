import 'package:image_picker/image_picker.dart';

/// Результат валидации изображения
class ImageValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ImageValidationResult({required this.isValid, this.errorMessage});

  const ImageValidationResult.success() : isValid = true, errorMessage = null;

  const ImageValidationResult.error(this.errorMessage) : isValid = false;
}

/// Валидатор изображений
class ImageValidator {
  /// Максимальный размер файла (5MB)
  static const int maxFileSize = 5 * 1024 * 1024;

  /// Поддерживаемые форматы файлов
  static const List<String> allowedFormats = ['.jpg', '.jpeg', '.png'];

  /// Максимальное количество фотографий
  static const int maxPhotos = 16;

  /// Валидировать изображение
  static ImageValidationResult validate(XFile image) {
    // Проверка размера файла будет выполнена асинхронно
    return const ImageValidationResult.success();
  }

  /// Валидировать размер файла
  static ImageValidationResult validateFileSize(int fileSize) {
    if (fileSize > maxFileSize) {
      return ImageValidationResult.error(
        'Файл слишком большой. Максимальный размер: ${_formatFileSize(maxFileSize)}',
      );
    }
    return const ImageValidationResult.success();
  }

  /// Валидировать формат файла
  static ImageValidationResult validateFileFormat(String fileName) {
    final lowerFileName = fileName.toLowerCase();

    for (final format in allowedFormats) {
      if (lowerFileName.endsWith(format)) {
        return const ImageValidationResult.success();
      }
    }

    return ImageValidationResult.error(
      'Неподдерживаемый формат файла. Используйте: ${allowedFormats.join(', ')}',
    );
  }

  /// Валидировать количество фотографий
  static ImageValidationResult validatePhotoCount(int currentCount) {
    if (currentCount >= maxPhotos) {
      return ImageValidationResult.error(
        'Достигнут лимит фотографий: $maxPhotos',
      );
    }
    return const ImageValidationResult.success();
  }

  /// Полная валидация изображения
  static Future<ImageValidationResult> validateImage(XFile image) async {
    try {
      // Проверяем формат файла
      final formatResult = validateFileFormat(image.name);
      if (!formatResult.isValid) {
        return formatResult;
      }

      // Проверяем размер файла
      final fileSize = await image.length();
      final sizeResult = validateFileSize(fileSize);
      if (!sizeResult.isValid) {
        return sizeResult;
      }

      return const ImageValidationResult.success();
    } catch (e) {
      return ImageValidationResult.error('Ошибка валидации файла: $e');
    }
  }

  /// Форматировать размер файла для отображения
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
