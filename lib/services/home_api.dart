import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api.dart';
import 'auth_service.dart';

class HomeApi {
  final AuthService _auth = AuthService();

  Future<Map<String, dynamic>> getHome() async {
    print('🏠🏠 HOME API: Starting getHome() call');
    
    final token = await _auth.getToken();
    print('🏠🏠 HOME API: Token retrieved: ${token != null ? "YES" : "NO"}');

    // Use the original /v1/home endpoint
    final url = "${ApiConfig.baseUrl}/v1/home";
    print('🏠🏠 HOME API: About to call original /v1/home URL: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          if (token != null) "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      print('🏠🏠 HOME API: Response received - Status: ${response.statusCode}');
      print('🏠🏠 HOME API: Response body: ${response.body}');

      final result = jsonDecode(response.body) as Map<String, dynamic>;
      print('🏠🏠 HOME API: JSON decoded successfully');
      
      return result;
    } catch (e, stackTrace) {
      print('🏠🏠❌ HOME API ERROR: $e');
      print('🏠🏠❌ HOME API STACK TRACE: $stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getEnrolledCourses() async {
    print('📚📚 HOME API: Starting getEnrolledCourses() call');
    
    final token = await _auth.getToken();
    print('📚📚 HOME API: Token retrieved: ${token != null ? "YES" : "NO"}');

    final url = "${ApiConfig.baseUrl}/my/enrolled-courses";
    print('📚📚 HOME API: About to call URL: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          if (token != null) "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      print('📚📚 HOME API: Response received - Status: ${response.statusCode}');
      print('📚📚 HOME API: Response body: ${response.body}');

      final result = jsonDecode(response.body) as Map<String, dynamic>;
      print('📚📚 HOME API: JSON decoded successfully');
      
      return result;
    } catch (e, stackTrace) {
      print('📚📚❌ HOME API ERROR: $e');
      print('📚📚❌ HOME API STACK TRACE: $stackTrace');
      rethrow;
    }
  }
}
















