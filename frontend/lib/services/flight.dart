import 'package:dio/dio.dart';
import 'package:frontend/models/flight.dart';
import 'package:frontend/services/position.dart';

import 'dio.dart';

class FlightService {
  static Future<List<Flight>?> getFlights(FlightFilters filters) async {
    try {
      final response = await dioApi.get("/flights", queryParameters: {
        if (filters.limit != null) 'limit': filters.limit,
        if (filters.offset != null) 'offset': filters.offset,
        if (filters.status != null) 'status': filters.status,
      });

      List<dynamic> data = response.data;
      return data.map((json) => Flight.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Something went wrong during flights retrieval: ${e.response}');
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

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

  static Future<List<Flight>?> getCurrentFlightRequests() async {
    final position = await determinePosition();
    try {
      final response = await dioApi.get("/flights/near-by?latitude=${position.latitude}&longitude=${position.longitude}&range=100");

      if (response.data == null) {
        return null;
      }

      List<dynamic> data = response.data;
      return data.map((json) => Flight.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Something went wrong during flight retrieval: ${e.response}');
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  static Future<List<Flight>> getFlightsHistory() async {
    try {
      final response = await dioApi.get("/flights/history");

      if (response.data == null) {
        return [];
      }

      List<dynamic> data = response.data;
      return data.map((json) => Flight.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Something went wrong during flight retrieval: ${e.response}');
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  static Future<Flight> getFlight(int flightId) async {
    try {
      final response = await dioApi.get("/flights/$flightId");

      return Flight.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Something went wrong during flight retrieval: ${e.response}');
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }
}

class FlightFilters {
  int? limit;
  int? offset;
  String? status;

  FlightFilters({this.limit, this.offset, this.status});
}
