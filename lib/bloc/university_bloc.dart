import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/university_api.dart';

abstract class UniversityEvent {}

class LoadUniversitiesEvent extends UniversityEvent {}

class LoadFacultiesEvent extends UniversityEvent {
  final String universityId;
  LoadFacultiesEvent(this.universityId);
}

class LoadFacultyCoursesEvent extends UniversityEvent {
  final String universityId;
  final String facultyId;
  LoadFacultyCoursesEvent(this.universityId, this.facultyId);
}

class UniversityState {
  final bool isLoading;
  final List<dynamic> universities;
  final List<dynamic> faculties;
  final List<dynamic> courses;
  final String? error;

  const UniversityState({
    required this.isLoading,
    required this.universities,
    required this.faculties,
    required this.courses,
    this.error,
  });

  UniversityState copyWith({
    bool? isLoading,
    List<dynamic>? universities,
    List<dynamic>? faculties,
    List<dynamic>? courses,
    String? error,
  }) {
    return UniversityState(
      isLoading: isLoading ?? this.isLoading,
      universities: universities ?? this.universities,
      faculties: faculties ?? this.faculties,
      courses: courses ?? this.courses,
      error: error,
    );
  }
}

class UniversityBloc extends Bloc<UniversityEvent, UniversityState> {
  final UniversityApi _api;

  UniversityBloc({UniversityApi? api})
      : _api = api ?? UniversityApi(),
        super(const UniversityState(
          isLoading: false,
          universities: [],
          faculties: [],
          courses: [],
        )) {
    on<LoadUniversitiesEvent>(_onLoadUniversities);
    on<LoadFacultiesEvent>(_onLoadFaculties);
    on<LoadFacultyCoursesEvent>(_onLoadFacultyCourses);
  }

  Future<void> _onLoadUniversities(
    LoadUniversitiesEvent event,
    Emitter<UniversityState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final list = await _api.getUniversities();
      emit(state.copyWith(isLoading: false, universities: list));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onLoadFaculties(
    LoadFacultiesEvent event,
    Emitter<UniversityState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null, faculties: []));
    try {
      final list = await _api.getFaculties(event.universityId);
      emit(state.copyWith(isLoading: false, faculties: list));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onLoadFacultyCourses(
    LoadFacultyCoursesEvent event,
    Emitter<UniversityState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null, courses: []));
    try {
      final list =
          await _api.getFacultyCourses(event.universityId, event.facultyId);
      emit(state.copyWith(isLoading: false, courses: list));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}













