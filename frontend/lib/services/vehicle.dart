import 'package:dio/dio.dart';
import 'package:frontend/services/dio.dart';
import 'package:frontend/models/vehicle.dart';

class VehicleService {
  static Future<List<Vehicle>> getVehicles() async {
    try {
      final response = await dioApi.get("/vehicles");
      List<dynamic> data = response.data;
      return data.map((json) => Vehicle.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response?.statusCode == 404) {
          throw Exception('No vehicles found.');
        }
      }

      throw Exception('Something went wrong: $e');
    }
  }

  static Future<Vehicle> getVehicle(int vehicleId) async {
    try {
      final response = await dioApi.get("/vehicles/$vehicleId");
      dynamic data = response.data;
      return Vehicle.fromJson(data);
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response?.statusCode == 404) {
          throw Exception('No vehicles found.');
        }
      }
      throw Exception('Something went wrong: $e');
    }
  }

 /* Future<String> updateVehicle(Vehicle vehicle) async {
    try {
      final response = await dioApi.put("/vehicles/${vehicle.id}", data: vehicle.toJson());
      return response.data['message'];
    } on DioException catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  Future<String> deleteVehicle(int vehicleId) async {
    try {
      final response = await dioApi.delete("/vehicles/$vehicleId");
      return response.data['message'];
    } on DioException catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  Future<String> createVehicle(Vehicle vehicle) async {
    try {
      final response = await dioApi.post("/vehicles", data: vehicle.toJson());
      return response.data['message'];
    } on DioException catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }*/
}