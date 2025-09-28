// To parse this JSON data, do
//
//     final profileResponseModel = profileResponseModelFromJson(jsonString);

import 'dart:convert';
import '../../domain/entities/user_entity.dart';

ProfileResponseModel profileResponseModelFromJson(String str) =>
    ProfileResponseModel.fromJson(json.decode(str));

String profileResponseModelToJson(ProfileResponseModel data) =>
    json.encode(data.toJson());

class ProfileResponseModel {
  int? id;
  String? name;
  String? email;
  String? phone;
  bool? isActive;
  String? note;

  ProfileResponseModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.isActive,
    this.note,
  });

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) =>
      ProfileResponseModel(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        isActive: json["is_active"],
        note: json["note"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
    "is_active": isActive,
    "note": note,
  };

  /// Преобразование в доменную сущность
  UserEntity toEntity() => UserEntity(
    id: id ?? 0,
    name: name,
    email: email,
    phone: phone,
    note: note,
    isActive: isActive,
    role: 'courier', // По умолчанию для курьеров
  );
}
