import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/services/phone_service.dart';
import '../../../../../core/services/whatsapp_service.dart';
import '../../../../../core/services/map_service.dart';
import '../../../../../shared/widgets/change_status_button.dart';
import 'package:bystraya_dostawka/features/orders/domain/entities/order_entity.dart';
import 'package:bystraya_dostawka/features/orders/domain/entities/order_status_entity.dart';
import '../../bloc/order_details_bloc.dart';

class OrderActionsBar extends StatelessWidget {
  const OrderActionsBar({
    super.key,
    required this.orderDetails,
    required this.statuses,
  });

  final OrderDetailsEntity orderDetails;
  final List<OrderStatusEntity> statuses;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Кнопка смены статуса (скрываем для завершенных и отмененных заказов)
            if (statuses.isNotEmpty &&
                !_isFinalStatus(orderDetails.orderStatusId))
              BlocBuilder<OrderDetailsBloc, OrderDetailsState>(
                builder: (context, state) {
                  final currentStatus = statuses.firstWhere(
                    (status) => status.id == orderDetails.orderStatusId,
                    orElse: () => statuses.first,
                  );
                  final isLoading = state is OrderDetailsUpdating;

                  return ChangeStatusButton(
                    currentStatus: currentStatus,
                    availableStatuses: statuses,
                    isLoading: isLoading,
                    onStatusChanged:
                        (statusId, note, deliveryDate, deliveryTimeRange) {
                          context.read<OrderDetailsBloc>().add(
                            UpdateOrderStatus(
                              orderId: orderDetails.id,
                              orderStatusId: statusId,
                              note: note,
                              deliveryDate: deliveryDate,
                              deliveryTimeRange: deliveryTimeRange,
                            ),
                          );
                        },
                  );
                },
              ),
            if (statuses.isNotEmpty &&
                !_isFinalStatus(orderDetails.orderStatusId))
              const SizedBox(height: 12),
            // Кнопки позвонить, WhatsApp и маршрут
            Row(
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) => OutlinedButton.icon(
                      onPressed: () =>
                          _makePhoneCall(orderDetails.phone, context),
                      icon: const Icon(Icons.phone, size: 20),
                      label: const Text('Позвонить'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Builder(
                    builder: (context) => OutlinedButton.icon(
                      onPressed: () =>
                          _openWhatsApp(orderDetails.phone, context),
                      icon: const Icon(Icons.chat, size: 20),
                      label: const Text('WhatsApp'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF24CC63),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: Color(0xFF24CC63)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openMaps(orderDetails.address),
                    icon: const Icon(Icons.navigation, size: 20),
                    label: const Text('На карте'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF74231),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: Color(0xFFF74231)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Совершить звонок
  Future<void> _makePhoneCall(String phoneNumber, BuildContext context) async {
    try {
      final success = await PhoneService.makeCall(phoneNumber);
      if (!success && context.mounted) {
        _showSnackBar(context, 'Номер скопирован в буфер обмена: $phoneNumber');
      }
    } catch (e) {
      debugPrint('Ошибка при звонке: $e');
      if (context.mounted) {
        _showSnackBar(context, 'Ошибка при звонке', isError: true);
      }
    }
  }

  /// Открыть WhatsApp с контактом
  Future<void> _openWhatsApp(String phoneNumber, BuildContext context) async {
    try {
      final success = await WhatsAppService.openChat(phoneNumber);
      if (!success && context.mounted) {
        _showSnackBar(context, 'Не удалось открыть WhatsApp', isError: true);
      }
    } catch (e) {
      debugPrint('Ошибка при открытии WhatsApp: $e');
      if (context.mounted) {
        _showSnackBar(context, 'Ошибка при открытии WhatsApp', isError: true);
      }
    }
  }

  /// Показать SnackBar с уведомлением
  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Открыть карты с адресом
  Future<void> _openMaps(String address) async {
    try {
      await MapService.openAddress(address);
    } catch (e) {
      // В случае ошибки просто логируем, сервис сам обработает все случаи
      debugPrint('Ошибка при открытии карт: $e');
    }
  }

  /// Проверить, является ли статус финальным (завершено или отменено)
  bool _isFinalStatus(int statusId) {
    // 4 - Завершено, 6 - Отменено
    return statusId == 4 || statusId == 6;
  }
}
