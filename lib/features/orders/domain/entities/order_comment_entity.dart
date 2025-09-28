class OrderCommentEntity {
  final int id;
  final int orderId; // ID заказа (всегда доступен)
  final String comment;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final OrderCommentUserEntity user;
  final OrderCommentOrderEntity? order; // Информация о заказе (только для комментариев курьера)

  const OrderCommentEntity({
    required this.id,
    required this.orderId,
    required this.comment,
    required this.isCompleted,
    this.completedAt,
    required this.createdAt,
    required this.user,
    this.order,
  });
}

class OrderCommentUserEntity {
  final int id;
  final String name;
  final String role;

  const OrderCommentUserEntity({
    required this.id,
    required this.name,
    required this.role,
  });
}

class OrderCommentOrderEntity {
  final int id;
  final String orderNumber;
  final String bankName;

  const OrderCommentOrderEntity({
    required this.id,
    required this.orderNumber,
    required this.bankName,
  });
}
