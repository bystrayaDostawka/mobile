import 'package:equatable/equatable.dart';

class OrderFileEntity extends Equatable {
  const OrderFileEntity({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.formattedSize,
    required this.url,
    required this.uploadedBy,
    required this.createdAt,
  });

  final int id;
  final String fileName;
  final String fileType;
  final int fileSize;
  final String formattedSize;
  final String url;
  final UploaderEntity uploadedBy;
  final DateTime createdAt;

  @override
  List<Object> get props => [
        id,
        fileName,
        fileType,
        fileSize,
        formattedSize,
        url,
        uploadedBy,
        createdAt,
      ];
}

class UploaderEntity extends Equatable {
  const UploaderEntity({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  @override
  List<Object> get props => [id, name];
}
