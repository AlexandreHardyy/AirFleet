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
  Airport departure;
  Airport arrival;

  Flight({
    required this.id,
    required this.status,
    this.price,
    required this.departure,
    required this.arrival,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id'],
      status: json['status'],
      price: json['price'],
      departure: Airport.fromJson(json['departure']),
      arrival: Airport.fromJson(json['arrival']),
    );
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