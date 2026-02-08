import 'dart:convert';
import 'api_client.dart';

class ReviewService {
  final ApiClient _client = ApiClient();

  /// Rate and review a course
  Future<Map<String, dynamic>> rateCourse({
    required String courseId,
    required int rating,
    String? review,
  }) async {
    final body = {
      "rating": rating,
      if (review != null && review.isNotEmpty) "review": review,
    };

    final response = await _client.post("/courses/$courseId/rate", body);

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Get user's rating for a course
  Future<Map<String, dynamic>> getMyRating(String courseId) async {
    final response = await _client.get("/courses/$courseId/my-rating");

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Delete user's rating
  Future<Map<String, dynamic>> deleteRating(String courseId) async {
    final response = await _client.delete("/courses/$courseId/my-rating");

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Get all user's ratings
  Future<Map<String, dynamic>> getUserRatings() async {
    final response = await _client.get("/my-ratings");

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Get course rating (public)
  Future<Map<String, dynamic>> getCourseRating(String courseId) async {
    final response = await _client.get("/courses/$courseId/rating");

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
