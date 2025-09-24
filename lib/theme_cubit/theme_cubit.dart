// lib/core/utils/theme_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState.initial());

  void toggleTheme() => emit(state.copyWith(isDarkMode: !state.isDarkMode));

  void setTheme(bool isDarkMode) => emit(state.copyWith(isDarkMode: isDarkMode));
}
