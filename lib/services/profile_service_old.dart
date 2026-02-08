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
    print(
      '🔵 Token available: ${token != null ? "YES (${token.substring(0, 10)}...)" : "NO"}',
    );

    if (token == null) {
      print('❌ ERROR: No token found!');
      return {
        'status': 401,
        'data': {'message': 'Not authenticated'},
        'message': 'Not authenticated',
      };
    }

    try {
      print('🟡 Creating HTTP client...');
      final client = http.Client();

      print('🟡 Sending request to: ${ApiConfig.baseUrl}$path');
      final response = await client
          .get(
            Uri.parse('${ApiConfig.baseUrl}$path'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Connection': 'keep-alive',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('🟢 Response status: ${response.statusCode}');
      print('🟢 Response headers: ${response.headers}');
      print('🟢 Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          return {'status': 200, 'data': data, 'message': 'Success'};
        } catch (e) {
          print('❌ JSON Parse Error: $e');
          return {
            'status': 500,
            'message': 'Error parsing server response',
            'error': e.toString(),
          };
        }
      } else {
        return {
          'status': response.statusCode,
          'message': 'Error: ${response.statusCode}',
          'error': response.body,
        };
      }
    } on http.ClientException catch (e) {
      print('❌ HTTP Client Exception: ${e.message}');
      print('❌ URI: ${e.uri}');
      return {
        'status': 0,
        'message': 'Connection error: ${e.message}',
        'error': e.toString(),
        'errorType': 'ClientException',
      };
    } on SocketException catch (e) {
      print('❌ Socket Exception: $e');
      return {
        'status': 0,
        'message': 'Network error: Please check your internet connection',
        'error': e.toString(),
        'errorType': 'SocketException',
      };
    } on TimeoutException catch (e) {
      print('❌ Timeout Exception: $e');
      return {
        'status': 0,
        'message': 'Request timed out',
        'error': e.toString(),
        'errorType': 'TimeoutException',
      };
    } catch (e) {
      print('❌ Unexpected Error: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return {
        'status': 0,
        'message': 'An unexpected error occurred',
        'error': e.toString(),
        'errorType': 'UnexpectedError',
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

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
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

      return {'status': response['status'], 'data': data, 'message': 'Success'};
    }

    return {
      'status': response['status'] ?? 0,
      'message': response['message'] ?? 'Failed to load profile',
      'error': response['error'] ?? 'Unknown error',
      'errorType': response['errorType'] ?? 'UnknownError',
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
        body: {'learning_state': learningState, 'interests': interests},
      );

      if (response['status'] == 200) {
        return {
          'status': 200,
          'message': 'Onboarding preferences saved successfully',
          'data': response['data'],
        };
      }

      return {
        'status': response['status'] ?? 500,
        'message': response['message'] ?? 'Failed to save preferences',
        'error': response['error'],
      };
    } catch (e) {
      print('❌ Error saving onboarding: $e');
      return {
        'status': 0,
        'message': 'Failed to save preferences',
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
    print(
      '🔵 Updating profile with data: name=$name, email=$email, phone=$phone, bio=$bio',
    );

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
        'error': 'Not authenticated',
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
            : (data?['message'] ?? 'فشل رفع الصورة'),
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
