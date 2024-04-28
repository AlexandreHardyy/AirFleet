import 'package:dio/dio.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/dio.dart';
import 'package:frontend/storage/user.dart';

class UserService {
  static Future<Map<String, dynamic>> register(
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

  static Future<Map<String, dynamic>> registerPilot(
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

  static Future<Map<String, dynamic>> login(String email, String password) async {
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

  static Future<User?> getCurrentUser() async {
    try {
      final response = await dioApi.get(
        '/users/me',
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        return null;
      }
      return User.fromJson(response.data);
    } catch (error) {
      if (error is DioException) {
        return null;
      } else {
        throw Exception('Failed to getcurrent user: $error');
      }
    }
  }

  static Future logOut() async {
    await UserStore.removeToken();
  }
}
