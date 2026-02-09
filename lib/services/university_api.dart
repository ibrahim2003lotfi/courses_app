import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api.dart';
import 'auth_service.dart';

class UniversityApi {
  final AuthService _auth = AuthService();

  Future<List<dynamic>> getUniversities() async {
    try {
      final token = await _auth.getToken();

      final response = await http
          .get(
            Uri.parse("${ApiConfig.baseUrl}/v1/universities"),
            headers: {
              if (token != null) "Authorization": "Bearer $token",
              "Accept": "application/json",
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Request timeout after 30 seconds');
            },
          );

      if (response.statusCode != 200) {
        throw Exception('Failed to load universities: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['data'] as List?) ?? [];
    } catch (e) {
      if (e is TimeoutException) {
        rethrow;
      }
      throw Exception('Network error: Unable to connect to server');
    }
  }

  Future<List<dynamic>> getFaculties(String universityId) async {
    // If universityId is empty (e.g. static university with no backend ID),
    // avoid calling the API and return an empty list instead.
    if (universityId.isEmpty) {
      return [];
    }

    try {
      final token = await _auth.getToken();

      final response = await http
          .get(
            Uri.parse(
              "${ApiConfig.baseUrl}/v1/universities/$universityId/faculties",
            ),
            headers: {
              if (token != null) "Authorization": "Bearer $token",
              "Accept": "application/json",
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Request timeout after 30 seconds');
            },
          );

      if (response.statusCode != 200) {
        throw Exception('Failed to load faculties: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['data'] as List?) ?? [];
    } catch (e) {
      if (e is TimeoutException) {
        rethrow;
      }
      throw Exception('Network error: Unable to connect to server');
    }
  }

  Future<List<dynamic>> getFacultyCourses(
    String universityId,
    String facultyId,
  ) async {
    // If IDs are empty, skip network call completely.
    if (universityId.isEmpty || facultyId.isEmpty) {
      return [];
    }

    try {
      final token = await _auth.getToken();

      final response = await http
          .get(
            Uri.parse(
              "${ApiConfig.baseUrl}/v1/universities/$universityId/faculties/$facultyId/courses",
            ),
            headers: {
              if (token != null) "Authorization": "Bearer $token",
              "Accept": "application/json",
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Request timeout after 30 seconds');
            },
          );

      if (response.statusCode != 200) {
        throw Exception('Failed to load courses: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['data'] as List?) ?? [];
    } catch (e) {
      if (e is TimeoutException) {
        rethrow;
      }
      throw Exception('Network error: Unable to connect to server');
    }
  }
}
