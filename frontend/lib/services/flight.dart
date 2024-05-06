import 'package:dio/dio.dart';
import 'package:frontend/models/flight.dart';

import 'dio.dart';

class FlightService {
  static Future<Flight> createFlight(Flight flight) async {
    try {
      final response = await dioApi.post("/flights", data: flight.toJson());

      return Flight.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Something went wrong during flight creation: ${e.response}');
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }
}