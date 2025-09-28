import '../../features/orders/domain/entities/order_status_entity.dart';

/// Результат валидации смены статуса
class StatusChangeValidationResult {
  final bool isValid;
  final String? errorMessage;

  const StatusChangeValidationResult({
    required this.isValid,
    this.errorMessage,
  });

  const StatusChangeValidationResult.success()
    : isValid = true,
      errorMessage = null;

  const StatusChangeValidationResult.error(this.errorMessage) : isValid = false;
}

/// Валидатор для смены статуса заказа
class StatusChangeValidator {
  /// Валидировать смену статуса
  static StatusChangeValidationResult validateStatusChange({
    required int currentStatusId,
    required int newStatusId,
    required List<OrderStatusEntity> availableStatuses,
    String? note,
  }) {
    // Проверяем, что новый статус отличается от текущего
    if (currentStatusId == newStatusId) {
      return const StatusChangeValidationResult.error(
        'Новый статус должен отличаться от текущего',
      );
    }

    // Проверяем, что новый статус не является запрещенным
    if (newStatusId == 2 || newStatusId == 4) {
      return const StatusChangeValidationResult.error(
        'Этот статус недоступен для изменения',
      );
    }

    // Проверяем, что новый статус доступен
    final isStatusAvailable = availableStatuses.any(
      (status) => status.id == newStatusId,
    );

    if (!isStatusAvailable) {
      return const StatusChangeValidationResult.error(
        'Выбранный статус недоступен',
      );
    }

    // Проверяем длину комментария
    if (note != null && note.length > 500) {
      return const StatusChangeValidationResult.error(
        'Комментарий не должен превышать 500 символов',
      );
    }

    return const StatusChangeValidationResult.success();
  }

  /// Проверить, можно ли сменить статус
  static bool canChangeStatus({
    required int currentStatusId,
    required List<OrderStatusEntity> availableStatuses,
  }) {
    return availableStatuses.any(
      (status) =>
          status.id != currentStatusId &&
          status.id != 2 && // "Принято в работу"
          status.id != 4, // "Завершено"
    );
  }
}
