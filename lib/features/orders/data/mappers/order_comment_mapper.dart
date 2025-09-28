import '../models/order_comment_model.dart';
import '../../domain/entities/order_comment_entity.dart';

class OrderCommentMapper {
  static OrderCommentEntity toEntity(OrderCommentModel model) {
    return OrderCommentEntity(
      id: model.id,
      orderId: model.orderId,
      comment: model.comment,
      isCompleted: model.isCompleted,
      completedAt: model.completedAt,
      createdAt: model.createdAt,
      user: OrderCommentUserMapper.toEntity(model.user),
      order: model.order != null ? OrderCommentOrderMapper.toEntity(model.order!) : null,
    );
  }

  static OrderCommentModel toModel(OrderCommentEntity entity) {
    return OrderCommentModel(
      id: entity.id,
      orderId: entity.orderId,
      comment: entity.comment,
      isCompleted: entity.isCompleted,
      completedAt: entity.completedAt,
      createdAt: entity.createdAt,
      user: OrderCommentUserMapper.toModel(entity.user),
      order: entity.order != null ? OrderCommentOrderMapper.toModel(entity.order!) : null,
    );
  }
}

class OrderCommentUserMapper {
  static OrderCommentUserEntity toEntity(OrderCommentUserModel model) {
    return OrderCommentUserEntity(
      id: model.id,
      name: model.name,
      role: model.role,
    );
  }

  static OrderCommentUserModel toModel(OrderCommentUserEntity entity) {
    return OrderCommentUserModel(
      id: entity.id,
      name: entity.name,
      role: entity.role,
    );
  }
}

class OrderCommentOrderMapper {
  static OrderCommentOrderEntity toEntity(OrderCommentOrderModel model) {
    return OrderCommentOrderEntity(
      id: model.id,
      orderNumber: model.orderNumber,
      bankName: model.bankName,
    );
  }

  static OrderCommentOrderModel toModel(OrderCommentOrderEntity entity) {
    return OrderCommentOrderModel(
      id: entity.id,
      orderNumber: entity.orderNumber,
      bankName: entity.bankName,
    );
  }
}
