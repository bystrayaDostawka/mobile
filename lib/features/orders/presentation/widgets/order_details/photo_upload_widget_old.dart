import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';
// import 'package:cached_network_image/cached_network_image.dart'; // Временно отключено из-за проблем с sqflite

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_fonts.dart';
import '../../../domain/entities/order_entity.dart';
import '../../bloc/order_details_bloc.dart';

/// Виджет для загрузки фотографий заказа
class PhotoUploadWidget extends StatelessWidget {
  const PhotoUploadWidget({
    super.key,
    required this.orderDetails,
    required this.orderDetailsBloc,
  });

  final OrderDetailsEntity orderDetails;
  final OrderDetailsBloc orderDetailsBloc;

  /// Максимальное количество фотографий
  static const int maxPhotos = 16;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Фотографии заказа',
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${orderDetails.photos.length}/$maxPhotos',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: orderDetails.photos.length >= maxPhotos
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Кнопка загрузки фотографии
            BlocBuilder<OrderDetailsBloc, OrderDetailsState>(
              bloc: orderDetailsBloc,
              builder: (context, state) {
                final isUploading = state is OrderPhotoUploading;
                final isMaxPhotosReached =
                    orderDetails.photos.length >= maxPhotos;

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (isUploading || isMaxPhotosReached)
                        ? null
                        : () => _pickImage(context, ImageSource.camera),
                    icon: isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.background,
                            ),
                          )
                        : const Icon(Icons.camera_alt, size: 20),
                    label: Text(
                      isUploading
                          ? 'Загрузка...'
                          : isMaxPhotosReached
                          ? 'Лимит достигнут ($maxPhotos/$maxPhotos)'
                          : 'Сделать фото',
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Предупреждение о лимите
            if (orderDetails.photos.length >= maxPhotos * 0.75 &&
                orderDetails.photos.length < maxPhotos)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_outlined,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Осталось ${maxPhotos - orderDetails.photos.length} фото из $maxPhotos',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (orderDetails.photos.length >= maxPhotos * 0.75 &&
                orderDetails.photos.length < maxPhotos)
              const SizedBox(height: 12),

            // Список существующих фотографий
            if (orderDetails.photos.isNotEmpty) ...[
              Text(
                'Загруженные фотографии:',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: orderDetails.photos.length,
                  itemBuilder: (context, index) {
                    final photo = orderDetails.photos[index];
                    return Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: photo.url != null
                            ? Stack(
                                children: [
                                  _NetworkImageWidget(
                                    imageUrl: photo.url!,
                                    width: 120,
                                    height: 120,
                                  ),
                                  // Кнопка удаления
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _showDeleteConfirmation(
                                        context,
                                        photo,
                                      ),
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: AppColors.error.withValues(
                                            alpha: 0.8,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: AppColors.background,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                color: AppColors.surfaceVariant,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Фотографии не загружены',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Предупреждение о безопасности данных
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(2),
              child: Row(
                children: [
                  Icon(Icons.security, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Данные шифруются и не хранятся на устройстве',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Показать диалог подтверждения удаления фотографии
  void _showDeleteConfirmation(BuildContext context, PhotoEntity photo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Удалить фотографию'),
          content: const Text('Вы уверены, что хотите удалить эту фотографию?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deletePhoto(context, photo);
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
  }

  /// Удалить фотографию
  void _deletePhoto(BuildContext context, PhotoEntity photo) {
    orderDetailsBloc.add(
      DeleteOrderPhoto(orderId: orderDetails.id, photoId: photo.id),
    );
  }

  /// Выбрать изображение
  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      // Проверяем лимит фотографий
      if (orderDetails.photos.length >= maxPhotos) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Достигнут лимит фотографий: $maxPhotos'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        // Проверяем размер файла
        final fileSize = await image.length();
        print('📸 Выбрано изображение: ${image.path}');
        print('📏 Размер файла: $fileSize байт');

        // Проверяем, что файл не слишком большой (5MB максимум)
        if (fileSize > 5 * 1024 * 1024) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Файл слишком большой. Максимальный размер: 5MB'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }

        // Проверяем формат файла
        final fileName = image.name.toLowerCase();
        if (!fileName.endsWith('.jpg') &&
            !fileName.endsWith('.jpeg') &&
            !fileName.endsWith('.png')) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Неподдерживаемый формат файла. Используйте JPG или PNG',
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }

          return;
        }

        // Отправляем событие загрузки фотографии в BLoC
        orderDetailsBloc.add(
          UploadOrderPhoto(orderId: orderDetails.id, photoPath: image.path),
        );
      }
    } catch (e) {
      print('❌ Ошибка при выборе изображения: $e');
      // Можно показать SnackBar с ошибкой
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при выборе изображения: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

/// Виджет для загрузки изображений через Dio (альтернатива Image.network)
class _NetworkImageWidget extends StatefulWidget {
  const _NetworkImageWidget({
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  final String imageUrl;
  final double width;
  final double height;

  @override
  State<_NetworkImageWidget> createState() => _NetworkImageWidgetState();
}

class _NetworkImageWidgetState extends State<_NetworkImageWidget> {
  Uint8List? _imageData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      print('🖼️ Загружаем изображение через Dio: ${widget.imageUrl}');

      final dio = Dio();
      final response = await dio.get<Uint8List>(
        widget.imageUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Accept': 'image/*', 'User-Agent': 'Flutter App'},
        ),
      );

      if (mounted) {
        setState(() {
          _imageData = response.data;
          _isLoading = false;
        });
        print('✅ Изображение загружено через Dio');
      }
    } catch (e) {
      print('❌ Ошибка загрузки через Dio: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: AppColors.surfaceVariant,
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: AppColors.surfaceVariant,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image_not_supported,
              color: AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              'Ошибка загрузки',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_imageData != null) {
      return Image.memory(
        _imageData!,
        fit: BoxFit.cover,
        width: widget.width,
        height: widget.height,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Ошибка декодирования изображения: $error');
          return Container(
            width: widget.width,
            height: widget.height,
            color: AppColors.surfaceVariant,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.image_not_supported,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  'Ошибка декодирования',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return Container(
      width: widget.width,
      height: widget.height,
      color: AppColors.surfaceVariant,
      child: const Icon(
        Icons.image_not_supported,
        color: AppColors.textSecondary,
      ),
    );
  }
}
