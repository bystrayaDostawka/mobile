import 'package:flutter/material.dart';

import '../../core/validators/status_change_validator.dart';
import '../../features/orders/domain/entities/order_status_entity.dart';
import 'change_status_dialog.dart';

/// Кнопка для смены статуса заказа
class ChangeStatusButton extends StatelessWidget {
  const ChangeStatusButton({
    super.key,
    required this.currentStatus,
    required this.availableStatuses,
    required this.onStatusChanged,
    this.isLoading = false,
  });

  final OrderStatusEntity currentStatus;
  final List<OrderStatusEntity> availableStatuses;
  final Function(int statusId, String note, DateTime? deliveryDate, String? deliveryTimeRange) onStatusChanged;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // _buildCurrentStatus(),
        _buildChangeButton(context),
      ],
    );
  }

  Widget _buildChangeButton(BuildContext context) {
    final canChange = StatusChangeValidator.canChangeStatus(
      currentStatusId: currentStatus.id,
      availableStatuses: availableStatuses,
    );

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading || !canChange
            ? null
            : () => _showChangeStatusDialog(context),
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.edit),
        label: Text(
          isLoading
              ? 'Обновляем...'
              : canChange
              ? 'Сменить статус'
              : 'Нет доступных статусов',
        ),
        style: ElevatedButton.styleFrom(
          // backgroundColor: AppColors.primary,
          // foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
    );
  }

  /// Показать диалог смены статуса
  void _showChangeStatusDialog(BuildContext context) {
    ChangeStatusDialog.show(
      context: context,
      currentStatusId: currentStatus.id,
      availableStatuses: availableStatuses,
      onStatusChanged: (statusId, note, deliveryDate, deliveryTimeRange) {
        onStatusChanged(statusId, note, deliveryDate, deliveryTimeRange);
      },
    );
  }
}
