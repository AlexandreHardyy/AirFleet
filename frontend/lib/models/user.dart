class User {
  int id;
  String email;
  String firstName;
  String lastName;
  String role;
  String createdAt;
  String updatedAt;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        email = json['email'] as String,
        firstName = json['first_name'] as String,
        lastName = json['last_name'] as String,
        role = json['role'] as String,
        createdAt = json['created_at'] as String,
        updatedAt = json['updated_at'] as String;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'created_at': createdAt,
      'updated_at': updatedAt
    };
  }
}
