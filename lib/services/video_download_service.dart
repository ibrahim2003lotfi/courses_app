import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for downloading and managing offline videos
class VideoDownloadService {
  static final VideoDownloadService _instance = VideoDownloadService._internal();
  factory VideoDownloadService() => _instance;
  VideoDownloadService._internal();

  final Dio _dio = Dio();
  final Map<String, double> _downloadProgress = {};
  final Map<String, bool> _downloading = {};

  /// Get the directory where videos are stored
  Future<Directory> get _videosDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final videosDir = Directory('${appDir.path}/downloaded_videos');
    if (!await videosDir.exists()) {
      await videosDir.create(recursive: true);
    }
    return videosDir;
  }

  /// Generate a unique file name for a lesson video
  String _generateFileName(String courseId, String lessonId) {
    return '${courseId}_${lessonId}.mp4';
  }

  /// Get the local file path for a downloaded video
  Future<String?> getLocalVideoPath(String courseId, String lessonId) async {
    final videosDir = await _videosDirectory;
    final fileName = _generateFileName(courseId, lessonId);
    final file = File('${videosDir.path}/$fileName');
    
    if (await file.exists()) {
      return file.path;
    }
    return null;
  }

  /// Check if a video is downloaded
  Future<bool> isVideoDownloaded(String courseId, String lessonId) async {
    final path = await getLocalVideoPath(courseId, lessonId);
    return path != null;
  }

  /// Get download progress (0.0 to 1.0)
  double getDownloadProgress(String courseId, String lessonId) {
    final key = '${courseId}_$lessonId';
    return _downloadProgress[key] ?? 0.0;
  }

  /// Check if a video is currently downloading
  bool isDownloading(String courseId, String lessonId) {
    final key = '${courseId}_$lessonId';
    return _downloading[key] ?? false;
  }

  /// Download a video
  Future<bool> downloadVideo({
    required String videoUrl,
    required String courseId,
    required String lessonId,
    required String lessonTitle,
    Function(double progress)? onProgress,
  }) async {
    final key = '${courseId}_$lessonId';
    
    if (_downloading[key] == true) {
      return false; // Already downloading
    }

    try {
      _downloading[key] = true;
      _downloadProgress[key] = 0.0;

      final videosDir = await _videosDirectory;
      final fileName = _generateFileName(courseId, lessonId);
      final savePath = '${videosDir.path}/$fileName';

      // Download the video
      await _dio.download(
        videoUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            _downloadProgress[key] = progress;
            onProgress?.call(progress);
          }
        },
      );

      // Save metadata about the downloaded video
      await _saveDownloadMetadata(
        courseId: courseId,
        lessonId: lessonId,
        lessonTitle: lessonTitle,
        filePath: savePath,
        downloadedAt: DateTime.now().toIso8601String(),
      );

      _downloadProgress[key] = 1.0;
      _downloading[key] = false;
      return true;
    } catch (e) {
      print('❌ Error downloading video: $e');
      _downloading[key] = false;
      _downloadProgress[key] = 0.0;
      
      // Delete partial file if exists
      try {
        final videosDir = await _videosDirectory;
        final fileName = _generateFileName(courseId, lessonId);
        final file = File('${videosDir.path}/$fileName');
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
      
      return false;
    }
  }

  /// Save download metadata to SharedPreferences
  Future<void> _saveDownloadMetadata({
    required String courseId,
    required String lessonId,
    required String lessonTitle,
    required String filePath,
    required String downloadedAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'downloaded_video_${courseId}_$lessonId';
    final metadata = {
      'courseId': courseId,
      'lessonId': lessonId,
      'lessonTitle': lessonTitle,
      'filePath': filePath,
      'downloadedAt': downloadedAt,
    };
    await prefs.setString(key, filePath);
    await prefs.setString('${key}_meta', '${courseId}|${lessonId}|${lessonTitle}|${downloadedAt}');
  }

  /// Delete a downloaded video
  Future<bool> deleteVideo(String courseId, String lessonId) async {
    try {
      final videosDir = await _videosDirectory;
      final fileName = _generateFileName(courseId, lessonId);
      final file = File('${videosDir.path}/$fileName');
      
      if (await file.exists()) {
        await file.delete();
      }

      // Clear metadata
      final prefs = await SharedPreferences.getInstance();
      final key = 'downloaded_video_${courseId}_$lessonId';
      await prefs.remove(key);
      await prefs.remove('${key}_meta');

      final mapKey = '${courseId}_$lessonId';
      _downloadProgress.remove(mapKey);
      _downloading.remove(mapKey);

      return true;
    } catch (e) {
      print('❌ Error deleting video: $e');
      return false;
    }
  }

  /// Check if a course has any downloaded videos
  Future<bool> courseHasDownloadedVideos(String courseId) async {
    final downloadedVideos = await getDownloadedVideosForCourse(courseId);
    return downloadedVideos.isNotEmpty;
  }

  /// Get total downloaded videos count for a course
  Future<int> getDownloadedVideosCountForCourse(String courseId) async {
    final downloadedVideos = await getDownloadedVideosForCourse(courseId);
    return downloadedVideos.length;
  }
  Future<List<Map<String, dynamic>>> getDownloadedVideosForCourse(String courseId) async {
    final prefs = await SharedPreferences.getInstance();
    final videosDir = await _videosDirectory;
    final List<Map<String, dynamic>> downloadedVideos = [];

    // Get all keys that match this course
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (key.startsWith('downloaded_video_${courseId}_') && !key.endsWith('_meta')) {
        final filePath = prefs.getString(key);
        final metaKey = '${key}_meta';
        final meta = prefs.getString(metaKey);
        
        if (filePath != null && meta != null) {
          final parts = meta.split('|');
          if (parts.length >= 4) {
            final file = File(filePath);
            if (await file.exists()) {
              downloadedVideos.add({
                'courseId': parts[0],
                'lessonId': parts[1],
                'lessonTitle': parts[2],
                'filePath': filePath,
                'downloadedAt': parts[3],
              });
            }
          }
        }
      }
    }

    return downloadedVideos;
  }

  /// Get total size of all downloaded videos
  Future<String> getTotalDownloadedSize() async {
    try {
      final videosDir = await _videosDirectory;
      int totalBytes = 0;
      
      await for (final file in videosDir.list()) {
        if (file is File && file.path.endsWith('.mp4')) {
          totalBytes += await file.length();
        }
      }

      // Format size
      if (totalBytes < 1024 * 1024) {
        return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
      } else if (totalBytes < 1024 * 1024 * 1024) {
        return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      } else {
        return '${(totalBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
      }
    } catch (e) {
      return '0 MB';
    }
  }

  /// Clear all downloaded videos
  Future<void> clearAllDownloads() async {
    try {
      final videosDir = await _videosDirectory;
      await videosDir.delete(recursive: true);
      await videosDir.create(recursive: true);

      // Clear all metadata
      final prefs = await SharedPreferences.getInstance();
      final keysToRemove = prefs.getKeys().where((k) => k.startsWith('downloaded_video_')).toList();
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }

      _downloadProgress.clear();
      _downloading.clear();
    } catch (e) {
      print('❌ Error clearing downloads: $e');
    }
  }
}
