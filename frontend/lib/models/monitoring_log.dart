class MonitoringLog {
  int id;
  String type;
  String content;

  String createdAt;
  String updatedAt;

  MonitoringLog({
    required this.id,
    required this.type,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  MonitoringLog.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        type = json['type'] as String,
        content = json['content'] as String,
        createdAt = json['created_at'] as String,
        updatedAt = json['updated_at'] as String;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'created_at': createdAt,
      'updated_at': updatedAt
    };
  }
}
