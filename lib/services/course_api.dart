import 'dart:convert';

import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:path/path.dart' as path;



import '../config/api.dart';

import 'api_client.dart';

import 'auth_service.dart';

import 'chunked_video_upload_service.dart';



class CourseApi {

  final ApiClient _client = ApiClient();

  final AuthService _auth = AuthService();



  /// Public courses listing with optional query params

  Future<Map<String, dynamic>> getPublicCourses({

    String? search,

    String? level,

    num? minPrice,

    num? maxPrice,

    String? categoryId,

    int page = 1,

    int perPage = 10,

  }) async {

    final queryParams = <String, String>{

      'page': page.toString(),

      'per_page': perPage.toString(),

    };



    if (search != null && search.isNotEmpty) {

      queryParams['search'] = search;

    }



    if (level != null && level.isNotEmpty) {

      queryParams['level'] = level;

    }

    if (minPrice != null) {

      queryParams['min_price'] = minPrice.toString();

    }

    if (maxPrice != null) {

      queryParams['max_price'] = maxPrice.toString();

    }

    if (categoryId != null && categoryId.isNotEmpty) {

      queryParams['category_id'] = categoryId;

    }



    final uri = Uri.parse(

      "${ApiConfig.baseUrl}/courses",

    ).replace(queryParameters: queryParams);



    final response = await _client.get("/courses?${uri.query}");



    return jsonDecode(response.body) as Map<String, dynamic>;

  }



  /// Delete instructor course (DB-backed)

  Future<Map<String, dynamic>> deleteInstructorCourse(String courseId) async {

    try {

      final response = await _client.delete('/instructor/courses-db/$courseId');



      if (response.body.isEmpty) {

        return {

          'success': false,

          'error': 'empty_response',

          'message': 'استجابة فارغة من الخادم',

        };

      }



      try {

        return jsonDecode(response.body) as Map<String, dynamic>;

      } catch (e) {

        return {

          'success': false,

          'error': 'invalid_response',

          'message': 'استجابة غير صالحة من الخادم',

          'raw_response': response.body,

        };

      }

    } catch (e) {

      return {

        'success': false,

        'error': 'network_error',

        'message': 'فشل الاتصال بالخادم: $e',

      };

    }

  }



  /// Update instructor course (DB-backed)

  Future<Map<String, dynamic>> updateInstructorCourse({

    required String id,

    String? title,

    String? description,

    num? price,

    String? level,

    String? categoryId,

    String? categoryName,

  }) async {

    final body = <String, String>{};

    if (title != null) body['title'] = title;

    if (description != null) body['description'] = description;

    if (price != null) body['price'] = price.toString();

    if (level != null) body['level'] = level;

    if (categoryId != null) body['category_id'] = categoryId;

    if (categoryName != null) body['category_name'] = categoryName;



    try {

      final response = await _client.put('/instructor/courses-db/$id', body);



      if (response.body.isEmpty) {

        return {

          'success': false,

          'error': 'empty_response',

          'message': 'استجابة فارغة من الخادم',

        };

      }



      try {

        return jsonDecode(response.body) as Map<String, dynamic>;

      } catch (e) {

        return {

          'success': false,

          'error': 'invalid_response',

          'message': 'استجابة غير صالحة من الخادم',

          'raw_response': response.body,

        };

      }

    } catch (e) {

      return {

        'success': false,

        'error': 'network_error',

        'message': 'فشل الاتصال بالخادم: $e',

      };

    }

  }



  /// Get single course details by slug

  Future<Map<String, dynamic>> getCourseDetails(String slug) async {

    final url = "/courses/$slug";

    print('DEBUG - Calling API: GET $url');



    final response = await _client.get(url);



    print('DEBUG - Response status: ${response.statusCode}');

    print('DEBUG - Response body: ${response.body}');

    print('DEBUG - Slug used: $slug');



    return jsonDecode(response.body) as Map<String, dynamic>;

  }



  /// Create regular instructor course with file uploads

  Future<Map<String, dynamic>> createInstructorCourse({

    required String title,

    String? description,

    num? price,

    String? level,

    String? categoryId,

    String? categoryName,

    File? thumbnailImage,

    List<Map<String, dynamic>>? lessons,

  }) async {

    // Get the current user's ID for instructor_id

    final instructorId = await _auth.getUserId();



    final fields = {

      "title": title,

      if (description != null) "description": description,

      if (price != null) "price": price.toString(),

      if (level != null) "level": level,

      if (categoryId != null) "category_id": categoryId,

      if (categoryName != null) "category_name": categoryName,

      if (lessons != null) "lessons_json": jsonEncode(lessons),

      if (instructorId != null) "instructor_id": instructorId,

    };



    final files = <String, File>{};

    if (thumbnailImage != null) {

      files['thumbnail_image'] = thumbnailImage;

    }



    final response = await _client.postMultipart(

      "/instructor/courses-db",

      fields: fields,

      files: files.isNotEmpty ? files : null,

    );



    // Handle empty or invalid response

    if (response.body.isEmpty) {

      return {

        'success': false,

        'error': 'empty_response',

        'message': 'استجابة فارغة من الخادم',

      };

    }



    try {

      return jsonDecode(response.body) as Map<String, dynamic>;

    } catch (e) {

      // If JSON parsing fails, return error with raw response

      return {

        'success': false,

        'error': 'invalid_response',

        'message': 'استجابة غير صالحة من الخادم',

        'raw_response': response.body,

        'status_code': response.statusCode,

      };

    }

  }



