class OrderCommentModel {
  final int id;
  final int orderId; // ID заказа (всегда доступен)
  final String comment;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final OrderCommentUserModel user;
  final OrderCommentOrderModel? order; // Информация о заказе (только для комментариев курьера)

  const OrderCommentModel({
    required this.id,
    required this.orderId,
    required this.comment,
    required this.isCompleted,
    this.completedAt,
    required this.createdAt,
    required this.user,
    this.order,
  });

  factory OrderCommentModel.fromJson(Map<String, dynamic> json) {
    return OrderCommentModel(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      comment: json['comment'] as String,
      isCompleted: json['is_completed'] as bool,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      user: OrderCommentUserModel.fromJson(json['user'] as Map<String, dynamic>),
      order: json['order'] != null 
          ? OrderCommentOrderModel.fromJson(json['order'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'comment': comment,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'user': user.toJson(),
      'order': order?.toJson(),
    };
  }

  OrderCommentModel copyWith({
    int? id,
    int? orderId,
    String? comment,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
    OrderCommentUserModel? user,
    OrderCommentOrderModel? order,
  }) {
    return OrderCommentModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      comment: comment ?? this.comment,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
      order: order ?? this.order,
    );
  }
}

class OrderCommentUserModel {
  final int id;
  final String name;
  final String role;

  const OrderCommentUserModel({
    required this.id,
    required this.name,
    required this.role,
  });

  factory OrderCommentUserModel.fromJson(Map<String, dynamic> json) {
    return OrderCommentUserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
    };
  }
}

class OrderCommentOrderModel {
  final int id;
  final String orderNumber;
  final String bankName;

  const OrderCommentOrderModel({
    required this.id,
    required this.orderNumber,
    required this.bankName,
  });

  factory OrderCommentOrderModel.fromJson(Map<String, dynamic> json) {
    return OrderCommentOrderModel(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String,
      bankName: json['bank_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'bank_name': bankName,
    };
  }
}
