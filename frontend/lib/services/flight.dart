import 'package:dio/dio.dart';
import 'package:frontend/models/flight.dart';

import 'dio.dart';

class FlightService {
  static Future<Flight> createFlight(CreateFlightRequest flightRequest) async {
    try {
      final response = await dioApi.post("/flights", data: flightRequest.toJson());

      return Flight.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Something went wrong during flight creation: ${e.response}');
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  static Future<Flight?> getCurrentFlight() async {
    try {
      final response = await dioApi.get("/flights/current");

      if (response.statusCode == 404) {
        return null;
      }

      return Flight.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Something went wrong during flight retrieval: ${e.response}');
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }
}