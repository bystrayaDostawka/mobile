import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Модель статуса заказа для фильтрации
class OrderStatusFilter {
  final int? id;
  final String label;
  final Color color;

  const OrderStatusFilter({
    required this.id,
    required this.label,
    required this.color,
  });

  static const List<OrderStatusFilter> allStatuses = [
    OrderStatusFilter(id: null, label: 'Все', color: AppColors.surfaceVariant),
    OrderStatusFilter(id: 1, label: 'Новые', color: AppColors.info),
    OrderStatusFilter(id: 2, label: 'В работе', color: AppColors.warning),
    OrderStatusFilter(
      id: 3,
      label: 'Проверка',
      color: AppColors.orderInProgress,
    ),
    OrderStatusFilter(id: 4, label: 'Завершено', color: AppColors.success),
    OrderStatusFilter(id: 5, label: 'Перенос', color: AppColors.orderDeferred),
    OrderStatusFilter(id: 6, label: 'Отменено', color: AppColors.error),
  ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderStatusFilter && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

