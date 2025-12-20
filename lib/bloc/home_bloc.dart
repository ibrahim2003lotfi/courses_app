import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/home_api.dart';

class HomeEvent {}

class LoadHomeEvent extends HomeEvent {}

class HomeState {
  final bool isLoading;
  final Map<String, dynamic>? data;
  final String? error;

  const HomeState({
    required this.isLoading,
    this.data,
    this.error,
  });

  HomeState copyWith({
    bool? isLoading,
    Map<String, dynamic>? data,
    String? error,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error,
    );
  }
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeApi _api;

  HomeBloc({HomeApi? api})
      : _api = api ?? HomeApi(),
        super(const HomeState(isLoading: false)) {
    on<LoadHomeEvent>(_onLoadHome);
  }

  Future<void> _onLoadHome(
    LoadHomeEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final data = await _api.getHome();
      emit(HomeState(isLoading: false, data: data));
    } catch (e) {
      emit(
        HomeState(
          isLoading: false,
          error: e.toString(),
          data: state.data,
        ),
      );
    }
  }
}













