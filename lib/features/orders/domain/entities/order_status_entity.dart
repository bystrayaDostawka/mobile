import 'package:equatable/equatable.dart';

/// Entity для статуса заказа
class OrderStatusEntity extends Equatable {
  const OrderStatusEntity({
    required this.id,
    required this.title,
    required this.color,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String title;
  final String color;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [id, title, color, createdAt, updatedAt];
}
