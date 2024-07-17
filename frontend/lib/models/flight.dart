import 'package:frontend/models/user.dart';
import 'package:frontend/models/vehicle.dart';
import 'dart:math';

class CreateFlightRequest {
  final Airport departure;
  final Airport arrival;

  CreateFlightRequest({
    required this.departure,
    required this.arrival,
  });

  Map<String, dynamic> toJson() {
    return {
      'departure': departure.toJson(),
      'arrival': arrival.toJson(),
    };
  }
}

class Flight {
  int id;
  String status;
  num? price;
  int? pilotId;
  int? vehicleId;
  Airport departure;
  Airport arrival;
  User? pilot;
  Vehicle? vehicle;
  List<User>? users;
  String? createdAt;
  String? updatedAt;

  Flight({
    required this.id,
    required this.status,
    this.price,
    this.pilotId,
    this.vehicleId,
    required this.departure,
    required this.arrival,
    this.pilot,
    this.vehicle,
    this.users,
    this.createdAt,
    this.updatedAt,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id'],
      status: json['status'],
      price: json['price'],
      pilotId: json['pilot_id'],
      vehicleId: json['vehicle_id'],
      departure: Airport.fromJson(json['departure']),
      arrival: Airport.fromJson(json['arrival']),
      pilot: json['pilot'] != null ? User.fromJson(json['pilot']) : null,
      vehicle: json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null,
      users: json['users'] != null ? (json['users'] as List).map((user) => User.fromJson(user)).toList() : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'price': price,
      'pilotId': pilotId,
      'vehicleId': vehicleId,
      'departure': departure.toJson(),
      'arrival': arrival.toJson(),
      'pilot': pilot?.toJson(),
      'vehicle': vehicle?.toJson(),
      'users': users?.map((user) => user.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class Airport {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  Airport({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude
  });

  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
      name: json['name'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}