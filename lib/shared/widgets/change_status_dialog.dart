import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../features/orders/domain/entities/order_status_entity.dart';

/// Диалог для смены статуса заказа
class ChangeStatusDialog extends StatefulWidget {
  const ChangeStatusDialog({
    super.key,
    required this.currentStatusId,
    required this.availableStatuses,
    required this.onStatusChanged,
  });

  final int currentStatusId;
  final List<OrderStatusEntity> availableStatuses;
  final Function(int statusId, String note, DateTime? deliveryDate) onStatusChanged;

  /// Показать диалог
  static Future<void> show({
    required BuildContext context,
    required int currentStatusId,
    required List<OrderStatusEntity> availableStatuses,
    required Function(int statusId, String note, DateTime? deliveryDate) onStatusChanged,
  }) {
    return showModalBottomSheet<void>(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangeStatusDialog(
        currentStatusId: currentStatusId,
        availableStatuses: availableStatuses,
        onStatusChanged: onStatusChanged,
      ),
    );
  }

  @override
  State<ChangeStatusDialog> createState() => _ChangeStatusDialogState();
}

class _ChangeStatusDialogState extends State<ChangeStatusDialog> {
  int? _selectedStatusId;
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _noteFocusNode = FocusNode();
  DateTime? _selectedDeliveryDate;
  bool _isSubmitting = false;
  bool _showNoteError = false;
  bool _showDateError = false;

