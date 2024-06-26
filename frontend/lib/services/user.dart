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
        return {
          'message': 'an error occurred.'
        };
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
        throw Exception('Failed to getCurrent user: $error');
      }
    }
  }

  static Future logOut() async {
    await UserStore.removeToken();
  }

  static Future<Response> createUser(Map<String, dynamic> data) async {
    try {
      final Response response = await dioApi.post(
        '/users',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            // 'Access-Control-Allow-Origin': '*',
          },
        ),
      );
      return response;
    } catch (error) {
      throw Exception('Failed to create user: $error');
    }
  }

  static Future<List<User>> getUsers() async {
    try {
      final response = await dioApi.get(
        '/users',
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );

      final List<dynamic> data = response.data;
      return data.map((user) => User.fromJson(user)).toList();
    } catch (error) {
      throw Exception('Failed to get users: $error');
    }
  }

  static Future<void> update(int id, Map<String, dynamic> data) async {
    try {
      await dioApi.put('/users/$id', data: data);
    } catch (error) {
      if (error is DioException) {
        throw Exception('Failed to update user: ${error.message}');
      } else {
        throw Exception('Unexpected error: $error');
      }
    }
  }

  static Future<void> delete(int id) async {
    try {
      await dioApi.delete('/users/$id');
    } catch (error) {
      if (error is DioException) {
        throw Exception('Failed to delete user: ${error.message}');
      } else {
        throw Exception('Unexpected error: $error');
      }
    }
  }
}
