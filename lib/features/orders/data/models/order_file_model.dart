class OrderFileModel {
  int? id;
  String? fileName;
  String? fileType;
  int? fileSize;
  String? formattedSize;
  String? url;
  UploaderModel? uploadedBy;
  DateTime? createdAt;

  OrderFileModel({
    this.id,
    this.fileName,
    this.fileType,
    this.fileSize,
    this.formattedSize,
    this.url,
    this.uploadedBy,
    this.createdAt,
  });

  factory OrderFileModel.fromJson(Map<String, dynamic> json) => OrderFileModel(
    id: json["id"],
    fileName: json["file_name"],
    fileType: json["file_type"],
    fileSize: json["file_size"],
    formattedSize: json["formatted_size"],
    url: json["url"],
    uploadedBy: json["uploaded_by"] == null 
        ? null 
        : UploaderModel.fromJson(json["uploaded_by"]),
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "file_name": fileName,
    "file_type": fileType,
    "file_size": fileSize,
    "formatted_size": formattedSize,
    "url": url,
    "uploaded_by": uploadedBy?.toJson(),
    "created_at": createdAt?.toIso8601String(),
  };
}

class UploaderModel {
  int? id;
  String? name;

  UploaderModel({
    this.id,
    this.name,
  });

  factory UploaderModel.fromJson(Map<String, dynamic> json) => UploaderModel(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