  @override
  void initState() {
    super.initState();
    _selectedStatusId = widget.currentStatusId;

    // Слушаем изменения в поле комментария
    _noteController.addListener(() {
      if (_showNoteError && _noteController.text.trim().isNotEmpty) {
        setState(() {
          _showNoteError = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  /// Проверяет, нужна ли дата для выбранного статуса
  bool _needsDeliveryDate() {
    return _selectedStatusId == 5; // Статус "Перенос"
  }

  /// Проверяет, обязателен ли комментарий для выбранного статуса
  bool _needsNote() {
    return _selectedStatusId == 5 || _selectedStatusId == 6; // "Перенос" или "Отменено"
  }

  /// Получает подсказку для поля комментария в зависимости от статуса
  String _getNoteHint() {
    if (_selectedStatusId == 5) {
      return 'Введите причину переноса...';
    } else if (_selectedStatusId == 6) {
      return 'Введите причину отмены...';
    }
    return 'Введите комментарий к смене статуса...';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
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
              _buildHeader(),
              const SizedBox(height: 20),
              _buildCurrentStatus(),
              const SizedBox(height: 20),
              _buildStatusSelection(),
              const SizedBox(height: 20),
              // Поле выбора даты (только для статуса "Перенос")
              if (_needsDeliveryDate()) ...[
                _buildDateField(),
                const SizedBox(height: 20),
              ],
              _buildNoteField(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// Заголовок диалога
  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          'Сменить статус заказа',
          style: AppTextStyles.h5.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.close,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  /// Текущий статус
  Widget _buildCurrentStatus() {
    final currentStatus = widget.availableStatuses.firstWhere(
      (status) => status.id == widget.currentStatusId,
      orElse: () => widget.availableStatuses.first,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _parseColor(currentStatus.color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _parseColor(currentStatus.color).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Индикатор статуса
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _parseColor(currentStatus.color),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Название статуса
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Текущий статус',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currentStatus.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _parseColor(currentStatus.color),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Выбор статуса
  Widget _buildStatusSelection() {
    // Исключаем запрещенные статусы: "принято" (ID 2) и "завершено" (ID 4)
    final allowedStatuses = widget.availableStatuses
        .where(
          (status) =>
              status.id != widget.currentStatusId &&
              status.id != 2 && // "Принято в работу"
              status.id != 4, // "Завершено"
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Новый статус',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: allowedStatuses
                .map((status) => _buildStatusOption(status))
                .toList(),
          ),
        ),
      ],
    );
  }

  /// Опция статуса
  Widget _buildStatusOption(OrderStatusEntity status) {
    final isSelected = _selectedStatusId == status.id;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedStatusId = status.id;
            // Сбрасываем ошибки при смене статуса
            _showNoteError = false;
            _showDateError = false;
            // Очищаем дату при смене статуса
            _selectedDeliveryDate = null;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: Row(
            children: [
              // Индикатор статуса
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _parseColor(status.color),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              // Название статуса
              Expanded(
                child: Text(
                  status.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              // Радио кнопка
              if (isSelected)
                Icon(
                  Icons.radio_button_checked,
                  color: AppColors.primary,
                  size: 20,
                )
              else
                Icon(
                  Icons.radio_button_unchecked,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Поле для выбора даты (только для статуса "Перенос")
  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Новая дата и время доставки',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _selectDeliveryDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: _showDateError ? AppColors.error : AppColors.border,
                width: _showDateError ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: _showDateError ? AppColors.error : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDeliveryDate != null
                        ? '${_selectedDeliveryDate!.day}.${_selectedDeliveryDate!.month}.${_selectedDeliveryDate!.year} ${_selectedDeliveryDate!.hour.toString().padLeft(2, '0')}:${_selectedDeliveryDate!.minute.toString().padLeft(2, '0')}'
                        : 'Выберите дату и время',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _selectedDeliveryDate != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Поле для заметки
  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Комментарий',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            if (_needsNote())
              Text(
                '*',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteController,
          focusNode: _noteFocusNode,
          maxLines: 3,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: _getNoteHint(),
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _showNoteError ? AppColors.error : AppColors.border,
                width: _showNoteError ? 2 : 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _showNoteError ? AppColors.error : AppColors.border,
                width: _showNoteError ? 2 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _showNoteError ? AppColors.error : AppColors.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
            counterStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          inputFormatters: [LengthLimitingTextInputFormatter(500)],
        ),
      ],
    );
  }

  /// Кнопки действий
  Widget _buildActionButtons() {
    final canSubmit = _selectedStatusId != null && !_isSubmitting;

    return Row(
      children: [
        // Кнопка отмены
        Expanded(
          child: OutlinedButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),

            child: Text(
              'Отмена',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Кнопка подтверждения
        Expanded(
          child: ElevatedButton(
            onPressed: canSubmit ? _submitStatusChange : null,

            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Сменить статус',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  /// Отправить смену статуса
  Future<void> _submitStatusChange() async {
    if (_selectedStatusId == null) return;

    bool hasErrors = false;

    // Проверяем, что комментарий заполнен (если обязателен)
    if (_needsNote() && _noteController.text.trim().isEmpty) {
      setState(() {
        _showNoteError = true;
      });
      hasErrors = true;
    }

    // Проверяем, что дата выбрана (для статуса "Перенос")
    if (_needsDeliveryDate() && _selectedDeliveryDate == null) {
      setState(() {
        _showDateError = true;
      });
      hasErrors = true;
    }

    if (hasErrors) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Скрываем клавиатуру
      FocusScope.of(context).unfocus();

      // Небольшая задержка для UX
      await Future.delayed(const Duration(milliseconds: 300));

      // Вызываем callback
      widget.onStatusChanged(_selectedStatusId!, _noteController.text.trim(), _selectedDeliveryDate);

      // Закрываем диалог
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  /// Выбор даты и времени доставки
  Future<void> _selectDeliveryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDeliveryDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: _selectedDeliveryDate != null
            ? TimeOfDay.fromDateTime(_selectedDeliveryDate!)
            : const TimeOfDay(hour: 9, minute: 0),
      );

      if (time != null && mounted) {
        setState(() {
          _selectedDeliveryDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          _showDateError = false;
        });
      }
    }
  }

  /// Парсинг цвета из строки
  Color _parseColor(String colorString) {
    try {
      String cleanColor = colorString.replaceAll('#', '');

      if (cleanColor.length == 6) {
        return Color(int.parse('FF$cleanColor', radix: 16));
      }

      if (cleanColor.length == 8) {
        return Color(int.parse(cleanColor, radix: 16));
      }

      return AppColors.primary;
    } catch (e) {
      return AppColors.primary;
    }
  }
}
