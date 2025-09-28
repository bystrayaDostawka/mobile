import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

/// Сервис для работы с изображениями
class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final ImagePicker _picker = ImagePicker();
  final Dio _dio = Dio();

  /// Выбрать изображение из камеры или галереи
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    try {
      return await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        preferredCameraDevice: preferredCameraDevice,
      );
    } catch (e) {
      throw ImageServiceException('Ошибка при выборе изображения: $e');
    }
  }

  /// Загрузить изображение по URL
  Future<Uint8List> loadNetworkImage(String url) async {
    try {
      final response = await _dio.get<Uint8List>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data == null) {
        throw ImageServiceException('Не удалось загрузить изображение');
      }

      return response.data!;
    } catch (e) {
      throw ImageServiceException('Ошибка загрузки изображения: $e');
    }
  }

  /// Получить размер файла изображения
  Future<int> getFileSize(XFile image) async {
    try {
      return await image.length();
    } catch (e) {
      throw ImageServiceException('Ошибка получения размера файла: $e');
    }
  }

  /// Получить имя файла
  String getFileName(XFile image) {
    return image.name.toLowerCase();
  }
}

/// Исключение сервиса изображений
class ImageServiceException implements Exception {
  final String message;

  const ImageServiceException(this.message);

  @override
  String toString() => 'ImageServiceException: $message';
}
