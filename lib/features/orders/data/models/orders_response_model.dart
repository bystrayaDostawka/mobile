import '../../../../shared/utils/order_status_utils.dart';

/// Модель ответа API для получения списка заявок
class OrdersResponseModel {
  final List<OrderModel> orders;

  const OrdersResponseModel({required this.orders});

  factory OrdersResponseModel.fromJson(List<dynamic> json) {
    return OrdersResponseModel(
      orders: json.map((order) => OrderModel.fromJson(order)).toList(),
    );
  }

  List<dynamic> toJson() {
    return orders.map((order) => order.toJson()).toList();
  }
}

/// Модель заявки
class OrderModel {
  final int id;
  final String orderNumber;
  final int bankId;
  final String product;
  final String name;
  final String surname;
  final String patronymic;
  final String phone;
  final String address;
  final String deliveryAt;
  final String? deliveredAt;
  final String? deliveryTimeRange;
  final int courierId;
  final int orderStatusId;
  final String? note;
  final String? declinedReason;
  final String createdAt;
  final String updatedAt;
  final BankModel bank;
  final CourierModel courier;
  final int commentsCount;
  final int uncompletedCommentsCount;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.bankId,
    required this.product,
    required this.name,
    required this.surname,
    required this.patronymic,
    required this.phone,
    required this.address,
    required this.deliveryAt,
    this.deliveredAt,
    this.deliveryTimeRange,
    required this.courierId,
    required this.orderStatusId,
    this.note,
    this.declinedReason,
    required this.createdAt,
    required this.updatedAt,
    required this.bank,
    required this.courier,
    this.commentsCount = 0,
    this.uncompletedCommentsCount = 0,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String,
      bankId: json['bank_id'] as int,
      product: json['product'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      patronymic: json['patronymic'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      deliveryAt: json['delivery_at'] as String,
      deliveredAt: json['delivered_at'] as String?,
      deliveryTimeRange: json['delivery_time_range'] as String?,
      courierId: json['courier_id'] as int,
      orderStatusId: json['order_status_id'] as int,
      note: json['note'] as String?,
      declinedReason: json['declined_reason'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      bank: BankModel.fromJson(json['bank'] as Map<String, dynamic>),
      courier: CourierModel.fromJson(json['courier'] as Map<String, dynamic>),
      commentsCount: json['comments_count'] as int? ?? 0,
      uncompletedCommentsCount: json['uncompleted_comments_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'bank_id': bankId,
      'product': product,
      'name': name,
      'surname': surname,
      'patronymic': patronymic,
      'phone': phone,
      'address': address,
      'delivery_at': deliveryAt,
      'delivered_at': deliveredAt,
      'delivery_time_range': deliveryTimeRange,
      'courier_id': courierId,
      'order_status_id': orderStatusId,
      'note': note,
      'declined_reason': declinedReason,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'bank': bank.toJson(),
      'courier': courier.toJson(),
      'comments_count': commentsCount,
      'uncompleted_comments_count': uncompletedCommentsCount,
    };
  }

  /// Полное имя клиента
  String get fullName => '$surname $name $patronymic';

  /// Статус заявки на русском
  String get statusDisplayName =>
      OrderStatusUtils.getStatusDisplayName(orderStatusId);
}

/// Модель банка
class BankModel {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String? orderPrefix;
  final String createdAt;
  final String updatedAt;

  const BankModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.orderPrefix,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      orderPrefix: json['order_prefix'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'order_prefix': orderPrefix,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

/// Модель курьера
class CourierModel {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;

  const CourierModel({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
  });

  factory CourierModel.fromJson(Map<String, dynamic> json) {
    return CourierModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      emailVerifiedAt: json['email_verified_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
    };
  }
}
