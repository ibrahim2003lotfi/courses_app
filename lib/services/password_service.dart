import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api.dart';

class PasswordService {
  /// Step 1: Request password reset code (email or phone)
  Future<Map<String, dynamic>> requestReset(String login) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/password/forgot'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'login': login,
        }),
      );

      final data = jsonDecode(response.body);

      return {
        'status': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {
        'status': 0,
        'data': {
          'message': 'خطأ في الاتصال بالخادم',
          'error': e.toString(),
        },
      };
    }
  }

  /// Step 2: Verify reset code (optional, used for step-by-step UI)
  Future<Map<String, dynamic>> verifyCode(String userId, String code) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/password/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'code': code,
        }),
      );

      final data = jsonDecode(response.body);

      return {
        'status': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {
        'status': 0,
        'data': {
          'message': 'خطأ في الاتصال بالخادم',
          'error': e.toString(),
        },
      };
    }
  }

  /// Step 3: Reset password with code
  Future<Map<String, dynamic>> resetPassword({
    required String userId,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/password/reset'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'code': code,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final data = jsonDecode(response.body);

      return {
        'status': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {
        'status': 0,
        'data': {
          'message': 'خطأ في الاتصال بالخادم',
          'error': e.toString(),
        },
      };
    }
  }
}








