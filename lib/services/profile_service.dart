import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../config/api.dart';
import 'auth_service.dart';

class ProfileService {
  final AuthService _auth = AuthService();

  Future<Map<String, dynamic>> _authorizedGet(String path) async {
    final token = await _auth.getToken();
    
    print('🔵 Profile Service - Making GET request to: $path');
    print('🔵 Full URL: ${ApiConfig.baseUrl}$path');
    print('🔵 Token available: ${token != null ? "YES (${token.substring(0, 10)}...)" : "NO"}');
    
    if (token == null) {
      print('❌ ERROR: No token found!');
      return {
        'status': 401,
        'data': {'message': 'Not authenticated'},
        'message': 'No authentication token',
        'error': 'Not authenticated'
      };
    }

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$path');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('🔵 Response status: ${response.statusCode}');
      print('🔵 Response body: ${response.body}');

      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;

      return {
        'status': response.statusCode,
        'data': data,
        'message': (response.statusCode == 200)
          ? (data?['message'] ?? 'Success')
          : (data?['message'] ?? 'Request failed'),
      };
    } catch (e) {
      print('❌ Unexpected Error: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return {
        'status': 0,
        'message': 'An unexpected error occurred',
        'error': e.toString(),
        'errorType': 'UnexpectedError'
      };
    }
  }

  Future<Map<String, dynamic>> _authorizedRequest(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final token = await _auth.getToken();
    print('🔵 _authorizedRequest: $method $path');
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$path');
      late http.Response response;

      final headers = <String, String>{
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      switch (method.toUpperCase()) {
        case 'GET':
          print('🔵 Making GET request to $uri');
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          print('🔵 Making POST request to $uri');
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          print('🔵 Making PUT request to $uri');
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          print('🔵 Making DELETE request to $uri');
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      print('🔵 Response status: ${response.statusCode}');
      print('🔵 Response body: ${response.body}');

      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;

      return {
        'status': response.statusCode,
        'data': data,
        'message': (response.statusCode >= 200 && response.statusCode < 300)
            ? (data?['message'] ?? 'Success')
            : (data?['message'] ?? 'Request failed'),
      };
    } catch (e) {
      print('❌ Request error: $e');
      return {
        'status': 0,
        'data': null,
        'message': 'Network error occurred',
        'error': e.toString(),
      };
    }
  }

  /// Get current user profile
  Future<Map<String, dynamic>> getMe() async {
    print('🔵 Getting user profile...');
    final response = await _authorizedGet('/me');
    
    print('🔵 Profile API Response Status: ${response['status']}');
    if (response['error'] != null) {
      print('❌ Profile API Error: ${response['error']}');
      return response;
    }
    
    if (response['status'] == 200 && response['data'] != null) {
      final data = response['data'] as Map<String, dynamic>;
      print('✅ Profile data loaded successfully');
      print('🔵 User data keys: ${data['user']?.keys}');
      print('🔵 Profile data exists: ${data['profile'] != null}');
      print('🔵 Stats data: ${data['stats']}');
      
      return {
        'status': response['status'],
        'data': data,
        'message': 'Success'
      };
    }
    
    return {
      'status': response['status'] ?? 0,
      'message': response['message'] ?? 'Failed to load profile',
      'error': response['error'] ?? 'Unknown error',
      'errorType': response['errorType'] ?? 'UnknownError'
    };
  }

  /// Save onboarding preferences
  Future<Map<String, dynamic>> saveOnboarding({
    required String learningState,
    required List<String> interests,
  }) async {
    try {
      final response = await _authorizedRequest(
        'POST',
        '/me/onboarding',
        body: {
          'learning_state': learningState,
          'interests': interests,
        },
      );

      return {
        'status': response['status'],
        'data': response['data'],
        'message': response['status'] == 200 ? 'Onboarding saved successfully' : response['message'],
      };
    } catch (e) {
      return {
        'status': 0,
        'data': null,
        'message': 'Failed to save onboarding preferences',
        'error': e.toString(),
      };
    }
  }

  /// Update basic profile info (name, email, phone, bio)
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? bio,
  }) async {
    print('🔵 Updating profile with data: name=$name, email=$email, phone=$phone, bio=$bio');
    
    final body = <String, dynamic>{};
    if (name != null && name.isNotEmpty) body['name'] = name;
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
    if (bio != null && bio.isNotEmpty) body['bio'] = bio;

    print('🔵 Request body: $body');
    
    return _authorizedRequest('PUT', '/me', body: body);
  }

  /// Upload avatar image
  Future<Map<String, dynamic>> uploadAvatar(File avatarFile) async {
    print('🔵 Uploading avatar: ${avatarFile.path}');
    final token = await _auth.getToken();
    
    if (token == null) {
      return {
        'status': 401,
        'message': 'No authentication token',
        'error': 'Not authenticated'
      };
    }

    try {
      print('🔵 Creating multipart request for avatar upload');
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/me/avatar'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Check file size (max 2MB)
      final fileSize = await avatarFile.length();
      print('🔵 Avatar file size: $fileSize bytes');
      
      if (fileSize > 2 * 1024 * 1024) {
        return {
          'status': 413,
          'data': null,
          'message': 'حجم الصورة كبير جداً (الحد الأقصى 2MB)',
        };
      }

      // Add avatar file
      request.files.add(
        await http.MultipartFile.fromPath('avatar', avatarFile.path),
      );

      print('🔵 Sending avatar upload request...');
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      
      print('🔵 Avatar upload response: ${response.statusCode}');
      print('🔵 Response body: ${response.body}');

      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;

      return {
        'status': response.statusCode,
        'data': data,
        'message': (response.statusCode == 200)
          ? (data?['message'] ?? 'تم رفع الصورة بنجاح')
          : (data?['message'] ?? 'فشل رفع الصورة')
      };
    } catch (e) {
      print('❌ Avatar upload error: $e');
      return {
        'status': 0,
        'data': null,
        'message': 'خطأ في رفع الصورة',
        'error': e.toString(),
      };
    }
  }

  /// Upload cover image
  Future<Map<String, dynamic>> uploadCover(File coverFile) async {
    print('🔵 Uploading cover: ${coverFile.path}');
    final token = await _auth.getToken();
    
    if (token == null) {
      return {
        'status': 401,
        'message': 'No authentication token',
        'error': 'Not authenticated'
      };
    }

    try {
      print('🔵 Creating multipart request for cover upload');
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/me/cover'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Check file size (max 2MB)
      final fileSize = await coverFile.length();
      print('🔵 Cover file size: $fileSize bytes');
      
      if (fileSize > 2 * 1024 * 1024) {
        return {
          'status': 413,
          'data': null,
          'message': 'حجم الصورة كبير جداً (الحد الأقصى 2MB)',
        };
      }

      // Add cover file
      request.files.add(
        await http.MultipartFile.fromPath('cover', coverFile.path),
      );

      print('🔵 Sending cover upload request...');
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      
      print('🔵 Cover upload response: ${response.statusCode}');
      print('🔵 Response body: ${response.body}');

      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;

      return {
        'status': response.statusCode,
        'data': data,
        'message': (response.statusCode == 200)
          ? (data?['message'] ?? 'تم رفع صورة الغلاف بنجاح')
          : (data?['message'] ?? 'فشل رفع صورة الغلاف')
      };
    } catch (e) {
      print('❌ Cover upload error: $e');
      return {
        'status': 0,
        'data': null,
        'message': 'خطأ في رفع صورة الغلاف',
        'error': e.toString(),
      };
    }
  }

  /// Delete current account
  Future<Map<String, dynamic>> deleteAccount() async {
    print('🔵 Deleting user account...');
    print('🔵 About to call DELETE /me endpoint');
    final result = await _authorizedRequest('DELETE', '/me');
    
    print('🔵 Delete account response status: ${result['status']}');
    print('🔵 Delete account response: ${result['data']}');
    
    if (result['status'] == 200) {
      print('🔵 Account deleted successfully, clearing local token');
      // Clear local token without calling logout API (token already deleted)
      await _auth.clearToken();
    }
    return result;
  }
}

