
class User {
  int id;
  String email;
  String firstName;
  String lastName;
  String role;
  bool isVerified;
  bool isPilotVerified;
  String createdAt;
  String updatedAt;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.isVerified,
    required this.isPilotVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        email = json['email'] as String,
        firstName = json['first_name'] as String,
        lastName = json['last_name'] as String,
        role = json['role'] as String,
        isVerified = json['is_verified'] != null ? json['is_verified'] as bool : false,
        isPilotVerified = json['is_pilot_verified'] != null ? json['is_pilot_verified'] as bool : false,
        createdAt = json['created_at'] as String,
        updatedAt = json['updated_at'] as String;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'is_verified': isVerified,
      'is_pilot_verified': isPilotVerified,
      'role': role,
      'created_at': createdAt,
      'updated_at': updatedAt
    };
  }
}
