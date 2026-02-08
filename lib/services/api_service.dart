import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api.dart';

class ApiService {
  static final storage = const FlutterSecureStorage();

  /// GET request with authentication
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final token = await storage.read(key: "token");
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}$endpoint"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      
      return {
        "success": response.statusCode >= 200 && response.statusCode < 300,
        "status": response.statusCode,
        "data": data,
        "message": data["message"] ?? "",
      };
    } catch (e) {
      print('API GET Error: $e');
      return {
        "success": false,
        "status": 0,
        "data": null,
        "message": "Connection error: ${e.toString()}",
      };
    }
  }

  /// POST request with authentication
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final token = await storage.read(key: "token");
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}$endpoint"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));

      final responseData = jsonDecode(response.body);
      
      return {
        "success": response.statusCode >= 200 && response.statusCode < 300,
        "status": response.statusCode,
        "data": responseData,
        "message": responseData["message"] ?? "",
      };
    } catch (e) {
      print('API POST Error: $e');
      return {
        "success": false,
        "status": 0,
        "data": null,
        "message": "Connection error: ${e.toString()}",
      };
    }
  }

  /// PUT request with authentication
  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final token = await storage.read(key: "token");
      final response = await http.put(
        Uri.parse("${ApiConfig.baseUrl}$endpoint"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));

      final responseData = jsonDecode(response.body);
      
      return {
        "success": response.statusCode >= 200 && response.statusCode < 300,
        "status": response.statusCode,
        "data": responseData,
        "message": responseData["message"] ?? "",
      };
    } catch (e) {
      print('API PUT Error: $e');
      return {
        "success": false,
        "status": 0,
        "data": null,
        "message": "Connection error: ${e.toString()}",
      };
    }
  }

  /// DELETE request with authentication
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final token = await storage.read(key: "token");
      final response = await http.delete(
        Uri.parse("${ApiConfig.baseUrl}$endpoint"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 15));

      final responseData = jsonDecode(response.body);
      
      return {
        "success": response.statusCode >= 200 && response.statusCode < 300,
        "status": response.statusCode,
        "data": responseData,
        "message": responseData["message"] ?? "",
      };
    } catch (e) {
      print('API DELETE Error: $e');
      return {
        "success": false,
        "status": 0,
        "data": null,
        "message": "Connection error: ${e.toString()}",
      };
    }
  }
}