  /// Create university course with file uploads - uses same endpoint as educational courses

  Future<Map<String, dynamic>> createUniversityCourse({

    required String title,

    String? description,

    required num price,

    String? level,

    required String universityId,

    required String universityName,

    required String facultyId,

    required String facultyName,

    String? categoryId,

    String? categoryName,

    File? thumbnailImage,

    List<Map<String, dynamic>>? lessons,

  }) async {

    // Get the current user's ID for instructor_id (same as educational courses)

    final instructorId = await _auth.getUserId();



    final fields = {

      "title": title,

      if (description != null) "description": description,

      "price": price.toString(),

      if (level != null) "level": level,

      "university_id": universityId,

      "university_name": universityName,

      "faculty_id": facultyId,

      "faculty_name": facultyName,

      if (categoryId != null) "category_id": categoryId,

      if (categoryName != null) "category_name": categoryName,

      "type": "university",

      "is_university_course": "true",

      if (lessons != null) "lessons_json": jsonEncode(lessons),

      if (instructorId != null) "instructor_id": instructorId,

    };



    final files = <String, File>{};

    if (thumbnailImage != null) {

      files['thumbnail_image'] = thumbnailImage;

    }



    // Use same endpoint as educational courses

    final response = await _client.postMultipart(

      "/instructor/courses-db",

      fields: fields,

      files: files.isNotEmpty ? files : null,

    );



    // Handle empty or invalid response (same as educational courses)

    if (response.body.isEmpty) {

      return {

        'success': false,

        'error': 'empty_response',

        'message': 'استجابة فارغة من الخادم',

      };

    }



    try {

      return jsonDecode(response.body) as Map<String, dynamic>;

    } catch (e) {

      // If JSON parsing fails, return error with raw response (same as educational)

      return {

        'success': false,

        'error': 'invalid_response',

        'message': 'استجابة غير صالحة من الخادم',

        'raw_response': response.body,

        'status_code': response.statusCode,

      };

    }

  }



  /// Get course sections (for instructors)

  Future<Map<String, dynamic>> getCourseSections(String courseId) async {

    final response = await _client.get(

      "/instructor/courses/$courseId/sections",

    );



    return jsonDecode(response.body) as Map<String, dynamic>;

  }



  /// Create section

  Future<Map<String, dynamic>> createSection({

    required String courseId,

    required String title,

    String? description,

    int? order,

  }) async {

    final body = {

      "title": title,

      if (description != null) "description": description,

      if (order != null) "order": order,

    };



    final response = await _client.post(

      "/instructor/courses/$courseId/sections",

      body,

    );



    return jsonDecode(response.body) as Map<String, dynamic>;

  }



  /// Update section

  Future<Map<String, dynamic>> updateSection({

    required String courseId,

    required String sectionId,

    String? title,

    String? description,

    int? order,

  }) async {

    final body = <String, dynamic>{};

    if (title != null) body["title"] = title;

    if (description != null) body["description"] = description;

    if (order != null) body["order"] = order;



    final response = await _client.put(

      "/instructor/courses/$courseId/sections/$sectionId",

      body,

    );



    return jsonDecode(response.body) as Map<String, dynamic>;

  }



  /// Delete section

  Future<Map<String, dynamic>> deleteSection(

    String courseId,

    String sectionId,

  ) async {

    final response = await _client.delete(

      "/instructor/courses/$courseId/sections/$sectionId",

    );



    return jsonDecode(response.body) as Map<String, dynamic>;

  }



  /// Get lessons for a section

  Future<Map<String, dynamic>> getLessons(

    String courseId,

    String sectionId,

  ) async {

    final response = await _client.get(

      "/instructor/courses/$courseId/sections/$sectionId/lessons",

    );



    return jsonDecode(response.body) as Map<String, dynamic>;

  }



  /// Create lesson

  Future<Map<String, dynamic>> createLesson({

    required String courseId,

    required String sectionId,

    required String title,

    String? description,

    String? videoUrl,

    String? hlsManifestUrl,

    int? duration,

    int? order,

    bool? isFree,

  }) async {

    final body = {

      "title": title,

      if (description != null) "description": description,

      if (videoUrl != null) "video_url": videoUrl,

      if (hlsManifestUrl != null) "hls_manifest_url": hlsManifestUrl,

      if (duration != null) "duration": duration,

      if (order != null) "order": order,

      if (isFree != null) "is_free": isFree,

    };



    final response = await _client.post(

      "/instructor/courses/$courseId/sections/$sectionId/lessons",

      body,

    );



    return jsonDecode(response.body) as Map<String, dynamic>;

  }



