import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/course_management_api.dart';

// Events
abstract class CourseManagementEvent {}

class RateCourseEvent extends CourseManagementEvent {
  final String courseId;
  final double rating;
  final String? review;
  RateCourseEvent({
    required this.courseId,
    required this.rating,
    this.review,
  });
}

class EnrollCourseEvent extends CourseManagementEvent {
  final Map<String, dynamic> course;
  EnrollCourseEvent(this.course);
}

class ToggleWatchLaterEvent extends CourseManagementEvent {
  final Map<String, dynamic> course;
  ToggleWatchLaterEvent(this.course);
}

class LoadUserCoursesEvent extends CourseManagementEvent {}

class UpdateCourseProgressEvent extends CourseManagementEvent {
  final String courseId;
  final double progress;
  final int currentLesson;
  UpdateCourseProgressEvent({
    required this.courseId,
    required this.progress,
    required this.currentLesson,
  });
}

// States
class CourseManagementState {
  final List<Map<String, dynamic>> enrolledCourses;
  final List<Map<String, dynamic>> watchLaterCourses;
  final bool isLoading;
  final String? error;

  CourseManagementState({
    required this.enrolledCourses,
    required this.watchLaterCourses,
    required this.isLoading,
    this.error,
  });

  CourseManagementState copyWith({
    List<Map<String, dynamic>>? enrolledCourses,
    List<Map<String, dynamic>>? watchLaterCourses,
    bool? isLoading,
    String? error,
  }) {
    return CourseManagementState(
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      watchLaterCourses: watchLaterCourses ?? this.watchLaterCourses,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// BLoC
class CourseManagementBloc extends Bloc<CourseManagementEvent, CourseManagementState> {
  final CourseManagementApi _api = CourseManagementApi();
  static const String _enrolledCoursesKey = 'cached_enrolled_courses';

  CourseManagementBloc()
      : super(CourseManagementState(
          enrolledCourses: [],
          watchLaterCourses: [],
          isLoading: false,
        )) {
    on<EnrollCourseEvent>(_onEnrollCourse);
    on<ToggleWatchLaterEvent>(_onToggleWatchLater);
    on<LoadUserCoursesEvent>(_onLoadUserCourses);
    on<UpdateCourseProgressEvent>(_onUpdateCourseProgress);
    on<RateCourseEvent>(_onRateCourse);
  }

  void _onRateCourse(RateCourseEvent event, Emitter<CourseManagementState> emit) {
    final updatedEnrolledCourses = state.enrolledCourses.map((course) {
      if (course['id'] == event.courseId) {
        return {
          ...course,
          'userRating': event.rating,
          'userReview': event.review,
          'ratedAt': DateTime.now().toString(),
        };
      }
      return course;
    }).toList();

    emit(state.copyWith(enrolledCourses: updatedEnrolledCourses));
    _cacheEnrolledCourses(updatedEnrolledCourses);
  }

  // Cache enrolled courses to local storage
  Future<void> _cacheEnrolledCourses(List<Map<String, dynamic>> courses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final coursesJson = jsonEncode(courses);
      await prefs.setString(_enrolledCoursesKey, coursesJson);
      print('✅ Cached ${courses.length} enrolled courses');
    } catch (e) {
      print('❌ Error caching enrolled courses: $e');
    }
  }

  // Load cached enrolled courses from local storage
  Future<List<Map<String, dynamic>>> _loadCachedEnrolledCourses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final coursesJson = prefs.getString(_enrolledCoursesKey);
      if (coursesJson != null) {
        final List<dynamic> decoded = jsonDecode(coursesJson);
        final courses = decoded.map((c) => Map<String, dynamic>.from(c)).toList();
        print('✅ Loaded ${courses.length} cached enrolled courses');
        return courses;
      }
    } catch (e) {
      print('❌ Error loading cached enrolled courses: $e');
    }
    return [];
  }

  void _onEnrollCourse(EnrollCourseEvent event, Emitter<CourseManagementState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    
    // Call backend API to enroll
    final courseId = event.course['id']?.toString() ?? '';
    if (courseId.isNotEmpty) {
      final result = await _api.enrollInCourse(courseId);
      
      if (!result['success']) {
        // If already enrolled, we can continue locally
        // If other error, show it
        if (result['message'] != 'Already enrolled in this course') {
          emit(state.copyWith(
            isLoading: false,
            error: result['message'],
          ));
          return;
        }
      }
    }
    
    // Check if already enrolled locally
    if (state.enrolledCourses.any((course) => course['id'] == event.course['id'])) {
      emit(state.copyWith(
        isLoading: false,
        error: 'أنت مسجل مسبقاً في هذه الدورة',
      ));
      return;
    }
    
    final enrolledCourse = {
      ...event.course,
      'enrolledAt': DateTime.now().toString(),
      'progress': 0.0,
      'currentLesson': 0,
      'completedLessons': [],
      'lastAccessed': DateTime.now().toString(),
    };
    
    final updatedEnrolledCourses = [...state.enrolledCourses, enrolledCourse];
    
    emit(state.copyWith(
      enrolledCourses: updatedEnrolledCourses,
      isLoading: false,
      error: null,
    ));

    // Cache the updated courses
    await _cacheEnrolledCourses(updatedEnrolledCourses);
  }

