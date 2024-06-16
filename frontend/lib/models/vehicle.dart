class Vehicle {
  final int? id;
  String matriculation;
  String modelName;
  int seat;
  String type;
  bool? isVerified;
  final String? createdAt;
  final String? updatedAt;

  Vehicle({
    this.id,
    required this.matriculation,
    required this.modelName,
    required this.seat,
    required this.type,
    this.isVerified,
    this.createdAt,
    this.updatedAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      matriculation: json['matriculation'],
      modelName: json['model_name'],
      seat: json['seat'],
      type: json['type'],
      isVerified: json['is_verified'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  toJson() {
    return {
      'id': id,
      'matriculation': matriculation,
      'model_name': modelName,
      'seat': seat,
      'type': type,
      'is_verified': isVerified,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
