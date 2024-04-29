import 'package:dio/dio.dart';
import 'package:frontend/services/dio.dart';

class UserService {
  Future<Map<String, dynamic>> register(
      String email, String firstName, String lastName, String password) async {
    try {
      final response = await dioApi.post(
        '/users',
        data: {
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'password': password,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );

      return response.data;
    } catch (error) {
      if (error is DioException) {
        return error.response?.data;
      } else {
        throw Exception('Failed to login: $error');
      }
    }
  }

  Future<Map<String, dynamic>> registerPilot(
      String email,
      String firstName,
      String lastName,
      String password,
      String idCardPath,
      String drivingLicencePath) async {
    try {
      final formData = FormData.fromMap({
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'password': password,
        'id_card': await MultipartFile.fromFile(idCardPath),
        'driving_licence': await MultipartFile.fromFile(drivingLicencePath)
      });

      final response = await dioApi.post(
        '/users/pilot',
        data: formData,
      );

      return response.data;
    } catch (error) {
      if (error is DioException) {
        return error.response?.data ?? { 'message': error.message };
      } else {
        throw Exception('Failed to register pilot: $error');
      }
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await dioApi.post(
        '/users/login',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );

      return response.data;
    } catch (error) {
      if (error is DioException) {
        return error.response?.data;
      } else {
        throw Exception('Failed to login: $error');
      }
    }
  }
}
