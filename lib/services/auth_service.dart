import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api.dart';

class AuthService {
  final storage = const FlutterSecureStorage();

  /// Login with email or phone number
  Future<Map<String, dynamic>> login(String login, String password) async {
    try {
      print('🔵 Attempting login to: ${ApiConfig.baseUrl}/login');
      print('🔵 Login: $login');
      
      final stopwatch = Stopwatch()..start();
      
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/login"),
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({
          "login": login, // Can be email or phone
          "password": password,
        }),
      ).timeout(
        const Duration(seconds: 20), // Increased timeout to 20 seconds
        onTimeout: () {
          stopwatch.stop();
          print('❌ Request timed out after ${stopwatch.elapsedMilliseconds}ms');
          throw Exception('Connection timeout. Please check your internet connection.');
        },
      );

      stopwatch.stop();
      print('✅ Response received in ${stopwatch.elapsedMilliseconds}ms');
      print('✅ Status code: ${response.statusCode}');
      print('✅ Response body: ${response.body}');

      final data = jsonDecode(response.body);

      // Handle successful login (200)
      if (response.statusCode == 200 && data["token"] != null) {
        await storage.write(key: "token", value: data["token"]);
        await storage.write(key: "user_id", value: data["user"]["id"].toString());
        print('✅ Token saved successfully');
      }

      // Handle unverified account (403) - return it so UI can handle it
      if (response.statusCode == 403 && data["needs_verification"] == true) {
        print('⚠️ Account needs verification');
        return {
          "status": response.statusCode,
          "data": data,
          "needs_verification": true,
        };
      }

      return {
        "status": response.statusCode,
        "data": data,
      };
    } catch (e) {
      print('❌ Login error: $e');
      
      // Handle network errors, timeouts, etc.
      String errorMessage = "خطأ في الاتصال";
      
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Connection refused')) {
        errorMessage = "لا يمكن الاتصال بالخادم. تأكد من تشغيل الخادم";
      } else if (e.toString().contains('timeout')) {
        errorMessage = "انتهت مهلة الاتصال. تحقق من اتصالك بالإنترنت";
      } else if (e.toString().contains('Failed host lookup')) {
        errorMessage = "لا يمكن الوصول إلى الخادم. تحقق من عنوان الخادم";
      } else {
        errorMessage = "خطأ: ${e.toString()}";
      }

      return {
        "status": 0, // 0 indicates network/connection error
        "data": {
          "message": errorMessage,
          "error": e.toString(),
        },
      };
    }
  }

  /// Register new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    required int age,
    required String gender,
    required String phone,
    required String verificationMethod, // 'email' or 'phone'
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/register"),
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "password_confirmation": passwordConfirmation,
          "role": role,
          "age": age,
          "gender": gender,
          "phone": phone,
          "verification_method": verificationMethod,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout. Please check your internet connection.');
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data["user_id"] != null) {
        await storage.write(key: "user_id", value: data["user_id"].toString());
      }

      return {
        "status": response.statusCode,
        "data": data,
      };
    } catch (e) {
      String errorMessage = "خطأ في الاتصال";
      
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Connection refused')) {
        errorMessage = "لا يمكن الاتصال بالخادم. تأكد من تشغيل الخادم";
      } else if (e.toString().contains('timeout')) {
        errorMessage = "انتهت مهلة الاتصال. تحقق من اتصالك بالإنترنت";
      }

      return {
        "status": 0,
        "data": {
          "message": errorMessage,
          "error": e.toString(),
        },
      };
    }
  }

  /// Verify user account with code
  Future<Map<String, dynamic>> verify(String userId, String verificationCode) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/verify"),
      headers: {"Content-Type": "application/json", "Accept": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "verification_code": verificationCode,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data["token"] != null) {
      await storage.write(key: "token", value: data["token"]);
      await storage.write(key: "user_id", value: data["user"]["id"].toString());
    }

    return {
      "status": response.statusCode,
      "data": data,
    };
  }

  /// Resend verification code
  Future<Map<String, dynamic>> resendVerification(String userId) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/resend-verification"),
      headers: {"Content-Type": "application/json", "Accept": "application/json"},
      body: jsonEncode({
        "user_id": userId,
      }),
    );

    final data = jsonDecode(response.body);

    return {
      "status": response.statusCode,
      "data": data,
    };
  }

  /// Logout user
  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        await http.post(
          Uri.parse("${ApiConfig.baseUrl}/logout"),
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        );
      } catch (e) {
        // Ignore errors on logout
      }
    }
    await storage.delete(key: "token");
    await storage.delete(key: "user_id");
  }

  Future<String?> getToken() async {
    return await storage.read(key: "token");
  }

  Future<String?> getUserId() async {
    return await storage.read(key: "user_id");
  }
}
