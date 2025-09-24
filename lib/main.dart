import 'package:courses_app/core/utils/theme_manager.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:courses_app/welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(BlocProvider(create: (_) => ThemeCubit(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
          home: const WelcomePage(),
        );
      },
    );
  }
}
