import 'package:dio/dio.dart';
import 'package:frontend/models/flight.dart';

import 'dio.dart';

class FlightService {
  static Future<Flight> createFlight(Flight flight) async {
    try {
      final response = await dioApi.post("/flights", data: flight.toJson());

      return Flight.fromJson(response.data);
    }  catch (error) {
      if (error is DioException) {
        return error.response?.data;
      } else {
        throw Exception('Failed to create a flight: $error');
      }
    }
  }
}