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
}