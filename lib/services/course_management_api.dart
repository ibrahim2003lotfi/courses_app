import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import 'auth_service.dart';

class CourseManagementApi {
  final AuthService _authService = AuthService();

  // Enroll in a course
  Future<Map<String, dynamic>> enrollInCourse(String courseId) async {
    try {
      final token = await _authService.getToken();
      final userId = await _authService.getUserId(); // Get user ID
      
      if (token == null || userId == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/courses/$courseId/enroll'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Id': userId, // Send user ID in header
        },
      );

      print('📚 Enroll API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 409) {
        return {'success': false, 'message': 'Already enrolled in this course'};
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Please login to enroll'};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to enroll'};
      }
    } catch (e) {
      print('❌ Error enrolling in course: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Get user's enrolled courses
  Future<Map<String, dynamic>> getEnrolledCourses() async {
    try {
      final token = await _authService.getToken();
      final userId = await _authService.getUserId();
      
      if (token == null || userId == null) {
        return {'success': false, 'message': 'Not authenticated', 'courses': []};
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/my/enrolled-courses'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'X-User-Id': userId,
        },
      );

      print('📚 Get Enrolled Courses API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'courses': data['courses'] ?? [],
          'total': data['total'] ?? 0,
        };
      } else {
        return {'success': false, 'message': 'Failed to load courses', 'courses': []};
      }
    } catch (e) {
      print('❌ Error getting enrolled courses: $e');
      return {'success': false, 'message': 'Network error: $e', 'courses': []};
    }
  }
}
