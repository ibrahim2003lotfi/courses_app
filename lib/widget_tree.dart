import 'package:courses_app/data/notifiers.dart';
import 'package:courses_app/main_pages/courses/presentation/pages/favorite_courses_page.dart';
import 'package:courses_app/main_pages/home/presentation/pages/home_page.dart';
import 'package:courses_app/main_pages/notifications/presentation/pages/notifications_page.dart';
import 'package:courses_app/main_pages/profile/presentation/pages/profile_page.dart';
import 'package:courses_app/main_pages/search/presentation/pages/search_page.dart';
import 'package:courses_app/navbar/presentation/main_navbar_page.dart';
import 'package:flutter/material.dart';

/// All main app pages
final List<Widget> pages = [
  const HomePage(),
  const SearchPage(),
  const CoursesPage(),
  const NotificationsPage(),
  const ProfilePage(),
];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Let MaterialApp + ThemeCubit control background colors globally
      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (BuildContext context, dynamic selectedPage, Widget? child) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0), // subtle slide-in animation
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
      bottomNavigationBar: const NavBarWidget(),
    );
  }
}
