import 'package:frontend/models/user.dart';

class Rating {
  int id;
  num? rating;
  String? comment;
  String status;
  int pilotId;
  User pilot;
  String createdAt;
  String updatedAt;

  Rating({
    required this.id,
    this.rating,
    this.comment,
    required this.status,
    required this.pilotId,
    required this.pilot,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      rating: json['rating'],
      comment: json['comment'],
      status: json['status'],
      pilotId: json['pilot_id'],
      pilot: User.fromJson(json['pilot']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'comment': comment,
      'status': status,
      'pilot_id': pilotId,
      'pilot': pilot.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class UpdateRatingRequest {
  final num? rating;
  final String? comment;

  UpdateRatingRequest({
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
    };
  }
}