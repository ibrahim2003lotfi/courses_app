import 'package:courses_app/core/utils/theme_manager.dart';
import 'package:courses_app/main_pages/courses/presentation/widgets/favorite_courses_widgets.dart';
import 'package:courses_app/main_pages/home/presentation/widgets/home_page_widgets.dart';
import 'package:courses_app/presentation/widgets/skeleton_widgets.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:courses_app/bloc/user_role_bloc.dart';
import 'package:courses_app/bloc/course_management_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CoursesPage extends StatelessWidget {
  final int initialTabIndex;
  
  const CoursesPage({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserRoleBloc, UserRoleState>(
      builder: (context, roleState) {
        // Rebuild entire page when role changes
        return _CoursesPageContent(
          key: ValueKey(roleState.isTeacher), // Force rebuild when role changes
          isTeacher: roleState.isTeacher,
          initialTabIndex: initialTabIndex,
        );
      },
    );
  }
}

class _CoursesPageContent extends StatefulWidget {
  final bool isTeacher;
  final int initialTabIndex;

  const _CoursesPageContent({
    super.key,
    required this.isTeacher,
    this.initialTabIndex = 0,
  });

  @override
  State<_CoursesPageContent> createState() => _CoursesPageContentState();
}

class _CoursesPageContentState extends State<_CoursesPageContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.isTeacher ? 3 : 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildSkeletonLoading(bool isDarkMode) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SkeletonUniversityItem(isDarkMode: isDarkMode),
        );
      },
    );
  }

  // Helper method to get responsive font size
  double _getResponsiveFontSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 600) {
      return 26;
    } else if (width > 400) {
      return 22;
    } else {
      return 18;
    }
  }

  // Helper method to get responsive small font size
  double _getResponsiveSmallFontSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 600) {
      return 18;
    } else if (width > 400) {
      return 16;
    } else {
      return 14;
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseFontSize = _getResponsiveFontSize(context);
    final smallFontSize = _getResponsiveSmallFontSize(context);

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final bool isDarkMode = themeState.isDarkMode;
        final themeData = isDarkMode
            ? ThemeManager.darkTheme
            : ThemeManager.lightTheme;

        return Scaffold(
          backgroundColor: themeData.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // TopSearchBar widget
                const TopSearchBar(),

                // Custom AppBar with Tabs
                Container(
                  color: themeData.appBarTheme.backgroundColor,
                  child: Column(
                    children: [
                      // TabBar
                      TabBar(
                        controller: _tabController,
                        tabs: _buildTabs(widget.isTeacher, smallFontSize),
                        labelColor: themeData.colorScheme.primary,
                        unselectedLabelColor: isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[600],
                        indicatorColor: themeData.colorScheme.primary,
                        indicatorWeight: 3,
                      ),
                    ],
                  ),
                ),

                // TabBarView - Wrapped with BlocBuilder for course management state
                Expanded(
                  child: _isLoading
                      ? _buildSkeletonLoading(isDarkMode)
                      : BlocBuilder<CourseManagementBloc, CourseManagementState>(
                          builder: (context, courseState) {
                            return TabBarView(
                              controller: _tabController,
                              children: _buildTabViews(
                                context,
                                widget.isTeacher,
                                baseFontSize,
                                smallFontSize,
                                isDarkMode,
                                courseState,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildTabs(bool isTeacher, double smallFontSize) {
    final tabs = [
      Tab(
        icon: const Icon(Icons.school),
        child: Text(
          'المشتركة',
          style: GoogleFonts.tajawal(
            fontSize: smallFontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      Tab(
        icon: const Icon(Icons.watch_later),
        child: Text(
          'لاحقاً',
          style: GoogleFonts.tajawal(
            fontSize: smallFontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ];

    if (isTeacher) {
      tabs.add(
        Tab(
          icon: const Icon(Icons.publish),
          child: Text(
            'منشوراتي',
            style: GoogleFonts.tajawal(
              fontSize: smallFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return tabs;
  }

  List<Widget> _buildTabViews(
    BuildContext context,
    bool isTeacher,
    double baseFontSize,
    double smallFontSize,
    bool isDarkMode,
    CourseManagementState courseState, // Receive course state as parameter
  ) {
    final views = <Widget>[
      // Subscribed Tab - Uses actual enrolled courses from BLoC
      CoursesListView(
        courses: courseState.enrolledCourses,
        showProgress: true,
        emptyMessage: 'لم تشترك في أي دورة بعد',
        emptyDescription: 'ابدأ رحلتك التعليمية واشترك في دورة جديدة!',
        emptyIcon: Icons.school_outlined,
        baseFontSize: baseFontSize,
        smallFontSize: smallFontSize,
        isDarkMode: isDarkMode,
      ),
      // Watch Later Tab - Uses actual watch later courses from BLoC
      CoursesListView(
        courses: courseState.watchLaterCourses,
        showProgress: false,
        emptyMessage: 'لا توجد دورات محفوظة',
        emptyDescription: 'احفظ الدورات التي تود مشاهدتها لاحقاً!',
        emptyIcon: Icons.watch_later_outlined,
        baseFontSize: baseFontSize,
        smallFontSize: smallFontSize,
        isDarkMode: isDarkMode,
      ),
    ];

    if (isTeacher) {
      views.add(
        PublishedCoursesTab(
          courses: const [],
          baseFontSize: baseFontSize,
          smallFontSize: smallFontSize,
          isDarkMode: isDarkMode,
          parentContext: context,
        ),
      );
    }

    return views;
  }
}
