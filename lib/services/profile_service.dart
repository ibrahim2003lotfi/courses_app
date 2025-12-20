import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api.dart';
import 'auth_service.dart';

class ProfileService {
  final AuthService _auth = AuthService();

  Future<Map<String, dynamic>> _authorizedGet(String path) async {
    final token = await _auth.getToken();
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
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

  Future<Map<String, dynamic>> _authorizedRequest(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final token = await _auth.getToken();
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$path');
      late http.Response response;

      final headers = <String, String>{
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final encodedBody = body != null ? jsonEncode(body) : null;

      switch (method.toUpperCase()) {
        case 'POST':
          response = await http.post(uri, headers: headers, body: encodedBody);
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: encodedBody);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers, body: encodedBody);
          break;
        default:
          throw Exception('Unsupported method $method');
      }

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

  /// Get current user profile + stats
  Future<Map<String, dynamic>> getMe() async {
    return _authorizedGet('/me');
  }

  /// Update basic profile info (name, email, phone, bio)
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? bio,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    if (phone != null) body['phone'] = phone;
    if (bio != null) body['bio'] = bio;

    return _authorizedRequest('PUT', '/me', body: body);
  }

  /// Save onboarding preferences
  Future<Map<String, dynamic>> saveOnboarding({
    required String learningState,
    required List<String> interests,
  }) async {
    return _authorizedRequest(
      'POST',
      '/me/onboarding',
      body: {
        'learning_state': learningState,
        'interests': interests,
      },
    );
  }

  /// Upload avatar image
  Future<Map<String, dynamic>> uploadAvatar(File avatarFile) async {
    final token = await _auth.getToken();
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/me/avatar'),
      );

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      request.files.add(
        await http.MultipartFile.fromPath('avatar', avatarFile.path),
      );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final data = jsonDecode(response.body);

      return {
        'status': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {
        'status': 0,
        'data': {
          'message': 'خطأ في رفع الصورة',
          'error': e.toString(),
        },
      };
    }
  }

  /// Delete current account
  Future<Map<String, dynamic>> deleteAccount() async {
    final result = await _authorizedRequest('DELETE', '/me');
    if (result['status'] == 200) {
      // Clear local token
      await _auth.logout();
    }
    return result;
  }
}








