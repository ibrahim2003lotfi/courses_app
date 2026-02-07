import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api.dart';
import 'auth_service.dart';

class UniversityApi {
  final AuthService _auth = AuthService();

  Future<List<dynamic>> getUniversities() async {
    final token = await _auth.getToken();

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/v1/universities"),
      headers: {
        if (token != null) "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['data'] as List?) ?? [];
  }

  Future<List<dynamic>> getFaculties(String universityId) async {
    final token = await _auth.getToken();

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/v1/universities/$universityId/faculties"),
      headers: {
        if (token != null) "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['data'] as List?) ?? [];
  }

  Future<List<dynamic>> getFacultyCourses(
    String universityId,
    String facultyId,
  ) async {
    final token = await _auth.getToken();

    final response = await http.get(
      Uri.parse(
        "${ApiConfig.baseUrl}/v1/universities/$universityId/faculties/$facultyId/courses",
      ),
      headers: {
        if (token != null) "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['data'] as List?) ?? [];
  }
}















