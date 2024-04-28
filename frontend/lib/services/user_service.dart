import 'package:dio/dio.dart';

class UserService {
  final String baseUrl = "http://localhost:3001/create"; // Remplacez par l'URL de votre API
  final Dio _dio = Dio();

  Future<Response> createUser(Map<String, dynamic> data) async {
    try {
      final Response response = await _dio.post(
        '$baseUrl/users',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }
}