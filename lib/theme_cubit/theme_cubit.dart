// lib/core/utils/theme_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'theme_state.dart';

export 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState.initial()) {
    _initSystemTheme();
  }

  void _initSystemTheme() {
    // Get initial system theme
    _updateThemeFromSystem();
    
    // Listen for system theme changes
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      _updateThemeFromSystem();
    };
  }

  void _updateThemeFromSystem() {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    emit(state.copyWith(isDarkMode: isDarkMode));
  }

  void toggleTheme() => emit(state.copyWith(isDarkMode: !state.isDarkMode));

  void setTheme(bool isDarkMode) => emit(state.copyWith(isDarkMode: isDarkMode));
}