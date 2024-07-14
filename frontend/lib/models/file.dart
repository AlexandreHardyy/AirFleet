class File {
  int id;
  String type;
  String path;
  String createdAt;
  String updatedAt;

  File({
    required this.id,
    required this.type,
    required this.path,
    required this.createdAt,
    required this.updatedAt,
  });

  factory File.fromJson(Map<String, dynamic> json) {
    return File(
      id: json['id'],
      type: json['type'],
      path: json['path'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}