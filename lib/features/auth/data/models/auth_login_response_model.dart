import '../../../profile/domain/entities/user_entity.dart';

/// Модель ответа от API для авторизации
class AuthLoginResponseModel {
  const AuthLoginResponseModel({this.token, this.user, this.message});

  final String? token;
  final UserModel? user;
  final String? message;

  factory AuthLoginResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthLoginResponseModel(
      token: json['token'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'user': user?.toJson(), 'message': message};
  }

  /// Преобразование в доменную сущность
  UserEntity? toEntity() => user?.toEntity();
}

/// Модель пользователя для API
class UserModel {
  const UserModel({required this.id, this.name, this.email, this.role});

  final int id;
  final String? name;
  final String? email;
  final String? role;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'role': role};
  }

  /// Преобразование в доменную сущность
  UserEntity toEntity() => UserEntity(
    id: id,
    name: name,
    email: email,
    phone: null, // В ответе авторизации нет телефона
    note: null, // В ответе авторизации нет заметки
    isActive: null, // В ответе авторизации нет статуса
    role: role,
  );
}
