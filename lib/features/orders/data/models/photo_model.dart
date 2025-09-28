class PhotoModel {
  int? id;
  int? orderId;
  String? filePath;
  String? url;
  DateTime? createdAt;
  DateTime? updatedAt;

  PhotoModel({
    this.id,
    this.orderId,
    this.filePath,
    this.url,
    this.createdAt,
    this.updatedAt,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) => PhotoModel(
    id: json["id"],
    orderId: json["order_id"],
    filePath: json["file_path"],
    url: json["url"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "file_path": filePath,
    "url": url,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
