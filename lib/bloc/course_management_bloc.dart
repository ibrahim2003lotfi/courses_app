import 'package:flutter_bloc/flutter_bloc.dart';

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
  }

  void _onEnrollCourse(EnrollCourseEvent event, Emitter<CourseManagementState> emit) async {
    emit(state.copyWith(isLoading: true));
    
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Check if already enrolled
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

  void _onLoadUserCourses(LoadUserCoursesEvent event, Emitter<CourseManagementState> emit) {
    // In a real app, you would load from shared preferences or API
    // For now, we'll simulate loading some initial data
    emit(state.copyWith(isLoading: true));
    
    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 500), () {
      emit(state.copyWith(isLoading: false));
    });
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