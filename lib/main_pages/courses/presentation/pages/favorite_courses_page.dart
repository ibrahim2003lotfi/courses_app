import 'package:courses_app/core/utils/theme_manager.dart';
import 'package:courses_app/main_pages/courses/presentation/widgets/favorite_courses_widgets.dart';
import 'package:courses_app/main_pages/home/presentation/widgets/home_page_widgets.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:courses_app/bloc/user_role_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserRoleBloc, UserRoleState>(
      builder: (context, roleState) {
        // Rebuild entire page when role changes
        return _CoursesPageContent(
          key: ValueKey(roleState.isTeacher), // Force rebuild when role changes
          isTeacher: roleState.isTeacher,
        );
      },
    );
  }
}

class _CoursesPageContent extends StatefulWidget {
  final bool isTeacher;

  const _CoursesPageContent({super.key, required this.isTeacher});

  @override
  State<_CoursesPageContent> createState() => _CoursesPageContentState();
}

class _CoursesPageContentState extends State<_CoursesPageContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample data for different tabs
  final List<Map<String, dynamic>> subscribedCourses = [
    {
      'id': '1',
      'title': 'دورة Flutter المتقدمة - بناء تطبيقات احترافية',
      'image': 'https://picsum.photos/seed/flutter1/400/300',
      'teacher': 'أحمد محمد',
      'category': 'برمجة',
      'rating': 4.8,
      'reviews': 1247,
      'students': '10,258',
      'duration': 28,
      'lessons': 45,
      'level': 'متقدم',
      'lastUpdated': 'ديسمبر 2024',
      'price': '950,000 S.P',
      'progress': 0.65,
      'description':
          'هذه الدورة الشاملة تغطي جميع جوانب تطوير تطبيقات Flutter بشكل احترافي.',
      'tags': ['Flutter', 'Dart', 'Mobile', 'Firebase', 'API'],
      'instructorImage': 'https://picsum.photos/seed/instructor1/200/200',
    },
    {
      'id': '2',
      'title': 'تعلم React Native من الصفر',
      'image': 'https://picsum.photos/seed/react/400/300',
      'teacher': 'سارة أحمد',
      'category': 'برمجة',
      'rating': 4.6,
      'reviews': 892,
      'students': '7,543',
      'duration': 22,
      'lessons': 38,
      'level': 'مبتدئ',
      'lastUpdated': 'نوفمبر 2024',
      'price': '800,000 S.P',
      'progress': 0.32,
      'description': 'تعلم تطوير تطبيقات الهاتف المحمول باستخدام React Native.',
      'tags': ['React Native', 'JavaScript', 'Mobile'],
      'instructorImage': 'https://picsum.photos/seed/instructor2/200/200',
    },
    {
      'id': '3',
      'title': 'UI/UX Design للمبتدئين',
      'image': 'https://picsum.photos/seed/design1/400/300',
      'teacher': 'محمد علي',
      'category': 'تصميم',
      'rating': 4.9,
      'reviews': 1543,
      'students': '12,847',
      'duration': 18,
      'lessons': 32,
      'level': 'مبتدئ',
      'lastUpdated': 'يناير 2025',
      'price': '800,000 S.P',
      'progress': 0.78,
      'description': 'تعلم أساسيات تصميم واجهات المستخدم وتجربة المستخدم.',
      'tags': ['UI', 'UX', 'Design', 'Figma'],
      'instructorImage': 'https://picsum.photos/seed/instructor3/200/200',
    },
  ];

  final List<Map<String, dynamic>> watchLaterCourses = [
    {
      'id': '5',
      'title': 'إدارة المشاريع الاحترافية',
      'image': 'https://picsum.photos/seed/project/400/300',
      'teacher': 'خالد محمود',
      'category': 'إدارة',
      'rating': 4.5,
      'reviews': 432,
      'students': '3,210',
      'duration': 12,
      'lessons': 24,
      'level': 'متوسط',
      'lastUpdated': 'نوفمبر 2024',
      'price': '675,000 S.P',
      'description': 'تعلم أساسيات إدارة المشاريع وأدوات التخطيط والتنظيم.',
      'tags': ['Project Management', 'Planning', 'Leadership'],
      'instructorImage': 'https://picsum.photos/seed/instructor5/200/200',
    },
    {
      'id': '6',
      'title': 'تطوير مواقع الويب بـ HTML & CSS',
      'image': 'https://picsum.photos/seed/web/400/300',
      'teacher': 'مريم أحمد',
      'category': 'برمجة',
      'rating': 4.4,
      'reviews': 698,
      'students': '8,765',
      'duration': 20,
      'lessons': 35,
      'level': 'مبتدئ',
      'lastUpdated': 'أكتوبر 2024',
      'price': 'مجاني',
      'description': 'تعلم أساسيات تطوير مواقع الويب باستخدام HTML و CSS.',
      'tags': ['HTML', 'CSS', 'Web Development'],
      'instructorImage': 'https://picsum.photos/seed/instructor6/200/200',
    },
  ];

  final List<Map<String, dynamic>> publishedCourses = [
    {
      'id': 'p1',
      'title': 'دورة Flutter المتقدمة - بناء تطبيقات احترافية',
      'image': 'https://picsum.photos/seed/flutter1/400/300',
      'teacher': 'أحمد محمد',
      'category': 'برمجة',
      'rating': 4.8,
      'reviews': 1247,
      'students': '10,258',
      'duration': 28,
      'lessons': 45,
      'level': 'متقدم',
      'lastUpdated': 'ديسمبر 2024',
      'price': '800,000 S.P',
      'description':
          'هذه الدورة الشاملة تغطي جميع جوانب تطوير تطبيقات Flutter بشكل احترافي.',
      'tags': ['Flutter', 'Dart', 'Mobile', 'Firebase', 'API'],
      'instructorImage': 'https://picsum.photos/seed/instructor1/200/200',
      'createdAt': '2024-12-01',
      'status': 'نشط',
      'enrollments': 10258,
    },
    {
      'id': 'p2',
      'title': 'تعلم React Native من الصفر',
      'image': 'https://picsum.photos/seed/react/400/300',
      'teacher': 'سارة أحمد',
      'category': 'برمجة',
      'rating': 4.6,
      'reviews': 892,
      'students': '7,543',
      'duration': 22,
      'lessons': 38,
      'level': 'مبتدئ',
      'lastUpdated': 'نوفمبر 2024',
      'price': '650,000 S.P',
      'description': 'تعلم تطوير تطبيقات الهاتف المحمول باستخدام React Native.',
      'tags': ['React Native', 'JavaScript', 'Mobile'],
      'instructorImage': 'https://picsum.photos/seed/instructor2/200/200',
      'createdAt': '2024-11-15',
      'status': 'نشط',
      'enrollments': 7543,
    },
    {
      'id': 'p3',
      'title': 'UI/UX Design للمبتدئين',
      'image': 'https://picsum.photos/seed/design1/400/300',
      'teacher': 'محمد علي',
      'category': 'تصميم',
      'rating': 4.9,
      'reviews': 1543,
      'students': '12,847',
      'duration': 18,
      'lessons': 32,
      'level': 'مبتدئ',
      'lastUpdated': 'يناير 2025',
      'price': '400,000 S.P',
      'description': 'تعلم أساسيات تصميم واجهات المستخدم وتجربة المستخدم.',
      'tags': ['UI', 'UX', 'Design', 'Figma'],
      'instructorImage': 'https://picsum.photos/seed/instructor3/200/200',
      'createdAt': '2025-01-10',
      'status': 'مسودة',
      'enrollments': 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.isTeacher ? 3 : 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

                // TabBarView
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _buildTabViews(
                      context,
                      widget.isTeacher,
                      baseFontSize,
                      smallFontSize,
                      isDarkMode,
                    ),
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
  ) {
    final views = <Widget>[
      CoursesListView(
        courses: subscribedCourses,
        showProgress: true,
        emptyMessage: 'لم تشترك في أي دورة بعد',
        emptyDescription: 'ابدأ رحلتك التعليمية واشترك في دورة جديدة!',
        emptyIcon: Icons.school_outlined,
        baseFontSize: baseFontSize,
        smallFontSize: smallFontSize,
        isDarkMode: isDarkMode,
      ),
      CoursesListView(
        courses: watchLaterCourses,
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
          courses: publishedCourses,
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
