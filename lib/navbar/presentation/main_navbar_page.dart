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
        return Directionality(
          textDirection: TextDirection.rtl, // هذا يجعل الشريط يبدأ من اليمين
          child: NavigationBar(
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_rounded),
                label: 'الرئيسية',
              ),
              NavigationDestination(icon: Icon(Icons.search), label: 'البحث'),
              NavigationDestination(
                icon: Icon(Icons.local_offer_outlined),
                label: 'كورساتي',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_circle_outlined),
                label: 'حسابي',
              ),
            ],
            onDestinationSelected: (int value) {
              selectedPageNotifier.value = value;
            },
            selectedIndex: selectedpage,
          ),
        );
      },
    );
  }
}
