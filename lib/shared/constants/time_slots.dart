/// Константы для временных слотов доставки
class TimeSlots {
  static const List<TimeSlot> slots = [
    TimeSlot(
      value: '10-14',
      label: '10:00 - 14:00',
      description: 'Утренняя доставка',
    ),
    TimeSlot(
      value: '12-16',
      label: '12:00 - 16:00',
      description: 'Дневная доставка',
    ),
    TimeSlot(
      value: '14-18',
      label: '14:00 - 18:00',
      description: 'Послеобеденная доставка',
    ),
    TimeSlot(
      value: '16-20',
      label: '16:00 - 20:00',
      description: 'Вечерняя доставка',
    ),
  ];

  /// Получить слот по значению
  static TimeSlot? getSlotByValue(String value) {
    try {
      return slots.firstWhere((slot) => slot.value == value);
    } catch (e) {
      return null;
    }
  }

  /// Получить название слота по значению
  static String getSlotLabel(String value) {
    final slot = getSlotByValue(value);
    return slot?.label ?? value;
  }

  /// Получить описание слота по значению
  static String getSlotDescription(String value) {
    final slot = getSlotByValue(value);
    return slot?.description ?? '';
  }
}

/// Модель временного слота
class TimeSlot {
  final String value;
  final String label;
  final String description;

  const TimeSlot({
    required this.value,
    required this.label,
    required this.description,
  });
}
