import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../features/orders/domain/entities/order_entity.dart';
import 'photo_item_widget.dart';

/// Виджет для отображения сетки фотографий
class PhotoGridWidget extends StatelessWidget {
  const PhotoGridWidget({
    super.key,
    required this.photos,
    required this.onDeletePhoto,
  });

  final List<PhotoEntity> photos;
  final void Function(PhotoEntity photo) onDeletePhoto;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              return PhotoItemWidget(
                photo: photo,
                onDelete: () => onDeletePhoto(photo),
              );
            },
          ),
        ),
      ],
    );
  }
}




