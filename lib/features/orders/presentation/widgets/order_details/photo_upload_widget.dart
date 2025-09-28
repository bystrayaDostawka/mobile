import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/local_photo_service.dart';
import '../../../../../core/validators/image_validator.dart';
import '../../../../../shared/widgets/confirmation_dialog.dart';
import '../../../../../shared/widgets/fullscreen_instruction_dialog.dart';
import '../../../../../shared/widgets/image_picker_button.dart';
import '../../../../../shared/widgets/photo_grid_widget.dart';
import '../../../../../shared/widgets/local_photo_grid_widget.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/entities/local_photo_entity.dart';
import '../../bloc/order_details_bloc.dart';

/// Рефакторенный виджет для загрузки фотографий заказа
class PhotoUploadWidgetRefactored extends StatefulWidget {
  const PhotoUploadWidgetRefactored({
    super.key,
    required this.orderDetails,
    required this.orderDetailsBloc,
  });

  final OrderDetailsEntity orderDetails;
  final OrderDetailsBloc orderDetailsBloc;

  @override
  State<PhotoUploadWidgetRefactored> createState() =>
      _PhotoUploadWidgetRefactoredState();
}

class _PhotoUploadWidgetRefactoredState
    extends State<PhotoUploadWidgetRefactored> {
  final LocalPhotoService _localPhotoService = LocalPhotoService();
  final List<LocalPhotoEntity> _localPhotos = [];
  bool _isUploading = false;
  int _lastUploadedPhotoCount = 0;

  @override
  void initState() {
    super.initState();
    _lastUploadedPhotoCount = widget.orderDetails.photos.length;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderDetailsBloc, OrderDetailsState>(
      listener: (context, state) {
        if (state is OrderDetailsLoaded) {
          // Проверяем, была ли добавлена новая фотография
          final newPhotoCount = state.orderDetails.photos.length;

          print(
            '📸 BlocListener: текущее количество фото = $newPhotoCount, последнее загруженное = $_lastUploadedPhotoCount',
          );

          if (newPhotoCount > _lastUploadedPhotoCount) {
            print(
              '📸 BlocListener: обнаружена новая фотография! Удаляем из локального списка',
            );

            // Фотография была успешно загружена, удаляем первую из локального списка
            if (_localPhotos.isNotEmpty) {
              final uploadedPhoto = _localPhotos.first;
              print('📸 BlocListener: удаляем фото ${uploadedPhoto.path}');
              _localPhotos.removeAt(0);

              // Обновляем счетчик
              _lastUploadedPhotoCount = newPhotoCount;

              // Очищаем временный файл
              _localPhotoService.deletePhoto(uploadedPhoto).catchError((e) {
                print('Ошибка при удалении временного файла: $e');
              });

              // Обновляем UI
              if (mounted) {
                setState(() {});
              }
            } else {
              print('📸 BlocListener: локальный список пуст, нечего удалять');
            }
          }
        } else if (state is OrderDetailsError) {
          // Обрабатываем ошибку загрузки
          print(
            '📸 BlocListener: ошибка загрузки фотографий: ${state.message}',
          );

          // Останавливаем загрузку
          if (mounted) {
            setState(() {
              _isUploading = false;
              // Сбрасываем статус загрузки для всех фотографий
              for (int i = 0; i < _localPhotos.length; i++) {
                _localPhotos[i] = _localPhotos[i].copyWith(
                  isUploading: false,
                  uploadError: state.message,
                );
              }
            });
          }

          // Показываем сообщение об ошибке
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка загрузки фотографий: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              _buildUploadButton(),
              const SizedBox(height: 16),
              _buildWarningIfNeeded(),
              _buildLocalPhotoGrid(),
              const SizedBox(height: 16),
              _buildUploadedPhotoGrid(context),
              const SizedBox(height: 16),
              _buildBatchUploadButton(),
              const SizedBox(height: 16),
              _buildSecurityWarning(),
            ],
          ),
        ),
      ),
    );
  }

  /// Заголовок с счетчиком фотографий
  Widget _buildHeader(BuildContext context) {
    final totalPhotos = widget.orderDetails.photos.length + _localPhotos.length;
    final isMaxPhotosReached = totalPhotos >= ImageValidator.maxPhotos;

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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$totalPhotos/${ImageValidator.maxPhotos}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: isMaxPhotosReached
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showInstructionDialog(context),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Кнопка загрузки фотографии
  Widget _buildUploadButton() {
    final totalPhotos = widget.orderDetails.photos.length + _localPhotos.length;
    final isMaxPhotosReached = totalPhotos >= ImageValidator.maxPhotos;

    return ImagePickerButton(
      onImagePicked: (source) => _pickImage(context, source),
      isLoading: _isUploading,
      isEnabled: !isMaxPhotosReached,
      disabledLabel:
          'Лимит достигнут (${ImageValidator.maxPhotos}/${ImageValidator.maxPhotos})',
    );
  }

  /// Предупреждение при приближении к лимиту
  Widget _buildWarningIfNeeded() {
    final totalPhotos = widget.orderDetails.photos.length + _localPhotos.length;
    final shouldShowWarning =
        totalPhotos >= ImageValidator.maxPhotos * 0.75 &&
        totalPhotos < ImageValidator.maxPhotos;

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
                  'Осталось ${ImageValidator.maxPhotos - totalPhotos} фото из ${ImageValidator.maxPhotos}',
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

  /// Сетка локальных фотографий
  Widget _buildLocalPhotoGrid() {
    if (_localPhotos.isEmpty) return const SizedBox.shrink();

    return LocalPhotoGridWidget(
      photos: _localPhotos,
      onDeletePhoto: _deleteLocalPhoto,
      maxPhotos: ImageValidator.maxPhotos,
    );
  }

  /// Сетка загруженных фотографий
  Widget _buildUploadedPhotoGrid(BuildContext context) {
    if (widget.orderDetails.photos.isEmpty) return const SizedBox.shrink();

    return PhotoGridWidget(
      photos: widget.orderDetails.photos,
      onDeletePhoto: (photo) => _showDeleteConfirmation(context, photo),
    );
  }

  /// Кнопка пакетной загрузки
  Widget _buildBatchUploadButton() {
    if (_localPhotos.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isUploading ? null : _uploadAllPhotos,
        icon: _isUploading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.cloud_upload),
        label: Text(
          _isUploading
              ? 'Загружаем...'
              : 'Загрузить все фото (${_localPhotos.length})',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
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
    widget.orderDetailsBloc.add(
      DeleteOrderPhoto(orderId: widget.orderDetails.id, photoId: photo.id),
    );
  }

  /// Удалить локальную фотографию
  void _deleteLocalPhoto(LocalPhotoEntity photo) async {
    try {
      await _localPhotoService.deletePhoto(photo);
      if (mounted) {
        setState(() {
          _localPhotos.remove(photo);
        });
      }
    } catch (e) {
      _showError('Ошибка при удалении фотографии: $e');
    }
  }

  /// Выбрать изображение
  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      // Проверяем лимит фотографий
      final totalPhotos =
          widget.orderDetails.photos.length + _localPhotos.length;
      final countValidation = ImageValidator.validatePhotoCount(totalPhotos);
      if (!countValidation.isValid) {
        _showError(countValidation.errorMessage!);
        return;
      }

      // Выбираем изображение
      LocalPhotoEntity? localPhoto;
      if (source == ImageSource.camera) {
        localPhoto = await _localPhotoService.takePhoto();
      } else {
        localPhoto = await _localPhotoService.pickFromGallery();
      }

      if (localPhoto != null && mounted) {
        setState(() {
          _localPhotos.add(localPhoto!);
        });
      }
    } catch (e) {
      _showError('Ошибка при выборе изображения: $e');
    }
  }

  /// Показать ошибку
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
    }
  }

  /// Предупреждение о безопасности данных
  Widget _buildSecurityWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
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
    );
  }

  /// Показать диалог с инструкцией
  void _showInstructionDialog(BuildContext context) {
    FullscreenInstructionDialog.show(
      context: context,
      title: 'Инструкция',
      imageAsset: 'assets/images/instructions.png',
    );
  }

  /// Загрузить все локальные фотографии
  Future<void> _uploadAllPhotos() async {
    if (_localPhotos.isEmpty) return;

    print('📸 Начинаем загрузку ${_localPhotos.length} фотографий');

    if (!mounted) return;
    setState(() {
      _isUploading = true;
    });

    try {
      // Обновляем статус загрузки для всех фотографий
      if (mounted) {
        setState(() {
          for (int i = 0; i < _localPhotos.length; i++) {
            _localPhotos[i] = _localPhotos[i].copyWith(isUploading: true);
          }
        });
      }

      // Отправляем все фотографии одним запросом
      final photoPaths = _localPhotos.map((photo) => photo.path).toList();

      print('📸 Отправляем ${photoPaths.length} фотографий одним запросом');

      // Отправляем событие загрузки всех фотографий в BLoC
      widget.orderDetailsBloc.add(
        UploadOrderPhotos(
          orderId: widget.orderDetails.id,
          photoPaths: photoPaths,
        ),
      );

      print('📸 Событие загрузки отправлено для всех фотографий');
    } catch (e) {
      print('❌ Ошибка при отправке фотографий: $e');
      // Останавливаем загрузку при ошибке
      if (mounted) {
        setState(() {
          _isUploading = false;
          // Сбрасываем статус загрузки для всех фотографий
          for (int i = 0; i < _localPhotos.length; i++) {
            _localPhotos[i] = _localPhotos[i].copyWith(
              isUploading: false,
              uploadError: e.toString(),
            );
          }
        });
      }
    }
  }

  @override
  void dispose() {
    // Очищаем временные файлы при закрытии виджета
    _localPhotoService.clearTempFiles();
    super.dispose();
  }
}
