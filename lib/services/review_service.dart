import 'dart:convert';
import 'api_client.dart';
import 'auth_service.dart';

class ReviewService {
  final ApiClient _client = ApiClient();
  final AuthService _authService = AuthService();

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

    // Get user ID for header
    final userId = await _authService.getUserId();
    final token = await _authService.getToken();
    
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (userId != null) 'X-User-Id': userId,
    };
    
    final response = await _client.postWithHeaders("/courses/$courseId/rate", body, headers);

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Get user's rating for a course
  Future<Map<String, dynamic>> getMyRating(String courseId) async {
    // Get user ID for header
    final userId = await _authService.getUserId();
    final token = await _authService.getToken();
    
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (userId != null) 'X-User-Id': userId,
    };
    
    final response = await _client.getWithHeaders("/courses/$courseId/my-rating", headers);

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
