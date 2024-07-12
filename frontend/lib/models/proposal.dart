import 'package:frontend/models/flight.dart';
import 'package:frontend/models/user.dart';

class Proposal {
  int id;
  String departureTime;
  String description;
  int availableSeats;
  Flight flight;

  Proposal({
    required this.id,
    required this.departureTime,
    required this.description,
    required this.availableSeats,
    required this.flight,
  });

  factory Proposal.fromJson(Map<String, dynamic> json) {
    return Proposal(
      id: json['id'],
      departureTime: json['departure_time'],
      description: json['description'],
      availableSeats: json['available_seats'],
      flight: Flight.fromJson(json['flight']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'departure_time': description,
      'description': description,
      'available_seats': availableSeats,
      'flight': flight.toJson(),
    };
  }
}