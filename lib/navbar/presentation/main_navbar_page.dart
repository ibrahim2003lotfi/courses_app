import 'package:courses_app/data/notifiers.dart';
import 'package:flutter/material.dart';

class NavBarWidget extends StatefulWidget {
  const NavBarWidget({super.key});

  @override
  State<NavBarWidget> createState() => _NavBarWidgetState();
}

class _NavBarWidgetState extends State<NavBarWidget> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (BuildContext context, dynamic selectedpage, Widget? child) {
        return NavigationBar(
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
            NavigationDestination(
              icon: Icon(Icons.local_offer_outlined),
              label: 'Courses',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_active_outlined,),
              label: 'Notifications',
            ),
          
            NavigationDestination(
              icon: Icon(Icons.account_circle_outlined,),
              label: 'Profile',
            ),
          ],
          onDestinationSelected: (int value) {
            selectedPageNotifier.value = value;
          },
          selectedIndex: selectedpage,
        );
      },
    );
  }
}
