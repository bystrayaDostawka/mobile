import 'package:bystraya_dostawka/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/orders_bloc.dart';
import 'order_status_filter.dart';

class ActiveFiltersChip extends StatelessWidget {
  const ActiveFiltersChip({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        if (state is! OrdersLoaded) {
          return const SizedBox.shrink();
        }
        final hasActiveFilters =
            state.search != null ||
            state.dateFrom != null ||
            state.orderStatusId != null;
        if (!hasActiveFilters) {
          return const SizedBox.shrink();
        }
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (state.search != null)
                  _buildFilterChip(
                    label: 'Поиск: ${state.search}',
                    onDeleted: () => _removeSearchFilter(context),
                  ),

                if (state.orderStatusId != null)
                  _buildFilterChip(
                    label: OrderStatusFilter.allStatuses
                        .firstWhere((s) => s.id == state.orderStatusId)
                        .label,
                    onDeleted: () =>
                        _removeStatusFilter(context, state.orderStatusId!),
                  ),

                if (state.dateFrom != null)
                  _buildFilterChip(
                    label:
                        'Дата: ${_formatDateFilter(state.dateFrom!, state.dateTo!)}',
                    onDeleted: () => _removeDateFilter(context),
                  ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _clearAllFilters(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                  child: const Text(
                    'Очистить все',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onDeleted,
        backgroundColor: AppColors.primary,
        labelStyle: const TextStyle(color: AppColors.black),
        deleteIconColor: AppColors.black,
      ),
    );
  }

  String _formatDateFilter(String dateFrom, String? dateTo) {
    try {
      final from = DateTime.parse(dateFrom);
      final to = dateTo != null ? DateTime.parse(dateTo) : null;

      if (to != null && !from.isAtSameMomentAs(to)) {
        return '${from.day}.${from.month} - ${to.day}.${to.month}';
      } else {
        return '${from.day}.${from.month}.${from.year}';
      }
    } catch (e) {
      return 'Дата';
    }
  }

  void _removeSearchFilter(BuildContext context) {
    final state = context.read<OrdersBloc>().state;
    if (state is OrdersLoaded) {
      context.read<OrdersBloc>().add(
        UpdateFilters(
          search: null,
          orderStatusId: state.orderStatusId,
          selectedStatusIds: state.selectedStatusIds,
          dateFrom: state.dateFrom,
          dateTo: state.dateTo,
        ),
      );
    }
  }

  void _removeDateFilter(BuildContext context) {
    final state = context.read<OrdersBloc>().state;
    if (state is OrdersLoaded) {
      context.read<OrdersBloc>().add(
        UpdateFilters(
          search: state.search,
          orderStatusId: state.orderStatusId,
          selectedStatusIds: state.selectedStatusIds,
          dateFrom: null,
          dateTo: null,
        ),
      );
    }
  }

  void _removeStatusFilter(BuildContext context, int statusId) {
    final state = context.read<OrdersBloc>().state;
    if (state is OrdersLoaded) {
      context.read<OrdersBloc>().add(
        UpdateFilters(
          search: state.search,
          orderStatusId: null, // Очищаем фильтр по статусу
          selectedStatusIds: state.selectedStatusIds,
          dateFrom: state.dateFrom,
          dateTo: state.dateTo,
        ),
      );
    }
  }

  void _clearAllFilters(BuildContext context) {
    context.read<OrdersBloc>().add(const ClearFilters());
  }
}
