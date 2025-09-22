import 'package:courses_app/data/notifiers.dart';
import 'package:courses_app/main%20pages/courses/presentation/pages/course_details_page.dart';
import 'package:courses_app/main%20pages/home/presentation/pages/home_page.dart';
import 'package:courses_app/main%20pages/profile/presentation/pages/profile_page.dart';
import 'package:courses_app/main%20pages/search/presentation/pages/search_page.dart';
import 'package:courses_app/navbar/presentation/main_navbar_page.dart';
import 'package:flutter/material.dart';

List<Widget> pages = [
  HomePage(),
  SearchPage(),
  CourseDetailsPage(),
  ProfilePage(),
];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Courses App'), centerTitle: true),
      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (BuildContext context, dynamic selectedPage, Widget? child) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0), // slight horizontal slide
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: pages[selectedPage],
          );
        },
      ),
      bottomNavigationBar: NavBarWidget(),
    );
  }
}