  void _onToggleWatchLater(ToggleWatchLaterEvent event, Emitter<CourseManagementState> emit) {
    final isInWatchLater = state.watchLaterCourses.any((course) => course['id'] == event.course['id']);
    
    List<Map<String, dynamic>> updatedWatchLaterCourses;
    
    if (isInWatchLater) {
      updatedWatchLaterCourses = state.watchLaterCourses
          .where((course) => course['id'] != event.course['id'])
          .toList();
    } else {
      final watchLaterCourse = {
        ...event.course,
        'addedAt': DateTime.now().toString(),
      };
      updatedWatchLaterCourses = [...state.watchLaterCourses, watchLaterCourse];
    }
    
    emit(state.copyWith(watchLaterCourses: updatedWatchLaterCourses));
  }

  Future<void> _onLoadUserCourses(
    LoadUserCoursesEvent event,
    Emitter<CourseManagementState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    // First, try to load cached courses
    final cachedCourses = await _loadCachedEnrolledCourses();
    if (cachedCourses.isNotEmpty) {
      // Show cached courses immediately while fetching fresh data
      emit(state.copyWith(
        enrolledCourses: cachedCourses,
        isLoading: true, // Still loading to fetch fresh data
      ));
    }

    try {
      // Fetch enrolled courses from backend
      final result = await _api.getEnrolledCourses();
      
      if (result['success'] == true) {
        final List<dynamic> courses = result['courses'] ?? [];
        
        // Map backend courses to local format
        final mappedCourses = courses.map((course) => _mapEnrolledCourse(course)).toList();
        
        emit(state.copyWith(
          enrolledCourses: mappedCourses,
          isLoading: false,
        ));

        // Cache the fresh courses
        await _cacheEnrolledCourses(mappedCourses);
      } else {
        // If backend fails but we have cached courses, keep them
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      print('❌ Error loading user courses: $e');
      // If error but we have cached courses, keep them
      emit(state.copyWith(isLoading: false));
    }
  }

  // Helper to map backend enrolled course to local format
  Map<String, dynamic> _mapEnrolledCourse(dynamic course) {
    return {
      'id': course['id'] ?? '',
      'slug': course['slug'] ?? '',
      'title': course['title'] ?? 'دورة بدون عنوان',
      'description': course['description'] ?? '',
      'image': course['image'] ?? '',
      'price': course['price']?.toString() ?? '0',
      'level': course['level'] ?? 'متوسط',
      'rating': (course['rating'] ?? 0).toDouble(),
      'teacher': course['instructor']?['name'] ?? 'مدرس',
      'instructor': course['instructor'],
      'category': course['category']?['name'] ?? 'عام',
      'category_id': course['category']?['id'],
      'progress': (course['progress'] ?? 0).toDouble(),
      'total_lessons': course['total_lessons'] ?? 0,
      'enrolled_at': course['enrolled_at'],
      'sections': course['sections'] ?? [],
      'lastAccessed': DateTime.now().toString(),
    };
  }

  void _onUpdateCourseProgress(UpdateCourseProgressEvent event, Emitter<CourseManagementState> emit) {
    final updatedEnrolledCourses = state.enrolledCourses.map((course) {
      if (course['id'] == event.courseId) {
        return {
          ...course,
          'progress': event.progress,
          'currentLesson': event.currentLesson,
          'lastAccessed': DateTime.now().toString(),
        };
      }
      return course;
    }).toList();

    emit(state.copyWith(enrolledCourses: updatedEnrolledCourses));
    _cacheEnrolledCourses(updatedEnrolledCourses);
  }

  // Helper methods
  bool isCourseEnrolled(String courseId) {
    return state.enrolledCourses.any((course) => course['id'] == courseId);
  }

  bool isCourseInWatchLater(String courseId) {
    return state.watchLaterCourses.any((course) => course['id'] == courseId);
  }

  Map<String, dynamic>? getEnrolledCourse(String courseId) {
    try {
      return state.enrolledCourses.firstWhere((course) => course['id'] == courseId);
    } catch (e) {
      return null;
    }
  }
}