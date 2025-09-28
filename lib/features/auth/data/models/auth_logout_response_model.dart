/// Модель ответа API для выхода из системы
class AuthLogoutResponseModel {
  final String? message;

  const AuthLogoutResponseModel({this.message});

  factory AuthLogoutResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthLogoutResponseModel(message: json["message"]);

  Map<String, dynamic> toJson() => {"message": message};
}
