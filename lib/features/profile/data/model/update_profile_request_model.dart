// To parse this JSON data, do
//
//     final updateProfileRequestModel = updateProfileRequestModelFromJson(jsonString);

import 'dart:convert';

UpdateProfileRequestModel updateProfileRequestModelFromJson(String str) =>
    UpdateProfileRequestModel.fromJson(json.decode(str));

String updateProfileRequestModelToJson(UpdateProfileRequestModel data) =>
    json.encode(data.toJson());

class UpdateProfileRequestModel {
  String? name;
  String? phone;
  String? note;

  UpdateProfileRequestModel({this.name, this.phone, this.note});

  factory UpdateProfileRequestModel.fromJson(Map<String, dynamic> json) =>
      UpdateProfileRequestModel(
        name: json["name"],
        phone: json["phone"],
        note: json["note"],
      );

  Map<String, dynamic> toJson() => {"name": name, "phone": phone, "note": note};

  /// Создание модели из существующих данных профиля
  factory UpdateProfileRequestModel.fromProfile({
    String? name,
    String? phone,
    String? note,
  }) {
    return UpdateProfileRequestModel(name: name, phone: phone, note: note);
  }

  /// Проверка, есть ли изменения в данных
  bool hasChanges(UpdateProfileRequestModel other) {
    return name != other.name || phone != other.phone || note != other.note;
  }

  /// Создание копии с изменениями
  UpdateProfileRequestModel copyWith({
    String? name,
    String? phone,
    String? note,
  }) {
    return UpdateProfileRequestModel(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      note: note ?? this.note,
    );
  }
}
