import 'package:frontend/models/user.dart';

class Message {
  int id;
  String content;
  String createdAt;
  int userId;
  int flightId;
  User user;

  Message({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.userId,
    required this.flightId,
    required this.user,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      createdAt: json['created_at'],
      userId: json['user_id'],
      flightId: json['flight_id'],
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'created_at': createdAt,
      'user_id': userId,
      'flight_id': flightId,
      'user': user.toJson(),
    };
  }
}