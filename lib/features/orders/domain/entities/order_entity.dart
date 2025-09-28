import 'package:equatable/equatable.dart';
import '../../../../shared/utils/order_status_utils.dart';

/// Базовая сущность заказа с общими полями
abstract class BaseOrderEntity extends Equatable {
  final int id;
  final int bankId;
  final String product;
  final String name;
  final String surname;
  final String patronymic;
  final String phone;
  final String address;
  final int orderStatusId;
  final String? note;
  final String? declinedReason;

  const BaseOrderEntity({
    required this.id,
    required this.bankId,
    required this.product,
    required this.name,
    required this.surname,
    required this.patronymic,
    required this.phone,
    required this.address,
    required this.orderStatusId,
    this.note,
    this.declinedReason,
  });

  /// Полное имя клиента
  String get fullName => '$surname $name $patronymic';

  /// Статус заявки на русском
  String get statusDisplayName =>
      OrderStatusUtils.getStatusDisplayName(orderStatusId);

  @override
  List<Object?> get props => [
    id,
    bankId,
    product,
    name,
    surname,
    patronymic,
    phone,
    address,
    orderStatusId,
    note,
    declinedReason,
  ];
}

/// Сущность заказа для списка (краткая информация)
class OrderEntity extends BaseOrderEntity {
  final String orderNumber;
  final DateTime deliveryAt;
  final DateTime? deliveredAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String bankName;
  final String courierName;
  final int commentsCount;
  final int uncompletedCommentsCount;

  const OrderEntity({
    required super.id,
    required super.bankId,
    required super.product,
    required super.name,
    required super.surname,
    required super.patronymic,
    required super.phone,
    required super.address,
    required super.orderStatusId,
    super.note,
    super.declinedReason,
    required this.orderNumber,
    required this.deliveryAt,
    this.deliveredAt,
    required this.createdAt,
    required this.updatedAt,
    required this.bankName,
    required this.courierName,
    this.commentsCount = 0,
    this.uncompletedCommentsCount = 0,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    orderNumber,
    deliveryAt,
    deliveredAt,
    createdAt,
    updatedAt,
    bankName,
    courierName,
    commentsCount,
    uncompletedCommentsCount,
  ];
}

/// Сущность заказа с полными деталями
class OrderDetailsEntity extends BaseOrderEntity {
  final DateTime? deliveryAt;
  final DateTime? deliveredAt; // Исправлена опечатка
  final int? courierId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String bankName;
  final List<PhotoEntity> photos;
  final String? courierComment;

  const OrderDetailsEntity({
    required super.id,
    required super.bankId,
    required super.product,
    required super.name,
    required super.surname,
    required super.patronymic,
    required super.phone,
    required super.address,
    required super.orderStatusId,
    super.note,
    super.declinedReason,
    this.deliveryAt,
    this.deliveredAt,
    this.courierId,
    this.createdAt,
    this.updatedAt,
    required this.bankName,
    required this.photos,
    this.courierComment,
  });

  /// Форматированная дата доставки
  String get formattedDeliveryAt {
    if (deliveryAt == null) return 'Не указана';
    return '${deliveryAt!.day.toString().padLeft(2, '0')}.${deliveryAt!.month.toString().padLeft(2, '0')}.${deliveryAt!.year}, ${deliveryAt!.hour.toString().padLeft(2, '0')}:${deliveryAt!.minute.toString().padLeft(2, '0')}:${deliveryAt!.second.toString().padLeft(2, '0')}';
  }

  /// Форматированная дата завершения
  String get formattedDeliveredAt {
    if (deliveredAt == null) return 'Не завершено';
    return '${deliveredAt!.day.toString().padLeft(2, '0')}.${deliveredAt!.month.toString().padLeft(2, '0')}.${deliveredAt!.year}, ${deliveredAt!.hour.toString().padLeft(2, '0')}:${deliveredAt!.minute.toString().padLeft(2, '0')}:${deliveredAt!.second.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
    ...super.props,
    deliveryAt,
    deliveredAt,
    courierId,
    createdAt,
    updatedAt,
    bankName,
    photos,
    courierComment,
  ];
}

/// Сущность фотографии
class PhotoEntity extends Equatable {
  final int id;
  final int orderId;
  final String? filePath;
  final String? url;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PhotoEntity({
    required this.id,
    required this.orderId,
    this.filePath,
    this.url,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, orderId, filePath, url, createdAt, updatedAt];
}
