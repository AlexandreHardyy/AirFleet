import 'package:dio/dio.dart';
import 'package:frontend/models/rating.dart';

import 'dio.dart';

class RatingService {
  static Future<Rating?> getRatingByUserIDAndStatus(String status) async {
    try {
      final response = await dioApi.get("/ratings/status/$status");

      if (response.statusCode == 404) {
        return null;
      }

      return Rating.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
          'Something went wrong during rating retrieval: ${e.response}');
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  static Future<Rating> updateRating(int ratingId, UpdateRatingRequest ratingRequest) async {
    try {
      final response = await dioApi.put("/ratings/$ratingId", data: ratingRequest.toJson());

      return Rating.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Something went wrong during rating update: ${e.response}');
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  static Future<List<Rating>> getAllRatings(Map<String, String>? filters) async {
    try {
      final response = await dioApi.get("/ratings", queryParameters: filters);

      if (response.data == null) {
        return [];
      }

      List<dynamic> data = response.data;
      return data.map((json) => Rating.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Something went wrong during rating retrieval: ${e.response}');
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }
}