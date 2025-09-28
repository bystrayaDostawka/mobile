import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/services/image_service.dart';
import '../../features/orders/domain/entities/order_entity.dart';

/// Виджет для отображения отдельной фотографии
class PhotoItemWidget extends StatelessWidget {
  const PhotoItemWidget({
    super.key,
    required this.photo,
    required this.onDelete,
  });

  final PhotoEntity photo;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Изображение
            if (photo.url != null)
              _NetworkImageWidget(imageUrl: photo.url!, width: 120, height: 120)
            else if (photo.filePath != null)
              Image.asset(
                photo.filePath!,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorWidget();
                },
              )
            else
              _buildErrorWidget(),

            // Кнопка удаления
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.8),
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
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: 120,
      height: 120,
      color: AppColors.surfaceVariant,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 32),
          const SizedBox(height: 4),
          Text(
            'Ошибка',
            style: AppTextStyles.caption.copyWith(color: AppColors.error),
          ),
        ],
      ),
    );
  }
}

/// Виджет для загрузки изображений через сеть
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
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final imageData = await ImageService().loadNetworkImage(widget.imageUrl);
      if (mounted) {
        setState(() {
          _imageData = imageData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
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

    if (_hasError || _imageData == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: AppColors.surfaceVariant,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 32),
            const SizedBox(height: 4),
            Text(
              'Ошибка',
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ],
        ),
      );
    }

    return Image.memory(
      _imageData!,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.cover,
    );
  }
}
