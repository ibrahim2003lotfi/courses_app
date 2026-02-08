import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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

  /// Post with multipart form data for file uploads
  Future<http.Response> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    Map<String, File>? files,
  }) async {
    final token = await _auth.getToken();
    final uri = Uri.parse("${ApiConfig.baseUrl}$endpoint");

    print('🔵 [ApiClient] Starting multipart POST to: $uri');
    print('🔵 [ApiClient] Token exists: ${token != null}');
    print('🔵 [ApiClient] Fields: ${fields.keys.join(", ")}');
    print('🔵 [ApiClient] Files: ${files?.keys.join(", ") ?? "none"}');

    // 🟢 If no files, use regular POST instead of multipart
    if (files == null || files.isEmpty) {
      print('🟢 [ApiClient] No files, using regular POST');
      return http.post(
        uri,
        headers: {
          if (token != null) "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(fields),
      );
    }

    final request = http.MultipartRequest('POST', uri);

    // Add authorization header
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Accept'] = 'application/json';

    // Add fields
    request.fields.addAll(fields);

    // Add files
    for (var entry in files.entries) {
      print('🔵 [ApiClient] Adding file: ${entry.key} = ${entry.value.path}');
      final fileStream = http.ByteStream(entry.value.openRead());
      final length = await entry.value.length();
      print('🔵 [ApiClient] File size: $length bytes');

      final multipartFile = http.MultipartFile(
        entry.key,
        fileStream,
        length,
        filename: path.basename(entry.value.path),
        contentType: _getMediaType(entry.value.path),
      );
      request.files.add(multipartFile);
    }

    print('🔵 [ApiClient] Sending request...');
    try {
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          print('🔴 [ApiClient] Request timed out after 60 seconds');
          throw Exception('Request timed out');
        },
      );
      print('🟢 [ApiClient] Response received: ${streamedResponse.statusCode}');

      final response = await http.Response.fromStream(streamedResponse);
      print('🟢 [ApiClient] Response body length: ${response.body.length}');
      return response;
    } catch (e) {
      print('🔴 [ApiClient] Error during request: $e');
      rethrow;
    }
  }

  MediaType _getMediaType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'mp4':
        return MediaType('video', 'mp4');
      case 'mov':
        return MediaType('video', 'quicktime');
      case 'avi':
        return MediaType('video', 'x-msvideo');
      case 'pdf':
        return MediaType('application', 'pdf');
      default:
        return MediaType('application', 'octet-stream');
    }
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
