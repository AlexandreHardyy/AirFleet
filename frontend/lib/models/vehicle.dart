class Vehicle {
  final int? id;
  String matriculation;
  String modelName;
  int seat;
  String type;
  num cruiseSpeed;
  num cruiseAltitude;
  final bool? isVerified;
  bool? isSelected;
  final String? createdAt;
  final String? updatedAt;

  Vehicle({
    this.id,
    required this.matriculation,
    required this.modelName,
    required this.seat,
    required this.type,
    required this.cruiseSpeed,
    required this.cruiseAltitude,
    this.isVerified,
    this.isSelected,
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
      cruiseSpeed: json['cruise_speed'],
      cruiseAltitude: json['cruise_altitude'],
      isVerified: json['is_verified'],
      isSelected: json['is_selected'],
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
      'cruise_speed': cruiseSpeed,
      'cruise_altitude': cruiseAltitude,
      'is_verified': isVerified,
      'is_selected': isSelected,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}