import 'package:courses_app/data/notifiers.dart';
import 'package:courses_app/main_pages/courses/presentation/pages/favorite_courses_page.dart';
import 'package:courses_app/main_pages/home/presentation/pages/home_page.dart';
import 'package:courses_app/main_pages/profile/presentation/pages/profile_page.dart';
import 'package:courses_app/main_pages/search/presentation/pages/search_page.dart';
import 'package:courses_app/navbar/presentation/main_navbar_page.dart';
import 'package:courses_app/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/user_role_bloc.dart';

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
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _bootstrapRole();
  }

  Future<void> _bootstrapRole() async {
    try {
      // 1) Get role from backend
      final result = await _profileService.getMe();
      if (!mounted) return;

      String backendRole = '';
      if (result['status'] == 200) {
        final data = result['data'] as Map<String, dynamic>;
        final user = data['user'] as Map<String, dynamic>?;
        backendRole = (user?['role'] ?? '').toString().toLowerCase();
      }

      // 2) Get locally saved instructor flag (when user submitted instructor form)
      final prefs = await SharedPreferences.getInstance();
      final bool localInstructorFlag =
          prefs.getBool('is_local_instructor') ?? false;

      // 3) Decide effective role for UI
      final bool isInstructorFromBackend = backendRole == 'instructor';
      final bool isTeacher = isInstructorFromBackend || localInstructorFlag;

      if (isTeacher) {
        context.read<UserRoleBloc>().add(const BecomeTeacherEvent());
      } else {
        context.read<UserRoleBloc>().add(const ResetRoleEvent());
      }
    } catch (_) {
      // ignore bootstrap errors; app can still function without role preloading
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: ValueListenableBuilder<int>(
        valueListenable: selectedPageNotifier,
        builder: (context, selectedPage, _) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.92, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(selectedPage),
              child: pages[selectedPage],
            ),
          );
        },
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
