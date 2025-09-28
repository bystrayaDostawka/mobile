import 'package:flutter/material.dart';

/// Типы сортировки заказов по дате доставки
enum SortOrder {
  deliveryAtDesc, // По дате доставки (новые к старым)
  deliveryAtAsc, // По дате доставки (старые к новым)
}

/// Расширения для SortOrder
extension SortOrderExtension on SortOrder {
  /// Получить название сортировки для отображения
  String get displayName {
    switch (this) {
      case SortOrder.deliveryAtDesc:
        return 'Сортировать от новых к старым';
      case SortOrder.deliveryAtAsc:
        return 'Сортировать от старых к новым';
    }
  }

  /// Получить иконку для сортировки
  IconData get icon {
    switch (this) {
      case SortOrder.deliveryAtAsc:
        return Icons.swap_vert;
      case SortOrder.deliveryAtDesc:
        return Icons.swap_vert;
    }
  }

  /// Получить следующий тип сортировки в цикле
  SortOrder get next {
    switch (this) {
      case SortOrder.deliveryAtDesc:
        return SortOrder.deliveryAtAsc;
      case SortOrder.deliveryAtAsc:
        return SortOrder.deliveryAtDesc;
    }
  }
}
