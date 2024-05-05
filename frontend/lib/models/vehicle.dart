class Vehicle {
  final int id;
  final String matriculation;
  final String modelName;
  final int seat;
  final String type;
  final bool isVerified;
  final String createdAt;
  final String updatedAt;

  Vehicle({
    required this.id,
    required this.matriculation,
    required this.modelName,
    required this.seat,
    required this.type,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
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
}