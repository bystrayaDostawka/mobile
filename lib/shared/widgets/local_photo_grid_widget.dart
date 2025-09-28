import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../features/orders/domain/entities/local_photo_entity.dart';

/// Виджет для отображения сетки локальных фотографий
class LocalPhotoGridWidget extends StatelessWidget {
  const LocalPhotoGridWidget({
    super.key,
    required this.photos,
    required this.onDeletePhoto,
    this.onPhotoTap,
    this.maxPhotos = 16,
  });

  final List<LocalPhotoEntity> photos;
  final Function(LocalPhotoEntity) onDeletePhoto;
  final Function(LocalPhotoEntity)? onPhotoTap;
  final int maxPhotos;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildHeader(), const SizedBox(height: 12), _buildPhotoGrid()],
    );
  }

  /// Заголовок с информацией о фотографиях
  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          'Локальные фотографии',
          style: AppTextStyles.h6.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${photos.length}/$maxPhotos',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Сетка фотографий
  Widget _buildPhotoGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return _buildPhotoItem(photo);
      },
    );
  }

  /// Элемент фотографии
  Widget _buildPhotoItem(LocalPhotoEntity photo) {
    return GestureDetector(
      onTap: () => onPhotoTap?.call(photo),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              // Изображение
              Positioned.fill(
                child: FutureBuilder<bool>(
                  future: photo.exists,
                  builder: (context, snapshot) {
                    if (snapshot.data == true) {
                      return Image.file(
                        photo.file,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildErrorWidget();
                        },
                      );
                    } else {
                      return _buildErrorWidget();
                    }
                  },
                ),
              ),

              // Индикатор загрузки
              if (photo.isUploading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),

              // Индикатор ошибки
              if (photo.uploadError != null)
                Positioned.fill(
                  child: Container(
                    color: AppColors.error.withOpacity(0.8),
                    child: const Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),

              // Кнопка удаления
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => onDeletePhoto(photo),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),

              // Время создания
              Positioned(
                bottom: 4,
                left: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatTime(photo.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Виджет ошибки
  Widget _buildErrorWidget() {
    return Container(
      color: AppColors.error.withOpacity(0.1),
      child: const Center(
        child: Icon(Icons.broken_image, color: AppColors.error, size: 32),
      ),
    );
  }

  /// Пустое состояние
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.photo_camera_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Нет фотографий',
            style: AppTextStyles.h6.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Сфотографируйте или выберите фотографии для заказа',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Форматировать время
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'только что';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}м';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}ч';
    } else {
      return '${difference.inDays}д';
    }
  }
}
