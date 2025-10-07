import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/theme/app_colors.dart';
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
            // Кнопка смены статуса
            if (statuses.isNotEmpty)
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
                    onStatusChanged: (statusId, note, deliveryDate, deliveryTimeRange) {
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
            if (statuses.isNotEmpty) const SizedBox(height: 12),
            // Кнопки позвонить и маршрут
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _makePhoneCall(orderDetails.phone),
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
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openMaps(orderDetails.address),
                    icon: const Icon(Icons.navigation, size: 20),
                    label: const Text('На карте'),
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Совершить звонок
  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        await Clipboard.setData(ClipboardData(text: phoneNumber));
        print('Номер скопирован в буфер обмена: $phoneNumber');
      }
    } catch (e) {
      print('Ошибка при звонке: $e');
      try {
        await Clipboard.setData(ClipboardData(text: phoneNumber));
        print('Номер скопирован в буфер обмена: $phoneNumber');
      } catch (clipboardError) {
        print('Ошибка при копировании номера: $clipboardError');
      }
    }
  }

  /// Открыть карты с адресом
  Future<void> _openMaps(String address) async {
    try {
      final Uri mapsUri = Uri(scheme: 'geo', path: '0,0', query: 'q=$address');

      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri);
      } else {
        // Fallback для Google Maps
        final Uri googleMapsUri = Uri(
          scheme: 'https',
          host: 'maps.google.com',
          query: 'q=$address',
        );

        if (await canLaunchUrl(googleMapsUri)) {
          await launchUrl(googleMapsUri);
        } else {
          print('Не удалось открыть карты для адреса: $address');
          // Fallback - копируем адрес в буфер обмена
          await Clipboard.setData(ClipboardData(text: address));
          print('Адрес скопирован в буфер обмена: $address');
        }
      }
    } catch (e) {
      print('Ошибка при открытии карт: $e');
      // Fallback - копируем адрес в буфер обмена
      try {
        await Clipboard.setData(ClipboardData(text: address));
        print('Адрес скопирован в буфер обмена: $address');
      } catch (clipboardError) {
        print('Ошибка при копировании адреса: $clipboardError');
      }
    }
  }
}
