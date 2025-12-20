import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api.dart';
import 'auth_service.dart';

class HomeApi {
  final AuthService _auth = AuthService();

  Future<Map<String, dynamic>> getHome() async {
    final token = await _auth.getToken();

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/v1/home"),
      headers: {
        if (token != null) "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}













