import 'package:bystraya_dostawka/features/orders/domain/entities/order_status_entity.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_fonts.dart';

/// Виджет для выбора статуса заказа
class OrderStatusDropdown extends StatelessWidget {
  const OrderStatusDropdown({
    super.key,
    required this.statuses,
    required this.currentStatusId,
    this.onStatusChanged,
  });

  final List<OrderStatusEntity> statuses;
  final int currentStatusId;
  final ValueChanged<int>? onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Статус заказа',
              style: AppTextStyles.h6.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: currentStatusId,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.surface),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.surface),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: statuses.map((status) {
                return DropdownMenuItem<int>(
                  value: status.id,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _parseColor(status.color),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        status.title,
                        style: AppTextStyles.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onStatusChanged != null
                  ? (value) {
                      if (value != null) {
                        onStatusChanged!(value);
                      }
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Парсинг цвета из строки
  Color _parseColor(String colorString) {
    try {
      // Убираем # если есть
      String cleanColor = colorString.replaceAll('#', '');

      // Если это hex цвет
      if (cleanColor.length == 6) {
        return Color(int.parse('FF$cleanColor', radix: 16));
      }

      // Если это уже с alpha
      if (cleanColor.length == 8) {
        return Color(int.parse(cleanColor, radix: 16));
      }

      // Fallback к основному цвету
      return AppColors.primary;
    } catch (e) {
      return AppColors.primary;
    }
  }
}
