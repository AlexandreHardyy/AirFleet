import 'package:dio/dio.dart';
import 'package:frontend/models/message.dart';

import 'dio.dart';

class MessageService {
  static Future<List<Message>> getMessagesByFlightId(int flightId) async {
    try {
      final response = await dioApi.get("/messages/flight/$flightId");

      if (response.statusCode == 404) {
        return [];
      }

      List<dynamic> data = response.data;

      return data.map((json) => Message.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(
          'Something went wrong during messages retrieval: ${e.response}');
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }
}