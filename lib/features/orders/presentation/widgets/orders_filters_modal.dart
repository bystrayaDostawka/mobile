import 'package:bystraya_dostawka/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/orders_bloc.dart';
import 'order_status_filter.dart';

class OrdersFiltersModal extends StatefulWidget {
  const OrdersFiltersModal({super.key});

  @override
  State<OrdersFiltersModal> createState() => _OrdersFiltersModalState();
}

class _OrdersFiltersModalState extends State<OrdersFiltersModal> {
  DateTime? _selectedDate;
  DateTimeRange? _selectedDateRange;
  List<int> _selectedStatusIds = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentFilters();
  }

  void _loadCurrentFilters() {
    final state = context.read<OrdersBloc>().state;
    if (state is OrdersLoaded) {
      // Загружаем выбранные статусы
      _selectedStatusIds = List.from(state.selectedStatusIds);

      // Парсим даты из строк
      if (state.dateFrom != null && state.dateTo != null) {
        try {
          final dateFrom = DateTime.parse(state.dateFrom!);
          final dateTo = DateTime.parse(state.dateTo!);

          if (dateFrom.isAtSameMomentAs(dateTo)) {
            _selectedDate = dateFrom;
            _selectedDateRange = null;
          } else {
            _selectedDateRange = DateTimeRange(start: dateFrom, end: dateTo);
            _selectedDate = null;
          }
        } catch (e) {
          print('Ошибка парсинга дат: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок с кнопками
            Row(
              children: [
                const Icon(
                  Icons.filter_list,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Фильтры',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text(
                    'Очистить',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Фильтр по статусам
            Row(
              children: [
                const Text(
                  'Статусы заказов',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (_selectedStatusIds.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_selectedStatusIds.length} выбрано',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            _buildStatusFilters(),
            const SizedBox(height: 20),

            // Разделитель
            Container(height: 1, color: AppColors.border),
            const SizedBox(height: 20),

            // Фильтр по датам
            const Text(
              'Фильтр по датам',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Фильтр по конкретной дате
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    spacing: 4,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Фильтр по дате',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _selectDate,
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: Text(
                            _selectedDate != null
                                ? '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}'
                                : 'Выберите дату',
                            style: const TextStyle(fontSize: 14),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      const Text(
                        'Фильтр по диапазону',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _selectDateRange,
                          icon: const Icon(Icons.date_range, size: 18),
                          label: Text(
                            _selectedDateRange != null
                                ? '${_selectedDateRange!.start.day}.${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}.${_selectedDateRange!.end.month}'
                                : 'Выберите период',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),

            const SizedBox(height: 32),

            // Кнопки применения и отмены
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Отмена'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _applyFilters();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Применить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _applyFilters() {
    String? dateFrom;
    String? dateTo;

    if (_selectedDateRange != null) {
      dateFrom =
          '${_selectedDateRange!.start.year}-${_selectedDateRange!.start.month.toString().padLeft(2, '0')}-${_selectedDateRange!.start.day.toString().padLeft(2, '0')}';
      dateTo =
          '${_selectedDateRange!.end.year}-${_selectedDateRange!.end.month.toString().padLeft(2, '0')}-${_selectedDateRange!.end.day.toString().padLeft(2, '0')}';
    } else if (_selectedDate != null) {
      dateFrom =
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      dateTo = dateFrom;
    }

    final state = context.read<OrdersBloc>().state;
    if (state is OrdersLoaded) {
      // Применяем фильтры с поддержкой множественного выбора статусов
      print('🔧 OrdersFiltersModal: Применяем фильтры');
      print('🔧 OrdersFiltersModal: selectedStatusIds: $_selectedStatusIds');
      context.read<OrdersBloc>().add(
        UpdateFilters(
          search: state.search,
          orderStatusId: _selectedStatusIds.isNotEmpty ? _selectedStatusIds.first : null, // Для обратной совместимости
          selectedStatusIds: _selectedStatusIds,
          dateFrom: dateFrom,
          dateTo: dateTo,
        ),
      );
    } else {
      context.read<OrdersBloc>().add(
        UpdateFilters(
          orderStatusId: _selectedStatusIds.isNotEmpty ? _selectedStatusIds.first : null, // Для обратной совместимости
          selectedStatusIds: _selectedStatusIds,
          dateFrom: dateFrom,
          dateTo: dateTo,
        ),
      );
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedDate = null;
      _selectedDateRange = null;
      _selectedStatusIds.clear();
    });
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _selectedDateRange = null; // Очищаем диапазон дат
      });
    }
  }

  Future<void> _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
    );

    if (range != null) {
      setState(() {
        _selectedDateRange = range;
        _selectedDate = null; // Очищаем одиночную дату
      });
    }
  }

  Widget _buildStatusFilters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: OrderStatusFilter.allStatuses
          .where((status) => status.id != null) // Исключаем "Все"
          .map(
            (status) => FilterChip(
              label: Text(status.label),
              selected: _selectedStatusIds.contains(status.id),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    // Добавляем статус к выбранным (множественный выбор)
                    if (!_selectedStatusIds.contains(status.id!)) {
                      _selectedStatusIds.add(status.id!);
                    }
                  } else {
                    // Убираем статус из выбранных
                    _selectedStatusIds.remove(status.id);
                  }
                });
              },
              selectedColor: status.color.withOpacity(0.3),
              checkmarkColor: status.color,
            ),
          )
          .toList(),
    );
  }
}
