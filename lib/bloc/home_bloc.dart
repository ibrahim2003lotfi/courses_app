import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/home_api.dart';
import '../services/profile_service.dart';

class HomeEvent {}

class LoadHomeEvent extends HomeEvent {}

class HomeState {
  final bool isLoading;
  final Map<String, dynamic>? data;
  final List<String> userInterests;
  final List<Map<String, dynamic>> enrolledCourses;
  final String? error;

  const HomeState({
    required this.isLoading,
    this.data,
    this.userInterests = const [],
    this.enrolledCourses = const [],
    this.error,
  });

  HomeState copyWith({
    bool? isLoading,
    Map<String, dynamic>? data,
    List<String>? userInterests,
    List<Map<String, dynamic>>? enrolledCourses,
    String? error,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      userInterests: userInterests ?? this.userInterests,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      error: error,
    );
  }
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeApi _api;
  final ProfileService _profileService;

  HomeBloc({HomeApi? api, ProfileService? profileService})
    : _api = api ?? HomeApi(),
      _profileService = profileService ?? ProfileService(),
      super(const HomeState(isLoading: false)) {
    on<LoadHomeEvent>(_onLoadHome);
  }

  Future<void> _onLoadHome(LoadHomeEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      // Fetch home data first (this is critical)
      final homeData = await _api.getHome();

      // Fetch profile (optional)
      List<String> interests = [];
      try {
        final profileResponse = await _profileService.getMe();
        print('🔍 Profile response: $profileResponse');
        if (profileResponse['status'] == 200 &&
            profileResponse['data'] != null) {
          final userData =
              profileResponse['data']['user'] as Map<String, dynamic>?;
          print('🔍 User data: $userData');
          print('🔍 Interests raw: ${userData?['interests']}');
          if (userData != null && userData['interests'] != null) {
            interests = List<String>.from(userData['interests']);
          }
        }
      } catch (e, stackTrace) {
        print('⚠️ Profile fetch failed: $e');
        print('⚠️ Stack trace: $stackTrace');
      }

      print('🎯 User interests loaded: $interests');

      // Skip enrolled courses API for now - it's causing server crashes
      // Return empty list to show "no courses" message

      emit(
        HomeState(
          isLoading: false,
          data: homeData,
          userInterests: interests,
          enrolledCourses: [],
        ),
      );
    } catch (e) {
      emit(
        HomeState(
          isLoading: false,
          error: e.toString(),
          data: state.data,
          userInterests: state.userInterests,
          enrolledCourses: state.enrolledCourses,
        ),
      );
    }
  }
}
