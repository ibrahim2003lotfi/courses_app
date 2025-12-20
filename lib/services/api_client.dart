import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../config/api.dart';

class ApiClient {
  final AuthService _auth = AuthService();

  Future<http.Response> get(String endpoint) async {
    final token = await _auth.getToken();

    return http.get(
      Uri.parse("${ApiConfig.baseUrl}$endpoint"),
      headers: {
        if (token != null) "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );
  }

  Future<http.Response> post(String endpoint, Map body) async {
    final token = await _auth.getToken();

    return http.post(
      Uri.parse("${ApiConfig.baseUrl}$endpoint"),
      headers: {
        if (token != null) "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> put(String endpoint, Map body) async {
    final token = await _auth.getToken();

    return http.put(
      Uri.parse("${ApiConfig.baseUrl}$endpoint"),
      headers: {
        if (token != null) "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String endpoint) async {
    final token = await _auth.getToken();

    return http.delete(
      Uri.parse("${ApiConfig.baseUrl}$endpoint"),
      headers: {
        if (token != null) "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );
  }
}
