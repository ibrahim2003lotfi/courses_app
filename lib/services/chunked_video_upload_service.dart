import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import 'auth_service.dart';

class ChunkedVideoUploadService {
  final AuthService _auth = AuthService();
  final int chunkSize = 1024 * 1024; // 1MB chunks

  /// Upload video using chunked approach - works with php artisan serve
  Future<Map<String, dynamic>> uploadVideoChunked({
    required String courseId,
    required String lessonId,
    required File videoFile,
    Function(int uploaded, int total)? onProgress,
  }) async {
    try {
      final userId = await _auth.getUserId();
      final token = await _auth.getToken();

      print('🟡 [ChunkedUpload] Starting chunked upload...');
      print('🟡 [ChunkedUpload] File: ${videoFile.path}');
      print('🟡 [ChunkedUpload] File size: ${await videoFile.length()} bytes');

      // Step 1: Initialize upload
      final initResponse = await _initUpload(courseId, lessonId, userId, token);
      if (initResponse['success'] != true) {
        return initResponse;
      }

      final uploadId = initResponse['upload_id'];
      final serverChunkSize = (initResponse['chunk_size'] ?? chunkSize) as int;

      print('🟡 [ChunkedUpload] Upload ID: $uploadId');
      print('🟡 [ChunkedUpload] Chunk size: $serverChunkSize');

      // Step 2: Read file and split into chunks
      final fileBytes = await videoFile.readAsBytes();
      final totalSize = fileBytes.length;
      final chunks = <Uint8List>[];

      for (int i = 0; i < totalSize; i += serverChunkSize) {
        final end = (i + serverChunkSize < totalSize) ? i + serverChunkSize : totalSize;
        chunks.add(Uint8List.sublistView(fileBytes, i, end as int));
      }

      print('🟡 [ChunkedUpload] Total chunks: ${chunks.length}');

      // Step 3: Upload each chunk
      for (int i = 0; i < chunks.length; i++) {
        print('🟡 [ChunkedUpload] Uploading chunk ${i + 1}/${chunks.length}...');

        final chunkResponse = await _uploadChunk(
          uploadId: uploadId,
          chunkIndex: i,
          chunkData: chunks[i],
          userId: userId,
          token: token,
        );

        if (chunkResponse['success'] != true) {
          print('🔴 [ChunkedUpload] Chunk ${i + 1} failed: ${chunkResponse['message']}');
          return chunkResponse;
        }

        if (onProgress != null) {
          onProgress(i + 1, chunks.length);
        }
      }

      print('🟡 [ChunkedUpload] All chunks uploaded, finalizing...');

      // Step 4: Finalize upload
      final filename = videoFile.path.split('/').last;
      return await _finalizeUpload(
        courseId: courseId,
        lessonId: lessonId,
        uploadId: uploadId,
        filename: filename,
        totalChunks: chunks.length,
        userId: userId,
        token: token,
      );

    } catch (e, stackTrace) {
      print('🔴 [ChunkedUpload] Error: $e');
      print('🔴 [ChunkedUpload] Stack: $stackTrace');
      return {
        'success': false,
        'error': 'upload_error',
        'message': 'Failed to upload video: $e',
      };
    }
  }

  Future<Map<String, dynamic>> _initUpload(
    String courseId,
    String lessonId,
    String? userId,
    String? token,
  ) async {
    final uri = Uri.parse(
      "${ApiConfig.baseUrl}/instructor/courses/$courseId/lessons/$lessonId/video-chunked/init",
    );

    final response = await http.post(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        if (userId != null) 'X-User-Id': userId,
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 30));

    if (response.body.isEmpty) {
      return {
        'success': false,
        'error': 'empty_response',
        'message': 'Server returned empty response',
      };
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _uploadChunk({
    required String uploadId,
    required int chunkIndex,
    required Uint8List chunkData,
    required String? userId,
    required String? token,
  }) async {
    final uri = Uri.parse(
      "${ApiConfig.baseUrl}/upload-chunk/$uploadId/$chunkIndex",
    );

    final request = http.MultipartRequest('POST', uri);

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Accept'] = 'application/json';
    if (userId != null) {
      request.headers['X-User-Id'] = userId;
    }

    // Add chunk as file
    request.files.add(
      http.MultipartFile.fromBytes(
        'chunk',
        chunkData,
        filename: 'chunk_$chunkIndex.bin',
      ),
    );

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 60),
    );

    final response = await http.Response.fromStream(streamedResponse);

    if (response.body.isEmpty) {
      return {
        'success': false,
        'error': 'empty_response',
        'message': 'Server returned empty response for chunk $chunkIndex',
      };
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _finalizeUpload({
    required String courseId,
    required String lessonId,
    required String uploadId,
    required String filename,
    required int totalChunks,
    required String? userId,
    required String? token,
  }) async {
    final uri = Uri.parse(
      "${ApiConfig.baseUrl}/instructor/courses/$courseId/lessons/$lessonId/video-chunked/finalize",
    );

    final response = await http.post(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        if (userId != null) 'X-User-Id': userId,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'upload_id': uploadId,
        'filename': filename,
        'total_chunks': totalChunks,
      }),
    ).timeout(const Duration(seconds: 60));

    if (response.body.isEmpty) {
      return {
        'success': false,
        'error': 'empty_response',
        'message': 'Server returned empty response during finalization',
      };
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
