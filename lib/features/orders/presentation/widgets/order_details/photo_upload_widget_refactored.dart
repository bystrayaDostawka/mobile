import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/image_service.dart';
import '../../../../../core/validators/image_validator.dart';
import '../../../../../shared/widgets/confirmation_dialog.dart';
import '../../../../../shared/widgets/image_picker_button.dart';
import '../../../../../shared/widgets/photo_grid_widget.dart';
import '../../../domain/entities/order_entity.dart';
import '../../bloc/order_details_bloc.dart';

/// Рефакторенный виджет для загрузки фотографий заказа
class PhotoUploadWidgetRefactored extends StatelessWidget {
  const PhotoUploadWidgetRefactored({
    super.key,
    required this.orderDetails,
    required this.orderDetailsBloc,
  });

  final OrderDetailsEntity orderDetails;
  final OrderDetailsBloc orderDetailsBloc;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildUploadButton(),
            const SizedBox(height: 16),
            _buildWarningIfNeeded(),
            _buildPhotoGrid(context),
          ],
        ),
      ),
    );
  }

  /// Заголовок с счетчиком фотографий
  Widget _buildHeader() {
    final isMaxPhotosReached =
        orderDetails.photos.length >= ImageValidator.maxPhotos;

    return Row(
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
          '${orderDetails.photos.length}/${ImageValidator.maxPhotos}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: isMaxPhotosReached
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  /// Кнопка загрузки фотографии
  Widget _buildUploadButton() {
    return BlocBuilder<OrderDetailsBloc, OrderDetailsState>(
      bloc: orderDetailsBloc,
      builder: (context, state) {
        final isUploading = state is OrderPhotoUploading;
        final isMaxPhotosReached =
            orderDetails.photos.length >= ImageValidator.maxPhotos;

        return ImagePickerButton(
          onImagePicked: (source) => _pickImage(context, source),
          isLoading: isUploading,
          isEnabled: !isMaxPhotosReached,
          disabledLabel:
              'Лимит достигнут (${ImageValidator.maxPhotos}/${ImageValidator.maxPhotos})',
        );
      },
    );
  }

  /// Предупреждение при приближении к лимиту
  Widget _buildWarningIfNeeded() {
    final currentCount = orderDetails.photos.length;
    final shouldShowWarning =
        currentCount >= ImageValidator.maxPhotos * 0.75 &&
        currentCount < ImageValidator.maxPhotos;

    if (!shouldShowWarning) return const SizedBox.shrink();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
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
                  'Осталось ${ImageValidator.maxPhotos - currentCount} фото из ${ImageValidator.maxPhotos}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  /// Сетка фотографий
  Widget _buildPhotoGrid(BuildContext context) {
    return PhotoGridWidget(
      photos: orderDetails.photos,
      onDeletePhoto: (photo) => _showDeleteConfirmation(context, photo),
    );
  }

  /// Показать диалог подтверждения удаления
  Future<void> _showDeleteConfirmation(
    BuildContext context,
    PhotoEntity photo,
  ) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Удалить фотографию',
      message: 'Вы уверены, что хотите удалить эту фотографию?',
      confirmText: 'Удалить',
      isDestructive: true,
    );

    if (confirmed == true) {
      _deletePhoto(photo);
    }
  }

  /// Удалить фотографию
  void _deletePhoto(PhotoEntity photo) {
    orderDetailsBloc.add(
      DeleteOrderPhoto(orderId: orderDetails.id, photoId: photo.id),
    );
  }

  /// Выбрать изображение
  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      // Проверяем лимит фотографий
      final countValidation = ImageValidator.validatePhotoCount(
        orderDetails.photos.length,
      );
      if (!countValidation.isValid) {
        _showError(context, countValidation.errorMessage!);
        return;
      }

      // Выбираем изображение
      final image = await ImageService().pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image == null) return;

      // Валидируем изображение
      final validation = await ImageValidator.validateImage(image);
      if (!validation.isValid) {
        _showError(context, validation.errorMessage!);
        return;
      }

      // Отправляем событие загрузки фотографии в BLoC
      orderDetailsBloc.add(
        UploadOrderPhoto(orderId: orderDetails.id, photoPath: image.path),
      );
    } catch (e) {
      _showError(context, 'Ошибка при выборе изображения: $e');
    }
  }

  /// Показать ошибку
  void _showError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
    }
  }
}
