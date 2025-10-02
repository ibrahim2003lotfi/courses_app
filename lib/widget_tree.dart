import 'package:courses_app/data/notifiers.dart';
import 'package:courses_app/main_pages/courses/presentation/pages/favorite_courses_page.dart';
import 'package:courses_app/main_pages/home/presentation/pages/home_page.dart';
import 'package:courses_app/main_pages/profile/presentation/pages/profile_page.dart';
import 'package:courses_app/main_pages/search/presentation/pages/search_page.dart';
import 'package:courses_app/navbar/presentation/main_navbar_page.dart';
import 'package:flutter/material.dart';

/// All main app pages
final List<Widget> pages = [
  const HomePage(),
  const SearchPage(),
  const CoursesPage(),
  const ProfilePage(),
];

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree>
    with AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    selectedPageNotifier.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    if (_pageController.hasClients) {
      // استخدام jumpToPage للقفز المباشر بين الصفحات
      _pageController.jumpToPage(selectedPageNotifier.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          selectedPageNotifier.value = index;
        },
        children: pages.map((page) => KeepAliveWrapper(child: page)).toList(),
      ),
      bottomNavigationBar: const NavBarWidget(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

// ويدجت مساعدة للحفاظ على حالة الصفحات
class KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const KeepAliveWrapper({super.key, required this.child});

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
