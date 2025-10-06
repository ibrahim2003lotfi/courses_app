// lib/core/utils/theme_state.dart
import 'package:equatable/equatable.dart';

class ThemeState extends Equatable {
  final bool isDarkMode;
  final bool isFollowingSystem;

  const ThemeState({required this.isDarkMode, this.isFollowingSystem = true});

  factory ThemeState.initial() => const ThemeState(isDarkMode: false, isFollowingSystem: true);

  ThemeState copyWith({bool? isDarkMode, bool? isFollowingSystem}) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isFollowingSystem: isFollowingSystem ?? this.isFollowingSystem,
    );
  }

  @override
  List<Object?> get props => [isDarkMode, isFollowingSystem];
}