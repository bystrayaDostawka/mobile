import 'dart:convert';

OrderStatusModel orderStatusModelFromJson(String str) =>
    OrderStatusModel.fromJson(json.decode(str));

String orderStatusModelToJson(OrderStatusModel data) =>
    json.encode(data.toJson());

class OrderStatusModel {
  final int id;
  final String title;
  final String color;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderStatusModel({
    required this.id,
    required this.title,
    required this.color,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderStatusModel.fromJson(Map<String, dynamic> json) =>
      OrderStatusModel(
        id: json["id"],
        title: json["title"],
        color: json["color"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "color": color,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
