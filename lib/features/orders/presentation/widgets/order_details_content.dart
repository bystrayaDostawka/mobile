import 'package:bystraya_dostawka/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/phone_service.dart';
import '../../../../core/services/map_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../shared/widgets/courier_comment_widget.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_status_entity.dart';
import '../bloc/order_details_bloc.dart';
import 'order_details/photo_upload_widget.dart';
import 'order_files_widget.dart';

/// Виджет с содержимым деталей заказа
class OrderDetailsContent extends StatefulWidget {
  const OrderDetailsContent({
    super.key,
    required this.orderDetails,
    required this.statuses,
    required this.orderDetailsBloc,
  });

  final OrderDetailsEntity orderDetails;
  final List<OrderStatusEntity> statuses;
  final OrderDetailsBloc orderDetailsBloc;

  @override
  State<OrderDetailsContent> createState() => _OrderDetailsContentState();
}

class _OrderDetailsContentState extends State<OrderDetailsContent> {
  String? _currentCourierComment;

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderDetailsBloc, OrderDetailsState>(
      listener: (context, state) {
        if (state is OrderDetailsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Закрыть',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        } else if (state is CourierNoteSaved) {
          // Определяем иконку в зависимости от действия
          IconData icon = Icons.check_circle;
          if (state.message.contains('удалена')) {
            icon = Icons.delete_outline;
          } else if (state.message.contains('обновлена')) {
            icon = Icons.edit_outlined;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(state.message),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is OrderDetailsLoaded) {
          // Сбрасываем текущий комментарий при обновлении заказа
          if (state.orderDetails.courierComment == null) {
            _currentCourierComment = null;
          }
        }
      },
      child: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppTheme.spacing4,
            children: [
              Text(
                'Информация о клиенте',
                style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppTheme.spacing8),
              _buildInfoRow('ФИО', widget.orderDetails.fullName),
              _buildInfoRow(
                'Телефон',
                widget.orderDetails.phone,
                isPhone: true,
              ),
              _buildInfoRow(
                'Адрес',
                widget.orderDetails.address,
                isAddress: true,
              ),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                'Информация о доставке',
                style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppTheme.spacing8),
              _buildInfoRow(
                'Дата доставки',
                widget.orderDetails.formattedDeliveryAt,
              ),
              _buildInfoRow(
                'Дата завершения',
                widget.orderDetails.formattedDeliveredAt,
              ),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                'Информация о продукте',
                style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Продукт', widget.orderDetails.product),
              _buildInfoRow('Банк', widget.orderDetails.bankName),
              const SizedBox(height: 16),
              if (widget.orderDetails.note != null) ...[
                Text(
                  'Заметка по стадии',
                  style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.orderDetails.note!,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppTheme.spacing16),
              ],
              if (widget.orderDetails.declinedReason != null) ...[
                Text(
                  widget.orderDetails.orderStatusId == 5
                      ? 'Причина переноса'
                      : widget.orderDetails.orderStatusId == 6
                      ? 'Причина отмены'
                      : 'Дополнительная информация',
                  style: AppTextStyles.h5.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.orderDetails.declinedReason!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
              ],

              PhotoUploadWidgetRefactored(
                orderDetails: widget.orderDetails,
                orderDetailsBloc: widget.orderDetailsBloc,
              ),
              const SizedBox(height: AppTheme.spacing16),

              // Файлы заказа
              Text(
                'Файлы заказа',
                style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Container(
                height: 300, // Фиксированная высота для списка файлов
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: OrderFilesWidget(orderId: widget.orderDetails.id),
              ),
              const SizedBox(height: AppTheme.spacing16),

              // Комментарий курьера
              CourierCommentWidget(
                initialComment: widget.orderDetails.courierComment,
                readOnly: false,
                showSaveButton: true,
                onCommentChanged: (comment) {
                  // Сохраняем комментарий для последующего сохранения
                  _currentCourierComment = comment;
                },
                onSaveComment: () {
                  if (_currentCourierComment != null &&
                      _currentCourierComment!.isNotEmpty) {
                    // Создаем новую заметку курьера
                    widget.orderDetailsBloc.add(
                      CreateCourierNote(
                        orderId: widget.orderDetails.id,
                        courierNote: _currentCourierComment!,
                      ),
                    );
                  }
                },
                onDeleteComment: () {
                  // Удаляем заметку курьера
                  widget.orderDetailsBloc.add(
                    DeleteCourierNote(orderId: widget.orderDetails.id),
                  );
                },
              ),
              const SizedBox(height: AppTheme.spacing16),
            ],
          ),
        ),
      ),
    );
  }

  /// Строка с информацией
  Widget _buildInfoRow(
    String label,
    String value, {
    bool isPhone = false,
    bool isAddress = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (isPhone) {
                  PhoneService.makeCall(value);
                } else if (isAddress) {
                  MapService.openAddress(value);
                }
              },
              child: Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: (isPhone || isAddress) ? AppColors.primary : null,
                  decoration: (isPhone || isAddress)
                      ? TextDecoration.underline
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
