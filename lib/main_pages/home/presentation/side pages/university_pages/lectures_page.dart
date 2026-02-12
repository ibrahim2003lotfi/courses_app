import 'package:courses_app/main_pages/courses/presentation/pages/course_details_page.dart';
import 'package:courses_app/presentation/widgets/course_image_widget.dart';
import 'package:courses_app/presentation/widgets/skeleton_widgets.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../bloc/university_bloc.dart';

class LecturesPage extends StatelessWidget {
  final String facultyName;
  final String universityName;
  final String universityId;
  final String facultyId;

  const LecturesPage({
    super.key,
    required this.facultyName,
    required this.universityName,
    required this.universityId,
    required this.facultyId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          UniversityBloc()
            ..add(LoadFacultyCoursesEvent(universityId, facultyId)),
      child: _LecturesPageBody(
        facultyName: facultyName,
        universityName: universityName,
      ),
    );
  }
}

class _LecturesPageBody extends StatelessWidget {
  final String facultyName;
  final String universityName;

  const _LecturesPageBody({
    required this.facultyName,
    required this.universityName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;

        return Scaffold(
          backgroundColor: isDarkMode
              ? const Color(0xFF121212)
              : const Color(0xFFF9FAFB),
          body: BlocBuilder<UniversityBloc, UniversityState>(
            builder: (context, uniState) {
              final courses = uniState.courses;

              return CustomScrollView(
                slivers: [
                  // Page Header with Back Button
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF1E1E1E)
                            : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              isDarkMode ? 0.2 : 0.05,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            // Back Button
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF667EEA),
                                    Color(0xFF764BA2),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () => Navigator.pop(context),
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Title
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'مواد $facultyName',
                                    style: GoogleFonts.tajawal(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: isDarkMode
                                          ? Colors.white
                                          : const Color(0xFF1F2937),
                                    ),
                                  ),
                                  Text(
                                    universityName,
                                    style: GoogleFonts.tajawal(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDarkMode
                                          ? Colors.white70
                                          : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: LecSearchField(isDarkMode: isDarkMode),
                    ),
                  ),

                  if (uniState.isLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: SkeletonList(itemCount: 6),
                      ),
                    )
                  else if (courses.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text('لا توجد محاضرات متاحة حالياً'),
                        ),
                      ),
                    )
                  else
                    // Lectures List (mapped from university courses)
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final course =
                            courses[index]
                                as Map<String, dynamic>; // from backend
                        return Padding(
                          padding: EdgeInsets.fromLTRB(
                            20,
                            index == 0 ? 0 : 0,
                            20,
                            16,
                          ),
                          child: LectureListItem(
                            course: course,
                            facultyName: facultyName,
                          ),
                        );
                      }, childCount: courses.length),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class LectureListItem extends StatelessWidget {
  final Map<String, dynamic> course;
  final String facultyName;

  const LectureListItem({
    super.key,
    required this.course,
    required this.facultyName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;

        return Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              border: isDarkMode ? Border.all(color: Colors.white30) : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GestureDetector(
                onTap: () {
                  _navigateToCourseDetails(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Course Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildCourseImage(),
                      ),

                      const SizedBox(width: 12),

                      // Lecture Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Lecture Title
                            Text(
                              course['title'] ?? 'مادة',
                              style: GoogleFonts.tajawal(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDarkMode
                                    ? Colors.white
                                    : const Color(0xFF1F2937),
                              ),
                            ),

                            const SizedBox(height: 4),

                            // Lecture Description
                            Text(
                              course['description'] ??
                                  _getLectureDescription(1, facultyName),
                              style: GoogleFonts.tajawal(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode
                                    ? Colors.white70
                                    : const Color(0xFF6B7280),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 8),

                            // Lecture Metadata
                            Row(
                              children: [
                                // Duration
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: isDarkMode
                                          ? Colors.white70
                                          : const Color(0xFF6B7280),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_getLectureDuration(1)} دقيقة',
                                      style: GoogleFonts.tajawal(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDarkMode
                                            ? Colors.white70
                                            : const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(width: 16),

                                // Date
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: isDarkMode
                                          ? Colors.white70
                                          : const Color(0xFF6B7280),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getLectureDate(1),
                                      style: GoogleFonts.tajawal(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDarkMode
                                            ? Colors.white70
                                            : const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCourseImage() {
    final imageUrl = course['course_image_url'] ?? course['image'] ?? '';

    if (imageUrl.isNotEmpty) {
      return CourseImageWidget(
        imageUrl: imageUrl,
        width: 100,
        height: 80,
        borderRadius: BorderRadius.circular(12),
        placeholderIcon: Icons.school_outlined,
      );
    }
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 100,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.school, size: 32, color: Colors.white),
    );
  }

  void _navigateToCourseDetails(BuildContext context) {
    // Map university course data to CourseDetailsPage expected format
    final mappedCourse = {
      'id': course['id'] ?? '',
      'title': course['title'] ?? course['name'] ?? 'Untitled',
      'image': course['course_image_url'] ?? course['image'] ?? '',
      'category': course['category_name'] ?? course['category'] ?? 'عام',
      'category_id': course['category_id'] ?? '',
      'teacher': course['instructor_name'] ?? course['teacher'] ?? 'مدرس',
      'rating': (course['rating'] ?? 0).toDouble(),
      'total_ratings': course['total_ratings'] ?? 0,
      'total_students': course['total_students'] ?? course['students'] ?? 0,
      'duration_hours': course['duration_hours'] ?? course['duration'] ?? 0,
      'lessons_count': course['lessons_count'] ?? course['lessons'] ?? 0,
      'level': course['level'] ?? 'متوسط',
      'updated_at': course['updated_at'] ?? '2026',
      'price': course['price']?.toString() ?? '0',
      'description': course['description'] ?? '',
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailsPage(course: mappedCourse),
      ),
    );
  }

  String _getLectureDescription(int lectureNumber, String facultyName) {
    final descriptions = {
      1: 'مقدمة في المواد الأساسية والتخصصية للفصل الدراسي الأول',
      2: 'الأسس النظرية والتطبيقية للمادة مع أمثلة عملية',
      3: 'التطبيقات العملية والتمارين التفاعلية',
      4: 'مراجعة شاملة وتحضير للاختبارات',
      5: 'مشاريع عملية وتطبيقات حقيقية',
      6: 'حلول ونماذج الاختبارات السابقة',
      7: 'ورشة عمل تفاعلية مع المحاضر',
      8: 'ملخص شامل للمادة قبل الاختبار النهائي',
    };
    return descriptions[lectureNumber] ?? 'محاضرة في $facultyName';
  }

  int _getLectureDuration(int lectureNumber) {
    return 45 + (lectureNumber * 5); // 50, 55, 60, etc.
  }

  String _getLectureDate(int lectureNumber) {
    final dates = [
      '2024-01-15',
      '2024-01-22',
      '2024-01-29',
      '2024-02-05',
      '2024-02-12',
      '2024-02-19',
      '2024-02-26',
      '2024-03-04',
    ];
    return dates[lectureNumber - 1];
  }

  void _showLectureDetails(
    BuildContext context,
    int lectureNumber,
    bool isDarkMode,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LectureDetailsSheet(
        lectureNumber: lectureNumber,
        facultyName: facultyName,
        isDarkMode: isDarkMode,
      ),
    );
  }
}

class LectureDetailsSheet extends StatelessWidget {
  final int lectureNumber;
  final String facultyName;
  final bool isDarkMode;

  const LectureDetailsSheet({
    super.key,
    required this.lectureNumber,
    required this.facultyName,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Lecture header
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.play_circle_filled,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مادة $lectureNumber',
                      style: GoogleFonts.tajawal(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDarkMode
                            ? Colors.white
                            : const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      facultyName,
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? Colors.white70
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Lecture info
          _buildInfoRow(
            'المدة',
            '${_getLectureDuration(lectureNumber)} دقيقة',
            isDarkMode,
          ),
          _buildInfoRow(
            'التاريخ',
            _getFormattedDate(lectureNumber),
            isDarkMode,
          ),
          _buildInfoRow('الحالة', 'متاحة', isDarkMode),
          _buildInfoRow('النوع', 'فيديو', isDarkMode),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pop(context);
                      _playLecture(context);
                    },
                    child: Center(
                      child: Text(
                        'الانتقال الى المحاضرات',
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.white30
                          : const Color(0xFFD1D5DB),
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.pop(context),
                    child: Center(
                      child: Text(
                        'إلغاء',
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.w700,
                          color: isDarkMode
                              ? Colors.white70
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  int _getLectureDuration(int lectureNumber) {
    return 45 + (lectureNumber * 5);
  }

  String _getFormattedDate(int lectureNumber) {
    final dates = [
      '15 يناير 2024',
      '22 يناير 2024',
      '29 يناير 2024',
      '5 فبراير 2024',
      '12 فبراير 2024',
      '19 فبراير 2024',
      '26 فبراير 2024',
      '4 مارس 2024',
    ];
    return dates[lectureNumber - 1];
  }

  void _playLecture(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('الانتقال الى مادة $lectureNumber'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }
}

class LecSearchField extends StatefulWidget {
  final bool isDarkMode;

  const LecSearchField({super.key, required this.isDarkMode});

  @override
  State<LecSearchField> createState() => _LecSearchFieldState();
}

class _LecSearchFieldState extends State<LecSearchField> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        child: TextField(
          controller: _controller,
          style: GoogleFonts.tajawal(
            fontWeight: _hasText ? FontWeight.w700 : FontWeight.w500,
            fontSize: 16,
            color: widget.isDarkMode ? Colors.white : const Color(0xFF1F2937),
          ),
          decoration: InputDecoration(
            hintText: 'ابحث عن الكورسات, المحاضرات, و الدروس',
            hintStyle: GoogleFonts.tajawal(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: widget.isDarkMode
                  ? Colors.white70
                  : const Color(0xFF6B7280),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: widget.isDarkMode
                  ? Colors.white70
                  : const Color(0xFF6B7280),
            ),
            filled: true,
            fillColor: widget.isDarkMode
                ? const Color(0xFF2D2D2D)
                : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: widget.isDarkMode
                    ? const Color(0xFF34D399)
                    : const Color(0xFF10B981),
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
