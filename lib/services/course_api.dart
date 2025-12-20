import 'dart:convert';


import '../config/api.dart';
import 'api_client.dart';

class CourseApi {
  final ApiClient _client = ApiClient();

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

  /// Get single course details by slug
  Future<Map<String, dynamic>> getCourseDetails(String slug) async {
    final response = await _client.get("/courses/$slug");

    return jsonDecode(response.body) as Map<String, dynamic>;

  }

  /// Create regular instructor course
  Future<Map<String, dynamic>> createInstructorCourse({
    required String title,
    String? description,
    num? price,
    String? level,
    String? categoryId,
  }) async {
    final body = {
      "title": title,
      if (description != null) "description": description,
      if (price != null) "price": price,
      if (level != null) "level": level,
      if (categoryId != null) "category_id": categoryId,
    };

    final response = await _client.post(
      "/instructor/courses",
      body as Map<String, dynamic>,
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Create university course (second tab)
  Future<Map<String, dynamic>> createUniversityCourse({
    required String title,
    String? description,
    required num price,
    String? level,
    required String universityId,
    required String facultyId,
  }) async {
    final body = {
      "title": title,
      if (description != null) "description": description,
      "price": price,
      if (level != null) "level": level,
      "university_id": universityId,
      "faculty_id": facultyId,
    };

    final response = await _client.post(
      "/instructor/university-courses",
      body as Map<String, dynamic>,
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Get course sections (for instructors)
  Future<Map<String, dynamic>> getCourseSections(String courseId) async {
    final response = await _client.get("/instructor/courses/$courseId/sections");

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
  Future<Map<String, dynamic>> deleteSection(String courseId, String sectionId) async {
    final response = await _client.delete("/instructor/courses/$courseId/sections/$sectionId");

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Get lessons for a section
  Future<Map<String, dynamic>> getLessons(String courseId, String sectionId) async {
    final response = await _client.get("/instructor/courses/$courseId/sections/$sectionId/lessons");

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
  Future<Map<String, dynamic>> deleteLesson(String courseId, String sectionId, String lessonId) async {
    final response = await _client.delete("/instructor/courses/$courseId/sections/$sectionId/lessons/$lessonId");

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Get stream URL for a lesson (for enrolled students)
  Future<Map<String, dynamic>> getLessonStream(String courseSlug, String lessonId) async {
    final response = await _client.get("/courses/$courseSlug/stream/$lessonId");

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}




