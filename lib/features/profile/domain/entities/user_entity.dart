import 'package:equatable/equatable.dart';

/// Доменная сущность пользователя
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.note,
    this.isActive,
    this.role,
  });

  final int id;
  final String? name;
  final String? email;
  final String? phone;
  final String? note;
  final bool? isActive;
  final String? role;

  @override
  List<Object?> get props => [id, name, email, phone, note, isActive, role];

  /// Создание копии с изменениями
  UserEntity copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? note,
    bool? isActive,
    String? role,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      note: note ?? this.note,
      isActive: isActive ?? this.isActive,
      role: role ?? this.role,
    );
  }
}
