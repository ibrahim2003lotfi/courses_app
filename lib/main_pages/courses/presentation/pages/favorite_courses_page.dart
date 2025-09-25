import 'package:courses_app/core/utils/theme_manager.dart';
import 'package:courses_app/main_pages/courses/presentation/pages/course_details_page.dart';
import 'package:courses_app/main_pages/home/presentation/widgets/home_page_widgets.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage>
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
      'price': '₪299',
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
      'price': '₪199',
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
      'price': '₪149',
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
      'price': '₪129',
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

  // New published courses data
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
      'price': '₪299',
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
      'price': '₪199',
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
      'price': '₪149',
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
    _tabController = TabController(length: 3, vsync: this);
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
      // Tablet
      return 26;
    } else if (width > 400) {
      // Large phone
      return 22;
    } else {
      // Small phone
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

                // Custom AppBar with Tabs - without nested Scaffold
                Container(
                  color: themeData.appBarTheme.backgroundColor,
                  child: Column(
                    children: [
                      // TabBar
                      TabBar(
                        controller: _tabController,
                        tabs: [
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
                        ],
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
                    children: [
                      CoursesListView(
                        courses: subscribedCourses,
                        showProgress: true,
                        emptyMessage: 'لم تشترك في أي دورة بعد',
                        emptyDescription:
                            'ابدأ رحلتك التعليمية واشترك في دورة جديدة!',
                        emptyIcon: Icons.school_outlined,
                        baseFontSize: baseFontSize,
                        smallFontSize: smallFontSize,
                        isDarkMode: isDarkMode,
                      ),
                      CoursesListView(
                        courses: watchLaterCourses,
                        showProgress: false,
                        emptyMessage: 'لا توجد دورات محفوظة',
                        emptyDescription:
                            'احفظ الدورات التي تود مشاهدتها لاحقاً!',
                        emptyIcon: Icons.watch_later_outlined,
                        baseFontSize: baseFontSize,
                        smallFontSize: smallFontSize,
                        isDarkMode: isDarkMode,
                      ),
                      PublishedCoursesTab(
                        courses: publishedCourses,
                        baseFontSize: baseFontSize,
                        smallFontSize: smallFontSize,
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// New Published Courses Tab Widget
class PublishedCoursesTab extends StatefulWidget {
  final List<Map<String, dynamic>> courses;
  final double baseFontSize;
  final double smallFontSize;
  final bool isDarkMode;

  const PublishedCoursesTab({
    super.key,
    required this.courses,
    required this.baseFontSize,
    required this.smallFontSize,
    required this.isDarkMode,
  });

  @override
  State<PublishedCoursesTab> createState() => _PublishedCoursesTabState();
}

class _PublishedCoursesTabState extends State<PublishedCoursesTab> {
  void _showAddCourseDialog() {
    showDialog(
      context: context,
      builder: (context) => AddCourseDialog(
        baseFontSize: widget.baseFontSize,
        smallFontSize: widget.smallFontSize,
        isDarkMode: widget.isDarkMode,
        onCourseAdded: (newCourse) {
          // Handle adding new course to the list
          setState(() {
            // In a real app, you would add to your data source
          });
        },
      ),
    );
  }

  void _showCourseOptionsBottomSheet(Map<String, dynamic> course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CourseOptionsBottomSheet(
        course: course,
        baseFontSize: widget.baseFontSize,
        smallFontSize: widget.smallFontSize,
        isDarkMode: widget.isDarkMode,
        onEdit: () {
          Navigator.pop(context);
          _showEditCourseDialog(course);
        },
        onDelete: () {
          Navigator.pop(context);
          _showDeleteConfirmationDialog(course);
        },
        onView: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailsPage(course: course),
            ),
          );
        },
      ),
    );
  }

  void _showEditCourseDialog(Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder: (context) => AddCourseDialog(
        baseFontSize: widget.baseFontSize,
        smallFontSize: widget.smallFontSize,
        isDarkMode: widget.isDarkMode,
        courseToEdit: course,
        onCourseAdded: (editedCourse) {
          // Handle course editing
          setState(() {
            // In a real app, you would update your data source
          });
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        course: course,
        baseFontSize: widget.baseFontSize,
        smallFontSize: widget.smallFontSize,
        isDarkMode: widget.isDarkMode,
        onConfirm: () {
          Navigator.pop(context);
          // Handle course deletion
          setState(() {
            // In a real app, you would remove from your data source
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم حذف "${course['title']}" بنجاح',
                style: GoogleFonts.tajawal(
                  fontSize: widget.smallFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = widget.isDarkMode
        ? ThemeManager.darkTheme
        : ThemeManager.lightTheme;

    return Column(
      children: [
        // Add New Course Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _showAddCourseDialog,
            icon: const Icon(Icons.add),
            label: Text(
              'إضافة دورة جديدة',
              style: GoogleFonts.tajawal(
                fontSize: widget.baseFontSize * 0.8,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeData.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),

        // Courses List
        Expanded(
          child: widget.courses.isEmpty
              ? EmptyState(
                  icon: Icons.publish_outlined,
                  message: 'لا توجد دورات منشورة',
                  description: 'انقر على زر "إضافة دورة جديدة" لبدء النشر',
                  baseFontSize: widget.baseFontSize,
                  smallFontSize: widget.smallFontSize,
                  isDarkMode: widget.isDarkMode,
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isTablet = constraints.maxWidth > 600;

                    if (isTablet) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1.3,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: widget.courses.length,
                          itemBuilder: (context, index) {
                            return PublishedCourseCard(
                              course: widget.courses[index],
                              isGridView: true,
                              baseFontSize: widget.baseFontSize,
                              smallFontSize: widget.smallFontSize,
                              isDarkMode: widget.isDarkMode,
                              onTap: () => _showCourseOptionsBottomSheet(
                                widget.courses[index],
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      return ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: widget.courses.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: PublishedCourseCard(
                              course: widget.courses[index],
                              isGridView: false,
                              baseFontSize: widget.baseFontSize,
                              smallFontSize: widget.smallFontSize,
                              isDarkMode: widget.isDarkMode,
                              onTap: () => _showCourseOptionsBottomSheet(
                                widget.courses[index],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
        ),
      ],
    );
  }
}

// Published Course Card Widget
class PublishedCourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final bool isGridView;
  final double baseFontSize;
  final double smallFontSize;
  final bool isDarkMode;
  final VoidCallback onTap;

  const PublishedCourseCard({
    super.key,
    required this.course,
    required this.isGridView,
    required this.baseFontSize,
    required this.smallFontSize,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = isDarkMode
        ? ThemeManager.darkTheme
        : ThemeManager.lightTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: themeData.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isGridView
            ? _buildGridLayout(themeData)
            : _buildListLayout(themeData),
      ),
    );
  }

  Widget _buildGridLayout(ThemeData themeData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Course Image
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Stack(
            children: [
              Image.network(
                course['image'],
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    child: Icon(
                      Icons.image,
                      size: 40,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey,
                    ),
                  );
                },
              ),
              // Status Badge
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: course['status'] == 'نشط'
                        ? Colors.green
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    course['status'],
                    style: GoogleFonts.tajawal(
                      fontSize: smallFontSize * 0.7,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Course Info
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course['title'],
                style: GoogleFonts.tajawal(
                  fontSize: baseFontSize * 0.7,
                  fontWeight: FontWeight.w900,
                  color: themeData.colorScheme.onBackground,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                course['teacher'],
                style: GoogleFonts.tajawal(
                  fontSize: smallFontSize * 0.8,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 14,
                    color: themeData.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${course['enrollments']}',
                    style: GoogleFonts.tajawal(
                      fontSize: smallFontSize * 0.7,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    course['price'],
                    style: GoogleFonts.tajawal(
                      fontSize: smallFontSize * 0.8,
                      fontWeight: FontWeight.w900,
                      color: themeData.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListLayout(ThemeData themeData) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Course Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  course['image'],
                  width: 100,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 80,
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      child: Icon(
                        Icons.image,
                        size: 30,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              // Status Badge
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: course['status'] == 'نشط'
                        ? Colors.green
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    course['status'],
                    style: GoogleFonts.tajawal(
                      fontSize: smallFontSize * 0.6,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Course Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['title'],
                  style: GoogleFonts.tajawal(
                    fontSize: baseFontSize * 0.8,
                    fontWeight: FontWeight.w900,
                    color: themeData.colorScheme.onBackground,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  course['teacher'],
                  style: GoogleFonts.tajawal(
                    fontSize: smallFontSize,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 14,
                      color: themeData.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${course['enrollments']} مشترك',
                      style: GoogleFonts.tajawal(
                        fontSize: smallFontSize * 0.8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      course['price'],
                      style: GoogleFonts.tajawal(
                        fontSize: smallFontSize * 0.9,
                        fontWeight: FontWeight.w900,
                        color: themeData.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Icon(Icons.more_vert, color: Colors.grey),
        ],
      ),
    );
  }
}

// Add/Edit Course Dialog
class AddCourseDialog extends StatefulWidget {
  final double baseFontSize;
  final double smallFontSize;
  final bool isDarkMode;
  final Map<String, dynamic>? courseToEdit;
  final Function(Map<String, dynamic>) onCourseAdded;

  const AddCourseDialog({
    super.key,
    required this.baseFontSize,
    required this.smallFontSize,
    required this.isDarkMode,
    this.courseToEdit,
    required this.onCourseAdded,
  });

  @override
  State<AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<AddCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _teacherController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.courseToEdit != null) {
      _titleController.text = widget.courseToEdit!['title'];
      _teacherController.text = widget.courseToEdit!['teacher'];
      _priceController.text = widget.courseToEdit!['price'];
      _descriptionController.text = widget.courseToEdit!['description'];
      _categoryController.text = widget.courseToEdit!['category'];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _teacherController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newCourse = {
        'id':
            widget.courseToEdit?['id'] ??
            'p${DateTime.now().millisecondsSinceEpoch}',
        'title': _titleController.text,
        'teacher': _teacherController.text,
        'price': _priceController.text,
        'description': _descriptionController.text,
        'category': _categoryController.text,
        'image':
            'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/400/300',
        'rating': 4.5,
        'reviews': 0,
        'students': '0',
        'duration': 0,
        'lessons': 0,
        'level': 'مبتدئ',
        'lastUpdated': '2024',
        'status': 'مسودة',
        'enrollments': 0,
      };

      widget.onCourseAdded(newCourse);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = widget.isDarkMode
        ? ThemeManager.darkTheme
        : ThemeManager.lightTheme;

    return Dialog(
      backgroundColor: themeData.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.courseToEdit == null
                      ? 'إضافة دورة جديدة'
                      : 'تعديل الدورة',
                  style: GoogleFonts.tajawal(
                    fontSize: widget.baseFontSize,
                    fontWeight: FontWeight.w900,
                    color: themeData.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 24),

                _buildTextField(
                  controller: _titleController,
                  label: 'عنوان الدورة',
                  hintText: 'أدخل عنوان الدورة',
                  validator: (value) =>
                      value!.isEmpty ? 'يرجى إدخال العنوان' : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _teacherController,
                  label: 'اسم المدرس',
                  hintText: 'أدخل اسم المدرس',
                  validator: (value) =>
                      value!.isEmpty ? 'يرجى إدخال اسم المدرس' : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _categoryController,
                  label: 'الفئة',
                  hintText: 'أدخل فئة الدورة',
                  validator: (value) =>
                      value!.isEmpty ? 'يرجى إدخال الفئة' : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _priceController,
                  label: 'السعر',
                  hintText: 'أدخل سعر الدورة',
                  validator: (value) =>
                      value!.isEmpty ? 'يرجى إدخال السعر' : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _descriptionController,
                  label: 'الوصف',
                  hintText: 'أدخل وصف الدورة',
                  maxLines: 3,
                  validator: (value) =>
                      value!.isEmpty ? 'يرجى إدخال الوصف' : null,
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'إلغاء',
                          style: GoogleFonts.tajawal(
                            fontSize: widget.smallFontSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: Text(
                          widget.courseToEdit == null ? 'إضافة' : 'حفظ',
                          style: GoogleFonts.tajawal(
                            fontSize: widget.smallFontSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required String? Function(String?) validator,
    int maxLines = 1,
  }) {
    final themeData = widget.isDarkMode
        ? ThemeManager.darkTheme
        : ThemeManager.lightTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: widget.smallFontSize,
            fontWeight: FontWeight.w700,
            color: themeData.colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.tajawal(fontSize: widget.smallFontSize),
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

// Course Options Bottom Sheet
class CourseOptionsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> course;
  final double baseFontSize;
  final double smallFontSize;
  final bool isDarkMode;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onView;

  const CourseOptionsBottomSheet({
    super.key,
    required this.course,
    required this.baseFontSize,
    required this.smallFontSize,
    required this.isDarkMode,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = isDarkMode
        ? ThemeManager.darkTheme
        : ThemeManager.lightTheme;

    return Container(
      decoration: BoxDecoration(
        color: themeData.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with course image and title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      course['image'],
                      width: 80,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 60,
                          color: isDarkMode
                              ? Colors.grey[800]
                              : Colors.grey[200],
                          child: Icon(
                            Icons.image,
                            size: 30,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course['title'],
                          style: GoogleFonts.tajawal(
                            fontSize: baseFontSize * 0.8,
                            fontWeight: FontWeight.w900,
                            color: themeData.colorScheme.onBackground,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          course['teacher'],
                          style: GoogleFonts.tajawal(
                            fontSize: smallFontSize,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Action Buttons
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 400;

                if (isWide) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.edit,
                            text: 'تعديل',
                            color: Colors.blue,
                            onTap: onEdit,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.delete,
                            text: 'حذف',
                            color: Colors.red,
                            onTap: onDelete,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.visibility,
                            text: 'عرض',
                            color: Colors.green,
                            onTap: onView,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildActionButton(
                          icon: Icons.edit,
                          text: 'تعديل الدورة',
                          color: Colors.blue,
                          onTap: onEdit,
                          isFullWidth: true,
                        ),
                        const SizedBox(height: 8),
                        _buildActionButton(
                          icon: Icons.delete,
                          text: 'حذف الدورة',
                          color: Colors.red,
                          onTap: onDelete,
                          isFullWidth: true,
                        ),
                        const SizedBox(height: 8),
                        _buildActionButton(
                          icon: Icons.visibility,
                          text: 'الانتقال إلى الدورة',
                          color: Colors.green,
                          onTap: onView,
                          isFullWidth: true,
                        ),
                      ],
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
    bool isFullWidth = false,
  }) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(
          text,
          style: GoogleFonts.tajawal(
            fontSize: smallFontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// Delete Confirmation Dialog
class DeleteConfirmationDialog extends StatelessWidget {
  final Map<String, dynamic> course;
  final double baseFontSize;
  final double smallFontSize;
  final bool isDarkMode;
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.course,
    required this.baseFontSize,
    required this.smallFontSize,
    required this.isDarkMode,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = isDarkMode
        ? ThemeManager.darkTheme
        : ThemeManager.lightTheme;

    return AlertDialog(
      backgroundColor: themeData.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'تأكيد الحذف',
        style: GoogleFonts.tajawal(
          fontSize: baseFontSize,
          fontWeight: FontWeight.w900,
          color: themeData.colorScheme.onBackground,
        ),
      ),
      content: Text(
        'هل أنت متأكد من أنك تريد حذف "${course['title']}"؟ لا يمكن التراجع عن هذا الإجراء.',
        style: GoogleFonts.tajawal(
          fontSize: smallFontSize,
          fontWeight: FontWeight.w500,
          color: themeData.colorScheme.onBackground,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'إلغاء',
            style: GoogleFonts.tajawal(
              fontSize: smallFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text(
            'حذف',
            style: GoogleFonts.tajawal(
              fontSize: smallFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// Existing classes remain the same...
class CoursesListView extends StatelessWidget {
  final List<Map<String, dynamic>> courses;
  final bool showProgress;
  final String emptyMessage;
  final String emptyDescription;
  final IconData emptyIcon;
  final double baseFontSize;
  final double smallFontSize;
  final bool isDarkMode;

  const CoursesListView({
    super.key,
    required this.courses,
    required this.showProgress,
    required this.emptyMessage,
    required this.emptyDescription,
    required this.emptyIcon,
    required this.baseFontSize,
    required this.smallFontSize,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return EmptyState(
        icon: emptyIcon,
        message: emptyMessage,
        description: emptyDescription,
        baseFontSize: baseFontSize,
        smallFontSize: smallFontSize,
        isDarkMode: isDarkMode,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;

        if (isTablet) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                return CourseCard(
                  course: courses[index],
                  showProgress: showProgress,
                  isGridView: true,
                  baseFontSize: baseFontSize,
                  smallFontSize: smallFontSize,
                  isDarkMode: isDarkMode,
                );
              },
            ),
          );
        } else {
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: CourseCard(
                  course: courses[index],
                  showProgress: showProgress,
                  isGridView: false,
                  baseFontSize: baseFontSize,
                  smallFontSize: smallFontSize,
                  isDarkMode: isDarkMode,
                ),
              );
            },
          );
        }
      },
    );
  }
}

class CourseCard extends StatefulWidget {
  final Map<String, dynamic> course;
  final bool showProgress;
  final bool isGridView;
  final double baseFontSize;
  final double smallFontSize;
  final bool isDarkMode;

  const CourseCard({
    super.key,
    required this.course,
    required this.showProgress,
    required this.isGridView,
    required this.baseFontSize,
    required this.smallFontSize,
    required this.isDarkMode,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool isSaved = false;

  @override
  Widget build(BuildContext context) {
    final themeData = widget.isDarkMode
        ? ThemeManager.darkTheme
        : ThemeManager.lightTheme;

    return Dismissible(
      key: Key(widget.course['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم حذف "${widget.course['title']}" من القائمة',
              style: GoogleFonts.tajawal(
                fontSize: widget.smallFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
            action: SnackBarAction(
              label: 'تراجع',
              onPressed: () {
                // Implement undo functionality
              },
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailsPage(course: widget.course),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: themeData.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(widget.isDarkMode ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: widget.isGridView
              ? _buildGridLayout(themeData)
              : _buildListLayout(themeData),
        ),
      ),
    );
  }

  Widget _buildGridLayout(ThemeData themeData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              widget.course['image'],
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: widget.isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[200],
                  child: Icon(
                    Icons.image,
                    size: 50,
                    color: widget.isDarkMode ? Colors.grey[400] : Colors.grey,
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.course['title'],
                  style: GoogleFonts.tajawal(
                    fontSize: widget.baseFontSize * 0.7,
                    fontWeight: FontWeight.w900,
                    color: themeData.colorScheme.onBackground,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.course['teacher'],
                  style: GoogleFonts.tajawal(
                    fontSize: widget.smallFontSize * 0.8,
                    fontWeight: FontWeight.w500,
                    color: widget.isDarkMode
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ),
                const Spacer(),
                if (widget.showProgress && widget.course['progress'] != null)
                  _buildProgressIndicator(themeData),
                _buildActionButtons(themeData),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListLayout(ThemeData themeData) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.course['image'],
              width: 120,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 120,
                  height: 80,
                  color: widget.isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[200],
                  child: Icon(
                    Icons.image,
                    size: 30,
                    color: widget.isDarkMode ? Colors.grey[400] : Colors.grey,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.course['title'],
                  style: GoogleFonts.tajawal(
                    fontSize: widget.baseFontSize * 0.8,
                    fontWeight: FontWeight.w900,
                    color: themeData.colorScheme.onBackground,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.course['teacher'],
                  style: GoogleFonts.tajawal(
                    fontSize: widget.smallFontSize,
                    fontWeight: FontWeight.w500,
                    color: widget.isDarkMode
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber[600]),
                    const SizedBox(width: 4),
                    Text(
                      widget.course['rating'].toString(),
                      style: GoogleFonts.tajawal(
                        fontSize: widget.smallFontSize * 0.8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.people,
                      size: 16,
                      color: widget.isDarkMode
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.course['students'],
                      style: GoogleFonts.tajawal(
                        fontSize: widget.smallFontSize * 0.8,
                        fontWeight: FontWeight.w500,
                        color: widget.isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (widget.showProgress &&
                    widget.course['progress'] != null) ...[
                  const SizedBox(height: 8),
                  _buildProgressIndicator(themeData),
                ],
                const SizedBox(height: 8),
                _buildActionButtons(themeData),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData themeData) {
    final progress = widget.course['progress'] ?? 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'التقدم',
              style: GoogleFonts.tajawal(
                fontSize: widget.smallFontSize * 0.8,
                fontWeight: FontWeight.w500,
                color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: GoogleFonts.tajawal(
                fontSize: widget.smallFontSize * 0.8,
                fontWeight: FontWeight.w900,
                color: themeData.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: widget.isDarkMode
              ? Colors.grey[700]
              : Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            themeData.colorScheme.primary,
          ),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData themeData) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Handle play action
            },
            icon: const Icon(Icons.play_arrow, size: 18),
            label: Text(
              'تشغيل',
              style: GoogleFonts.tajawal(
                fontSize: widget.smallFontSize * 0.8,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeData.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String description;
  final double baseFontSize;
  final double smallFontSize;
  final bool isDarkMode;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    required this.description,
    required this.baseFontSize,
    required this.smallFontSize,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = isDarkMode
        ? ThemeManager.darkTheme
        : ThemeManager.lightTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: GoogleFonts.tajawal(
                fontSize: baseFontSize,
                fontWeight: FontWeight.w900,
                color: themeData.colorScheme.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.tajawal(
                fontSize: smallFontSize,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to explore courses
              },
              icon: const Icon(Icons.explore),
              label: Text(
                'استكشف الدورات',
                style: GoogleFonts.tajawal(
                  fontSize: smallFontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeData.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
