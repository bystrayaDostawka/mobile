import 'dart:io';

/// Локальная фотография для предварительного просмотра
class LocalPhotoEntity {
  final String id;
  final String path;
  final DateTime createdAt;
  final bool isUploading;
  final String? uploadError;

  const LocalPhotoEntity({
    required this.id,
    required this.path,
    required this.createdAt,
    this.isUploading = false,
    this.uploadError,
  });

  /// Создать локальную фотографию из файла
  factory LocalPhotoEntity.fromFile(File file) {
    return LocalPhotoEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      path: file.path,
      createdAt: DateTime.now(),
    );
  }

  /// Создать копию с обновленными полями
  LocalPhotoEntity copyWith({
    String? id,
    String? path,
    DateTime? createdAt,
    bool? isUploading,
    String? uploadError,
  }) {
    return LocalPhotoEntity(
      id: id ?? this.id,
      path: path ?? this.path,
      createdAt: createdAt ?? this.createdAt,
      isUploading: isUploading ?? this.isUploading,
      uploadError: uploadError ?? this.uploadError,
    );
  }

  /// Получить файл
  File get file => File(path);

  /// Проверить существование файла
  Future<bool> get exists => file.exists();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocalPhotoEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'LocalPhotoEntity(id: $id, path: $path, createdAt: $createdAt, isUploading: $isUploading)';
  }
}
