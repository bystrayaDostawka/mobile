// To parse this JSON data, do
//
//     final updateOrderResponseModel = updateOrderResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:bystraya_dostawka/features/orders/data/models/photo_model.dart';

UpdateOrderResponseModel updateOrderResponseModelFromJson(String str) =>
    UpdateOrderResponseModel.fromJson(json.decode(str));

String updateOrderResponseModelToJson(UpdateOrderResponseModel data) =>
    json.encode(data.toJson());

class UpdateOrderResponseModel {
  int? id;
  int? bankId;
  String? product;
  String? name;
  String? surname;
  String? patronymic;
  String? phone;
  String? address;
  DateTime? deliveryAt;
  DateTime? deliveredAt;
  int? courierId;
  int? orderStatusId;
  String? note;
  String? declinedReason;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<PhotoModel>? photos;

  UpdateOrderResponseModel({
    this.id,
    this.bankId,
    this.product,
    this.name,
    this.surname,
    this.patronymic,
    this.phone,
    this.address,
    this.deliveryAt,
    this.deliveredAt,
    this.courierId,
    this.orderStatusId,
    this.note,
    this.declinedReason,
    this.createdAt,
    this.updatedAt,
    this.photos,
  });

  factory UpdateOrderResponseModel.fromJson(Map<String, dynamic> json) =>
      UpdateOrderResponseModel(
        id: json["id"],
        bankId: json["bank_id"],
        product: json["product"],
        name: json["name"],
        surname: json["surname"],
        patronymic: json["patronymic"],
        phone: json["phone"],
        address: json["address"],
        deliveryAt: json["delivery_at"] == null
            ? null
            : DateTime.parse(json["delivery_at"]),
        deliveredAt: json["delivered_at"] == null
            ? null
            : DateTime.parse(json["delivered_at"]),
        courierId: json["courier_id"],
        orderStatusId: json["order_status_id"],
        note: json["note"],
        declinedReason: json["declined_reason"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        photos: json["photos"] == null
            ? []
            : List<PhotoModel>.from(
                json["photos"]!.map((x) => PhotoModel.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "bank_id": bankId,
    "product": product,
    "name": name,
    "surname": surname,
    "patronymic": patronymic,
    "phone": phone,
    "address": address,
    "delivery_at":
        "${deliveryAt!.year.toString().padLeft(4, '0')}-${deliveryAt!.month.toString().padLeft(2, '0')}-${deliveryAt!.day.toString().padLeft(2, '0')}",
    "delivered_at": deliveredAt?.toIso8601String().split('T')[0],
    "courier_id": courierId,
    "order_status_id": orderStatusId,
    "note": note,
    "declined_reason": declinedReason,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "photos": photos == null
        ? []
        : List<dynamic>.from(photos!.map((x) => x.toJson())),
  };
}
