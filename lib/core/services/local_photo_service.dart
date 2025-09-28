import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../validators/image_validator.dart';
import '../../features/orders/domain/entities/local_photo_entity.dart';

/// Сервис для работы с локальными фотографиями
class LocalPhotoService {
  static final LocalPhotoService _instance = LocalPhotoService._internal();
  factory LocalPhotoService() => _instance;
  LocalPhotoService._internal();

  final ImagePicker _imagePicker = ImagePicker();

  /// Снять фотографию с камеры
  Future<LocalPhotoEntity?> takePhoto({
    int maxWidth = 1920,
    int maxHeight = 1080,
    int imageQuality = 85,
  }) async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image == null) return null;

      // Валидируем изображение
      final validation = await ImageValidator.validateImage(image);
      if (!validation.isValid) {
        throw Exception(validation.errorMessage);
      }

      // Создаем локальную фотографию
      return LocalPhotoEntity.fromFile(File(image.path));
    } catch (e) {
      throw Exception('Ошибка при съемке фотографии: $e');
    }
  }

  /// Выбрать фотографию из галереи
  Future<LocalPhotoEntity?> pickFromGallery({
    int maxWidth = 1920,
    int maxHeight = 1080,
    int imageQuality = 85,
  }) async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (image == null) return null;

      // Валидируем изображение
      final validation = await ImageValidator.validateImage(image);
      if (!validation.isValid) {
        throw Exception(validation.errorMessage);
      }

      // Создаем локальную фотографию
      return LocalPhotoEntity.fromFile(File(image.path));
    } catch (e) {
      throw Exception('Ошибка при выборе фотографии: $e');
    }
  }

  /// Удалить локальную фотографию
  Future<void> deletePhoto(LocalPhotoEntity photo) async {
    try {
      final file = photo.file;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Ошибка при удалении фотографии: $e');
    }
  }

  /// Очистить временные файлы
  Future<void> clearTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();

      for (final file in files) {
        if (file is File && file.path.contains('order_photo_')) {
          try {
            await file.delete();
          } catch (e) {
            // Игнорируем ошибки удаления отдельных файлов
          }
        }
      }
    } catch (e) {
      // Игнорируем ошибки очистки
    }
  }

  /// Получить размер файла в байтах
  Future<int> getFileSize(LocalPhotoEntity photo) async {
    try {
      final file = photo.file;
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Получить общий размер всех фотографий
  Future<int> getTotalSize(List<LocalPhotoEntity> photos) async {
    int totalSize = 0;
    for (final photo in photos) {
      totalSize += await getFileSize(photo);
    }
    return totalSize;
  }

  /// Проверить, не превышен ли лимит фотографий
  bool canAddMorePhotos(List<LocalPhotoEntity> currentPhotos) {
    return currentPhotos.length < ImageValidator.maxPhotos;
  }

  /// Получить количество оставшихся слотов
  int getRemainingSlots(List<LocalPhotoEntity> currentPhotos) {
    return ImageValidator.maxPhotos - currentPhotos.length;
  }
}
