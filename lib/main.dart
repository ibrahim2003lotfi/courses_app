import 'package:courses_app/main%20pages/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Courses App',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
