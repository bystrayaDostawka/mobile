import 'dart:convert';

import '../usecase/usecase.dart';

/// Базовый интерфейс для всех репозиториев
abstract class Repository {
  const Repository();
}

/// Интерфейс для репозитория авторизации
abstract class AuthRepository extends Repository {
  /// Авторизация с email и паролем
  Future<Result<AuthLoginResponseModel>> login(String email, String password);

  /// Проверка авторизации
  Future<Result<bool>> isAuthenticated();

  /// Выход из системы
  Future<Result<void>> logout();

  /// Получение роли пользователя
  Future<Result<String>> getUserRole();

  /// Сохранение токена авторизации
  Future<Result<void>> saveAuthToken(String token);

  /// Получение токена авторизации
  Future<Result<String?>> getAuthToken();
}

/// Интерфейс для репозитория заявок
abstract class OrdersRepository extends Repository {
  /// Получение списка заявок
  Future<Result<List<dynamic>>> getOrders();

  /// Получение заявки по ID
  Future<Result<dynamic>> getOrderById(String id);

  /// Обновление статуса заявки
  Future<Result<void>> updateOrderStatus(String orderId, String status);

  /// Отправка фото заявки
  Future<Result<void>> uploadOrderPhoto(String orderId, String photoPath);
}

/// Интерфейс для репозитория уведомлений
abstract class NotificationsRepository extends Repository {
  /// Получение уведомлений
  Future<Result<List<dynamic>>> getNotifications();

  /// Отметка уведомления как прочитанного
  Future<Result<void>> markAsRead(String notificationId);

  /// Подписка на push уведомления
  Future<Result<void>> subscribeToPushNotifications();
}

/// Интерфейс для репозитория профиля
abstract class ProfileRepository extends Repository {
  /// Получение профиля пользователя
  Future<Result<dynamic>> getProfile();

  /// Обновление профиля
  Future<Result<void>> updateProfile(Map<String, dynamic> data);
}

// To parse this JSON data, do
//
//     final authLoginResponseModel = authLoginResponseModelFromJson(jsonString);

AuthLoginResponseModel authLoginResponseModelFromJson(String str) =>
    AuthLoginResponseModel.fromJson(json.decode(str));

String authLoginResponseModelToJson(AuthLoginResponseModel data) =>
    json.encode(data.toJson());

class AuthLoginResponseModel {
  String? token;
  UserModel? user;

  AuthLoginResponseModel({this.token, this.user});

  factory AuthLoginResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthLoginResponseModel(
        token: json["token"],
        user: json["user"] == null ? null : UserModel.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {"token": token, "user": user?.toJson()};
}

class UserModel {
  int? id;
  String? name;
  String? email;
  dynamic emailVerifiedAt;
  dynamic phone;
  String? role;
  dynamic bankId;
  bool? isActive;
  dynamic note;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<RoleModel>? roles;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.phone,
    this.role,
    this.bankId,
    this.isActive,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    emailVerifiedAt: json["email_verified_at"],
    phone: json["phone"],
    role: json["role"],
    bankId: json["bank_id"],
    isActive: json["is_active"],
    note: json["note"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    roles: json["roles"] == null
        ? []
        : List<RoleModel>.from(
            json["roles"]!.map((x) => RoleModel.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "email_verified_at": emailVerifiedAt,
    "phone": phone,
    "role": role,
    "bank_id": bankId,
    "is_active": isActive,
    "note": note,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "roles": roles == null
        ? []
        : List<dynamic>.from(roles!.map((x) => x.toJson())),
  };
}

class RoleModel {
  int? id;
  String? name;
  String? guardName;
  DateTime? createdAt;
  DateTime? updatedAt;
  PivotModel? pivot;

  RoleModel({
    this.id,
    this.name,
    this.guardName,
    this.createdAt,
    this.updatedAt,
    this.pivot,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) => RoleModel(
    id: json["id"],
    name: json["name"],
    guardName: json["guard_name"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    pivot: json["pivot"] == null ? null : PivotModel.fromJson(json["pivot"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "guard_name": guardName,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "pivot": pivot?.toJson(),
  };
}

class PivotModel {
  String? modelType;
  int? modelId;
  int? roleId;

  PivotModel({this.modelType, this.modelId, this.roleId});

  factory PivotModel.fromJson(Map<String, dynamic> json) => PivotModel(
    modelType: json["model_type"],
    modelId: json["model_id"],
    roleId: json["role_id"],
  );

  Map<String, dynamic> toJson() => {
    "model_type": modelType,
    "model_id": modelId,
    "role_id": roleId,
  };
}