  /// Update lesson

  Future<Map<String, dynamic>> updateLesson({

    required String courseId,

    required String sectionId,

    required String lessonId,

    String? title,

    String? description,

    String? videoUrl,

    String? hlsManifestUrl,

    int? duration,

    int? order,

    bool? isFree,

  }) async {

    final body = <String, dynamic>{};

    if (title != null) body["title"] = title;

    if (description != null) body["description"] = description;

    if (videoUrl != null) body["video_url"] = videoUrl;

    if (hlsManifestUrl != null) body["hls_manifest_url"] = hlsManifestUrl;

    if (duration != null) body["duration"] = duration;

    if (order != null) body["order"] = order;

    if (isFree != null) body["is_free"] = isFree;



    final response = await _client.put(

      "/instructor/courses/$courseId/sections/$sectionId/lessons/$lessonId",

      body,

    );



    return jsonDecode(response.body) as Map<String, dynamic>;

  }



  /// Delete lesson

  Future<Map<String, dynamic>> deleteLesson(

    String courseId,

    String sectionId,

    String lessonId,

  ) async {

    final response = await _client.delete(

      "/instructor/courses/$courseId/sections/$sectionId/lessons/$lessonId",

    );



    return jsonDecode(response.body) as Map<String, dynamic>;

  }



  /// Get instructor's courses

  Future<Map<String, dynamic>> getInstructorCourses() async {

    try {

      // Get the current user's ID

      final instructorId = await _auth.getUserId();



      // Build URL with instructor_id query parameter if available

      final endpoint = instructorId != null

          ? "/instructor/my-courses-db?instructor_id=$instructorId"

          : "/instructor/my-courses-db";



      // Use the DB-backed endpoint for instructor courses

      final response = await _client.get(endpoint);



      if (response.body.isEmpty) {

        return {

          'success': false,

          'error': 'empty_response',

          'message': 'استجابة فارغة من الخادم',

          'courses': [],

        };

      }



      try {

        return jsonDecode(response.body) as Map<String, dynamic>;

      } catch (e) {

        return {

          'success': false,

          'error': 'invalid_response',

          'message': 'استجابة غير صالحة من الخادم',

          'raw_response': response.body,

          'courses': [],

        };

      }

    } catch (e) {

      print('🔴 Error fetching instructor courses: $e');

      return {

        'success': false,

        'error': 'network_error',

        'message': 'فشل الاتصال بالخادم: $e',

        'courses': [],

      };

    }

  }



  /// Get stream URL for a lesson (for enrolled students)

  Future<Map<String, dynamic>> getLessonStream(

    String courseSlug,

    String lessonId,

  ) async {

    // Get user ID for header

    final authService = AuthService();

    final userId = await authService.getUserId();

    final token = await authService.getToken();



    final headers = {

      'Authorization': 'Bearer $token',

      'Content-Type': 'application/json',

      'Accept': 'application/json',

      if (userId != null) 'X-User-Id': userId,

    };



    print('🔵 [CourseApi] Getting stream for $courseSlug lesson $lessonId');

    print('🔵 [CourseApi] User ID: $userId');



    try {

      final response = await _client.getWithHeaders("/courses/$courseSlug/stream/$lessonId", headers);



      print('🔵 [CourseApi] Stream response status: ${response.statusCode}');





      // Handle non-200 status codes

      if (response.statusCode == 403) {

        return {

          'success': false,

          'error_code': 'unauthorized',

          'message': 'يجب شراء الكورس أولاً للوصول إلى هذا الفيديو',

        };

      }



      if (response.statusCode != 200) {

        return {

          'success': false,

          'error_code': 'http_error',

          'message': 'Server returned ${response.statusCode}',

          'status_code': response.statusCode,

        };

      }



      if (response.body.isEmpty) {

        return {

          'success': false,

          'error_code': 'empty_response',

          'message': 'Empty response from server',

        };

      }



      return jsonDecode(response.body) as Map<String, dynamic>;

    } catch (e) {

      print('🔴 [CourseApi] Stream error: $e');

      return {

        'success': false,

        'error_code': 'network_error',

        'message': 'Failed to load video: $e',

      };

    }

  }



  /// Upload video for a lesson using chunked upload (avoids php artisan serve crashes)

  Future<Map<String, dynamic>> uploadLessonVideo({

    required String courseId,
    required String lessonId,
    required File videoFile,
    int? duration,
    Function(int uploaded, int total)? onProgress,
  }) async {
    print('🟡 [CourseApi] Using chunked video upload for php artisan serve compatibility');
    
    final chunkedService = ChunkedVideoUploadService();
    return await chunkedService.uploadVideoChunked(
      courseId: courseId,
      lessonId: lessonId,
      videoFile: videoFile,
      onProgress: onProgress,
    );
  }

}

