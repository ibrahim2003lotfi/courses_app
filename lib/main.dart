// Update your main.dart
import 'package:courses_app/bloc/user_role_bloc.dart';
import 'package:courses_app/core/utils/onboarding_manager.dart';
import 'package:courses_app/core/utils/theme_manager.dart';
import 'package:courses_app/main_pages/splash/splash_page.dart';
import 'package:courses_app/onboarding/onboarding_screen.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check if onboarding is completed
  final isOnboardingCompleted = await OnboardingManager.isOnboardingCompleted();
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => UserRoleBloc()),
      ],
      child: MyApp(isOnboardingCompleted: isOnboardingCompleted),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isOnboardingCompleted;
  
  const MyApp({super.key, required this.isOnboardingCompleted});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          title: 'Courses App',
          theme: ThemeManager.lightTheme,
          darkTheme: ThemeManager.darkTheme,
          themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          debugShowCheckedModeBanner: false,
          home: isOnboardingCompleted ? const SplashScreen() : const OnboardingScreen(),
        );
      },
    );
  }
}