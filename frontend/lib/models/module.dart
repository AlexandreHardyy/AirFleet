class Module {
  final int id;
  final String name;
  bool isEnabled;

  Module({
    required this.id,
    required this.name,
    required this.isEnabled,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'],
      name: json['name'],
      isEnabled: json['is_enabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_enabled': isEnabled,
    };
  }
}

class UpdateModuleRequest {
  final bool isEnabled;

  UpdateModuleRequest({
    required this.isEnabled,
  });

  Map<String, dynamic> toJson() {
    return {
      'is_enabled': isEnabled,
    };
  }
}