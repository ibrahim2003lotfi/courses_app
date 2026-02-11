// published_courses_tab.dart
import 'package:courses_app/core/utils/theme_manager.dart';
import 'package:courses_app/main_pages/courses/presentation/pages/course_details_page.dart';
import 'package:courses_app/main_pages/courses/presentation/widgets/add_courses.dart';
import 'package:courses_app/services/course_api.dart';
import 'package:courses_app/presentation/widgets/skeleton_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// New Published Courses Tab Widget
class PublishedCoursesTab extends StatefulWidget {
  final List<Map<String, dynamic>> courses;
  final double baseFontSize;
  final double smallFontSize;
  final bool isDarkMode;
  final BuildContext parentContext; // Add this

  const PublishedCoursesTab({
    super.key,
    required this.courses,
    required this.baseFontSize,
    required this.smallFontSize,
    required this.isDarkMode,
    required this.parentContext, // Add this
  });

  @override
  State<PublishedCoursesTab> createState() => _PublishedCoursesTabState();
}

class _PublishedCoursesTabState extends State<PublishedCoursesTab> {
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _courses = const [];

  @override
  void initState() {
    super.initState();
    _courses = widget.courses;
    _loadPublishedCourses();
  }

  Future<void> _deleteCourseFromBackend(Map<String, dynamic> course) async {
    final courseId = course['id']?.toString();
    if (courseId == null || courseId.isEmpty) {
      return;
    }

    try {
      final api = CourseApi();
      final result = await api.deleteInstructorCourse(courseId);

      if (result['success'] == true) {
        await _loadPublishedCourses();
        if (mounted) {
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
        }
      } else {
        final msg = result['message'] ?? 'فشل حذف الدورة';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                msg,
                style: GoogleFonts.tajawal(
                  fontSize: widget.smallFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'فشل حذف الدورة: $e',
            style: GoogleFonts.tajawal(
              fontSize: widget.smallFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _loadPublishedCourses() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = CourseApi();
      final data = await api.getInstructorCourses();

      // Check if response contains an error
      if (data.containsKey('error')) {
        // Handle authentication errors
        if (data['error'] == 'no_user' || data['error'] == 'unauthenticated') {
          throw Exception('يجب تسجيل الدخول أولاً');
        }
        // Handle authorization errors
        if (data['error'] == 'unauthorized') {
          throw Exception(
            'ليس لديك صلاحية المعلم. يرجى التقدم بطلب للحصول على صلاحية المعلم',
          );
        }
        // Handle middleware errors
        if (data['error'] == 'middleware_error') {
          throw Exception('حدث خطأ في الخادم. يرجى المحاولة مرة أخرى');
        }
      }

      // Check if response is valid
      if (!data.containsKey('courses')) {
        throw Exception('Invalid response from server');
      }

      final raw =
          (data['courses'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      final mapped = raw.map<Map<String, dynamic>>((c) {
        final id = (c['id'] ?? '').toString();
        final instructorName = (c['instructor'] is Map)
            ? ((c['instructor'] as Map)['name'] ?? '').toString()
            : '';
        final categoryName = (c['category'] is Map)
            ? ((c['category'] as Map)['name'] ?? '').toString()
            : '';

        final totalStudents = c['total_students'] ?? 0;
        final price = c['price'] ?? 0;

        final courseImageUrl = (c['course_image_url'] ?? '').toString();

        // حقول إضافية نحتاجها في شاشة التعديل
        final description = (c['description'] ?? '').toString();
        final levelBackend = (c['level'] ?? '')
            .toString(); // beginner/intermediate/advanced

        return {
          'id': id,
          'title': (c['title'] ?? '').toString(),
          'description': description,
          'level_backend': levelBackend,
          'category_name': categoryName,
          'teacher': instructorName,
          'category': categoryName,
          'rating': (c['rating'] ?? 0).toDouble(),
          'students': totalStudents.toString(),
          'enrollments': totalStudents,
          'price': price.toString(),
          'status': 'نشط',
          'image': courseImageUrl.isNotEmpty
              ? courseImageUrl
              : 'https://picsum.photos/seed/published_$id/400/300',
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        _courses = mapped;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      // Log the error for debugging
      print('Error loading published courses: $e');
    }
  }

  String _getErrorMessage(String error) {
    // Convert technical errors to user-friendly Arabic messages
    if (error.contains('يجب تسجيل الدخول') ||
        error.contains('Unauthenticated') ||
        error.contains('no_user')) {
      return 'يجب تسجيل الدخول أولاً للمتابعة';
    }
    if (error.contains('ليس لديك صلاحية') ||
        error.contains('Unauthorized') ||
        error.contains('unauthorized')) {
      return 'ليس لديك صلاحية المعلم. يرجى التقدم بطلب للحصول على صلاحية المعلم';
    }
    if (error.contains('SocketException') ||
        error.contains('Connection refused') ||
        error.contains('Connection timed out')) {
      return 'لا يمكن الاتصال بالخادم. تأكد من تشغيل الخادم والاتصال بالإنترنت';
    }
    if (error.contains('timeout')) {
      return 'انتهت مهلة الاتصال. تحقق من اتصالك بالإنترنت وحاول مرة أخرى';
    }
    if (error.contains('Invalid response')) {
      return 'استجابة غير صالحة من الخادم. يرجى المحاولة مرة أخرى';
    }
    // Return the original error if no specific match found
    return error;
  }

  @override
  Widget build(BuildContext context) {
    // Use widget.parentContext for dialogs and navigation
    // ignore: unused_local_variable
    final themeData = widget.isDarkMode
        ? ThemeManager.darkTheme
        : ThemeManager.lightTheme;

    return Column(
      children: [
        // Add New Course Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height:
                56, // Matches the ElevatedButton height (16 vertical padding * 2 + content height)
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: () => _navigateToAddCoursePage(widget.parentContext),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'إضافة دورة جديدة',
                      style: GoogleFonts.tajawal(
                        fontSize: widget.baseFontSize * 0.8,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Courses List
        Expanded(
          child: _isLoading
              ? _buildSkeletonCourseList()
              : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'فشل تحميل دوراتك',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.tajawal(
                            fontSize: widget.baseFontSize,
                            fontWeight: FontWeight.w700,
                            color: themeData.colorScheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getErrorMessage(_error!),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.tajawal(
                            fontSize: widget.smallFontSize,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadPublishedCourses,
                          icon: const Icon(Icons.refresh),
                          label: Text(
                            'إعادة المحاولة',
                            style: GoogleFonts.tajawal(
                              fontSize: widget.smallFontSize,
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
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _courses.isEmpty
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
                          itemCount: _courses.length,
                          itemBuilder: (context, index) {
                            return PublishedCourseCard(
                              course: _courses[index],
                              isGridView: true,
                              baseFontSize: widget.baseFontSize,
                              smallFontSize: widget.smallFontSize,
                              isDarkMode: widget.isDarkMode,
                              onTap: () => _showCourseOptionsBottomSheet(
                                widget.parentContext,
                                _courses[index],
                              ),
                            );
                          },
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _courses.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: PublishedCourseCard(
                            course: _courses[index],
                            isGridView: false,
                            baseFontSize: widget.baseFontSize,
                            smallFontSize: widget.smallFontSize,
                            isDarkMode: widget.isDarkMode,
                            onTap: () => _showCourseOptionsBottomSheet(
                              widget.parentContext,
                              _courses[index],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _navigateToAddCoursePage(BuildContext context) async {
    // Navigate to the add course page instead of showing a dialog
    final created = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCoursePage()),
    );

    if (created == true) {
      await _loadPublishedCourses();
    }
  }

  Widget _buildSkeletonCourseList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              // Image skeleton
              SkeletonContainer(
                width: 100,
                height: 80,
                borderRadius: 12,
                isLoading: true,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title skeleton
                    SkeletonContainer(
                      width: double.infinity,
                      height: 18,
                      borderRadius: 4,
                      isLoading: true,
                    ),
                    const SizedBox(height: 8),
                    // Subtitle skeleton
                    SkeletonContainer(
                      width: 120,
                      height: 14,
                      borderRadius: 4,
                      isLoading: true,
                    ),
                    const SizedBox(height: 8),
                    // Stats row skeleton
                    Row(
                      children: [
                        SkeletonContainer(
                          width: 60,
                          height: 12,
                          borderRadius: 4,
                          isLoading: true,
                        ),
                        const SizedBox(width: 16),
                        SkeletonContainer(
                          width: 50,
                          height: 12,
                          borderRadius: 4,
                          isLoading: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCourseOptionsBottomSheet(
    BuildContext context,
    Map<String, dynamic> course,
  ) {
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
          _navigateToEditCoursePage(context, course);
        },
        onDelete: () {
          Navigator.pop(context);
          _showDeleteConfirmationDialog(context, course);
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

  void _navigateToEditCoursePage(
    BuildContext context,
    Map<String, dynamic> course,
  ) {
    // فتح صفحة إضافة الدورة في وضع التعديل مع تعبئة بعض البيانات المتوفرة
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCoursePage(
          courseId: course['id']?.toString(),
          initialTitle: course['title']?.toString(),
          initialDescription: course['description']?.toString(),
          initialPrice: num.tryParse(course['price']?.toString() ?? ''),
          initialLevelBackend: course['level_backend']?.toString(),
          initialCategoryName: course['category_name']?.toString(),
          isEditing: true,
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    Map<String, dynamic> course,
  ) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        course: course,
        baseFontSize: widget.baseFontSize,
        smallFontSize: widget.smallFontSize,
        isDarkMode: widget.isDarkMode,
        onConfirm: () {
          Navigator.pop(context);
          _deleteCourseFromBackend(course);
        },
      ),
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
                course['image']?.toString().isNotEmpty == true 
                    ? course['image']
                    : 'https://picsum.photos/seed/course/400/300',
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
                  course['image']?.toString().isNotEmpty == true 
                      ? course['image']
                      : 'https://picsum.photos/seed/course/400/300',
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
                      course['image']?.toString().isNotEmpty == true 
                          ? course['image']
                          : 'https://picsum.photos/seed/course/400/300',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: isDarkMode
                              ? Colors.grey[800]
                              : Colors.grey[200],
                          child: Icon(
                            Icons.image,
                            size: 24,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      course['title'],
                      style: GoogleFonts.tajawal(
                        fontSize: baseFontSize * 0.8,
                        fontWeight: FontWeight.w900,
                        color: themeData.colorScheme.onBackground,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Options List
            _buildOptionItem(
              context: context,
              icon: Icons.visibility,
              title: 'عرض الدورة',
              onTap: onView,
            ),
            _buildOptionItem(
              context: context,
              icon: Icons.edit,
              title: 'تعديل الدورة',
              onTap: onEdit,
            ),
            _buildOptionItem(
              context: context,
              icon: Icons.bar_chart,
              title: 'إحصائيات الدورة',
              onTap: () {
                Navigator.pop(context);
                _showStatisticsDialog(context);
              },
            ),
            _buildOptionItem(
              context: context,
              icon: Icons.delete,
              title: 'حذف الدورة',
              titleColor: Colors.red,
              onTap: onDelete,
            ),

            const SizedBox(height: 16),

            // Cancel Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'إلغاء',
                    style: GoogleFonts.tajawal(
                      fontSize: smallFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    final themeData = isDarkMode
        ? ThemeManager.darkTheme
        : ThemeManager.lightTheme;

    return ListTile(
      leading: Icon(icon, color: titleColor ?? themeData.colorScheme.primary),
      title: Text(
        title,
        style: GoogleFonts.tajawal(
          fontSize: smallFontSize,
          fontWeight: FontWeight.w700,
          color: titleColor ?? themeData.colorScheme.onBackground,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showStatisticsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CourseStatisticsDialog(
        course: course,
        baseFontSize: baseFontSize,
        smallFontSize: smallFontSize,
        isDarkMode: isDarkMode,
      ),
    );
  }
}

// Course Statistics Dialog
class CourseStatisticsDialog extends StatelessWidget {
  final Map<String, dynamic> course;
  final double baseFontSize;
  final double smallFontSize;
  final bool isDarkMode;

  const CourseStatisticsDialog({
    super.key,
    required this.course,
    required this.baseFontSize,
    required this.smallFontSize,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = isDarkMode
        ? ThemeManager.darkTheme
        : ThemeManager.lightTheme;

    return Dialog(
      backgroundColor: themeData.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إحصائيات الدورة',
              style: GoogleFonts.tajawal(
                fontSize: baseFontSize,
                fontWeight: FontWeight.w900,
                color: themeData.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),

            _buildStatItem('عدد المشتركين', '${course['enrollments']}'),
            _buildStatItem('التقييم', '${course['rating']} ⭐'),
            _buildStatItem('عدد التقييمات', '${course['reviews']}'),
            _buildStatItem('الحالة', course['status']),
            _buildStatItem('آخر تحديث', course['lastUpdated']),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'حسناً',
                  style: GoogleFonts.tajawal(
                    fontSize: smallFontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    final themeData = isDarkMode
        ? ThemeManager.darkTheme
        : ThemeManager.lightTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: smallFontSize,
              fontWeight: FontWeight.w700,
              color: themeData.colorScheme.onBackground,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.tajawal(
              fontSize: smallFontSize,
              fontWeight: FontWeight.w500,
              color: themeData.colorScheme.primary,
            ),
          ),
        ],
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
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text(
            'حذف',
            style: GoogleFonts.tajawal(
              fontSize: smallFontSize,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// Existing CoursesListView Widget (keep as is)
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
    // ignore: unused_local_variable
    final themeData = isDarkMode
        ? ThemeManager.darkTheme
        : ThemeManager.lightTheme;

    return courses.isEmpty
        ? EmptyState(
            icon: emptyIcon,
            message: emptyMessage,
            description: emptyDescription,
            baseFontSize: baseFontSize,
            smallFontSize: smallFontSize,
            isDarkMode: isDarkMode,
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

// Existing CourseCard Widget (keep as is)
class CourseCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final themeData = isDarkMode
        ? ThemeManager.darkTheme
        : ThemeManager.lightTheme;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailsPage(course: course),
          ),
        );
      },
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
          child: Image.network(
            course['image']?.toString().isNotEmpty == true 
                ? course['image']
                : 'https://picsum.photos/seed/course/400/300',
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
                  Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    course['rating'].toString(),
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
              if (showProgress) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: course['progress'],
                  backgroundColor: isDarkMode
                      ? Colors.grey[700]
                      : Colors.grey[300],
                  color: themeData.colorScheme.primary,
                ),
                const SizedBox(height: 4),
                Text(
                  '${(course['progress'] * 100).toInt()}% مكتمل',
                  style: GoogleFonts.tajawal(
                    fontSize: smallFontSize * 0.7,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              course['image']?.toString().isNotEmpty == true 
                  ? course['image']
                  : 'https://picsum.photos/seed/course/400/300',
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
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      course['rating'].toString(),
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
                if (showProgress) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: course['progress'],
                    backgroundColor: isDarkMode
                        ? Colors.grey[700]
                        : Colors.grey[300],
                    color: themeData.colorScheme.primary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(course['progress'] * 100).toInt()}% مكتمل',
                    style: GoogleFonts.tajawal(
                      fontSize: smallFontSize * 0.7,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Existing EmptyState Widget (keep as is)
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
            Icon(
              icon,
              size: 80,
              color: isDarkMode ? Colors.grey[400] : Colors.grey,
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
            const SizedBox(height: 12),
            Text(
              description,
              style: GoogleFonts.tajawal(
                fontSize: smallFontSize,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
