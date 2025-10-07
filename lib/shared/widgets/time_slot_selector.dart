import 'package:flutter/material.dart';
import '../constants/time_slots.dart';

/// Виджет для выбора временного слота доставки
class TimeSlotSelector extends StatelessWidget {
  final String? selectedTimeRange;
  final ValueChanged<String> onTimeRangeSelected;

  const TimeSlotSelector({
    Key? key,
    this.selectedTimeRange,
    required this.onTimeRangeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Выберите время доставки',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: TimeSlots.slots.length,
          itemBuilder: (context, index) {
            final slot = TimeSlots.slots[index];
            final isSelected = selectedTimeRange == slot.value;

            return GestureDetector(
              onTap: () => onTimeRangeSelected(slot.value),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected 
                        ? const Color(0xFF3B82F6) 
                        : const Color(0xFFE5E7EB),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected 
                      ? const Color(0xFFEFF6FF) 
                      : Colors.white,
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                slot.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected 
                                      ? const Color(0xFF1F2937) 
                                      : const Color(0xFF374151),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                slot.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected 
                                      ? const Color(0xFF6B7280) 
                                      : const Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF3B82F6),
                            size: 20,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Виджет для отображения выбранного времени доставки
class SelectedDeliveryTimeDisplay extends StatelessWidget {
  final DateTime? deliveryDate;
  final String? timeRange;

  const SelectedDeliveryTimeDisplay({
    Key? key,
    this.deliveryDate,
    this.timeRange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (deliveryDate == null || timeRange == null) {
      return const SizedBox.shrink();
    }

    final timeSlotLabel = TimeSlots.getSlotLabel(timeRange!);
    final formattedDate = _formatDate(deliveryDate!);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        border: Border.all(color: const Color(0xFFBBF7D0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.schedule,
            color: Color(0xFF059669),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Выбрано: $formattedDate - $timeSlotLabel',
            style: const TextStyle(
              color: Color(0xFF065F46),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
