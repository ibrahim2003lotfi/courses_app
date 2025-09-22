import 'package:courses_app/data/notifiers.dart';
import 'package:courses_app/main%20pages/home/presentation/pages/home_page.dart';
import 'package:courses_app/main%20pages/profile/presentation/pages/profile_page.dart';
import 'package:courses_app/navbar/presentation/main_navbar_page.dart';
import 'package:flutter/material.dart';

List<Widget> pages = [HomePage(), ProfilePage()];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Courses App'), centerTitle: true),
      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (context, selectedPage, child) {
          return pages.elementAt(selectedPage);
        },
      ),
      bottomNavigationBar: NavBarWidget(),
    );
  }
}
