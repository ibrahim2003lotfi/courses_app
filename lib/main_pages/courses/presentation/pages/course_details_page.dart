import 'package:courses_app/bloc/course_management_bloc.dart';
import 'package:courses_app/main_pages/courses/presentation/widgets/courses_details_widgets.dart';
import 'package:courses_app/main_pages/courses/presentation/widgets/enrolled_course_widgets.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CourseDetailsPage extends StatefulWidget {
  final Map<String, dynamic> course;

  const CourseDetailsPage({super.key, required this.course});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  @override
  void initState() {
    super.initState();
    if (widget.course['id'] == null) {
      widget.course['id'] = 'course_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;

        return Scaffold(
          backgroundColor: isDarkMode
              ? const Color(0xFF121212)
              : const Color(0xFFF8FAFC),
          body: BlocBuilder<CourseManagementBloc, CourseManagementState>(
            builder: (context, courseState) {
              final isEnrolled = courseState.enrolledCourses.any(
                (course) => course['id'] == widget.course['id'],
              );

              if (isEnrolled) {
                final enrolledCourse = courseState.enrolledCourses.firstWhere(
                  (course) => course['id'] == widget.course['id'],
                );
                return _buildEnrolledCourseView(context, enrolledCourse);
              } else {
                return _buildCoursePreviewView(context);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildCoursePreviewView(BuildContext context) {
    return CustomScrollView(
      slivers: [
        CourseHeader(course: widget.course),
        CourseInfoCard(course: widget.course),
        CourseTabs(course: widget.course),
        RelatedCourses(
          relatedCourses: _getRelatedCourses(),
          onCourseTap: _navigateToCourseDetails,
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildEnrolledCourseView(
    BuildContext context,
    Map<String, dynamic> enrolledCourse,
  ) {
    return CustomScrollView(
      slivers: [
        EnrolledCourseHeader(course: enrolledCourse),
        CourseProgressWidget(course: enrolledCourse),
        SliverToBoxAdapter(
          child: _buildRatingSection(context, enrolledCourse),
        ),
        SliverToBoxAdapter(
          child: _buildContinueLearningButton(context, enrolledCourse),
        ),
        LessonsListWidget(
          course: enrolledCourse,
          isEnrolled: true, // This unlocks all videos
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildRatingSection(
    BuildContext context,
    Map<String, dynamic> course,
  ) {
    final currentRating = course['userRating'] ?? 0.0;
    final hasRated = currentRating > 0;

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: 8,
            ),
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasRated ? 'تقييمك للدورة' : 'قيم هذه الدورة',
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w700,
                    fontSize: isMobile ? 18 : 20,
                    color: isDarkMode ? Colors.white : Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 12),
                isMobile 
                    ? _buildMobileRatingLayout(context, course, currentRating, hasRated, isDarkMode)
                    : _buildDesktopRatingLayout(context, course, currentRating, hasRated, isDarkMode),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileRatingLayout(
    BuildContext context,
    Map<String, dynamic> course,
    double currentRating,
    bool hasRated,
    bool isDarkMode,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStarRating(
              currentRating,
              onRatingChanged: (rating) {
                _rateCourse(context, course['id'], rating);
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    hasRated
                        ? 'شكراً لتقييمك!'
                        : 'كيف كانت تجربتك مع هذه الدورة؟',
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: isDarkMode
                          ? Colors.white70
                          : Color(0xFF666666),
                    ),
                    textAlign: TextAlign.right,
                  ),
                  if (hasRated) ...[
                    const SizedBox(height: 8),
                    Text(
                      'قيمتها بـ ${currentRating.toStringAsFixed(1)}/5',
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.amber,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (!hasRated) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (currentRating > 0) {
                  _rateCourse(context, course['id'], currentRating);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'تأكيد التقييم',
                style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDesktopRatingLayout(
    BuildContext context,
    Map<String, dynamic> course,
    double currentRating,
    bool hasRated,
    bool isDarkMode,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStarRating(
          currentRating,
          onRatingChanged: (rating) {
            _rateCourse(context, course['id'], rating);
          },
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                hasRated
                    ? 'شكراً لتقييمك!'
                    : 'كيف كانت تجربتك مع هذه الدورة؟',
                style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: isDarkMode
                      ? Colors.white70
                      : Color(0xFF666666),
                ),
                textAlign: TextAlign.right,
              ),
              if (hasRated) ...[
                const SizedBox(height: 8),
                Text(
                  'قيمتها بـ ${currentRating.toStringAsFixed(1)}/5',
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.amber,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ],
          ),
        ),
        if (!hasRated) ...[
          const SizedBox(width: 16),
          SizedBox(
            width: 120,
            child: ElevatedButton(
              onPressed: () {
                if (currentRating > 0) {
                  _rateCourse(context, course['id'], currentRating);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'تأكيد التقييم',
                style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStarRating(
    double currentRating, {
    required Function(double) onRatingChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            onRatingChanged(starIndex.toDouble());
          },
          icon: Icon(
            starIndex <= currentRating
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: Colors.amber,
            size: 32,
          ),
        );
      }),
    );
  }

  Widget _buildContinueLearningButton(
    BuildContext context,
    Map<String, dynamic> course,
  ) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        final currentLesson = course['currentLesson'] ?? 0;
        final totalLessons = course['lessons'] ?? 1;
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: 8,
            ),
            child: Container(
              height: isMobile ? 60 : 70,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF667EEA).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  _playLesson(context, currentLesson, course);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: isMobile ? 30 : 36,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'واصل التعلم',
                              style: GoogleFonts.tajawal(
                                fontWeight: FontWeight.w700,
                                fontSize: isMobile ? 16 : 18,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'المحاضرة ${currentLesson + 1} من $totalLessons',
                              style: GoogleFonts.tajawal(
                                fontWeight: FontWeight.w500,
                                fontSize: isMobile ? 12 : 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 16,
                          vertical: isMobile ? 6 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'استمر',
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.w700,
                            fontSize: isMobile ? 12 : 14,
                            color: Colors.white,
                          ),
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

  void _rateCourse(BuildContext context, String courseId, double rating) {
    context.read<CourseManagementBloc>().add(
          RateCourseEvent(
            courseId: courseId,
            rating: rating,
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'شكراً لتقييمك!',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _playLesson(
    BuildContext context,
    int lessonIndex,
    Map<String, dynamic> course,
  ) {
    // Navigate to video player - all videos are unlocked for enrolled users
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'فتح مشغل الفيديو للمحاضرة ${lessonIndex + 1}',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _navigateToCourseDetails(Map<String, dynamic> course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailsPage(course: course),
      ),
    );
  }

  List<Map<String, dynamic>> _getRelatedCourses() {
    return [
      {
        'id': 'related_1',
        'title': 'تعلم Flutter من الصفر إلى الاحتراف',
        'image': 'https://picsum.photos/seed/flutter/400/300',
        'teacher': 'أحمد محمد',
        'category': 'برمجة',
        'rating': 4.8,
        'reviews': 1247,
        'students': '10,258',
        'duration': 28,
        'lessons': 45,
        'level': 'متقدم',
        'lastUpdated': 'ديسمبر 2024',
        'price': '200,000 S.P',
        'description':
            'دورة شاملة لتعلم Flutter من الصفر حتى الاحتراف. ستتعلم بناء تطبيقات متقدمة باستخدام أحدث التقنيات.',
        'tags': ['Flutter', 'Dart', 'Mobile', 'Firebase'],
        'instructorImage': 'https://picsum.photos/seed/instructor2/200/200',
      },
      {
        'id': 'related_2',
        'title': 'UI/UX Design للمبتدئين',
        'image': 'https://picsum.photos/seed/design/400/300',
        'teacher': 'فاطمة علي',
        'category': 'تصميم',
        'rating': 4.6,
        'reviews': 892,
        'students': '8,745',
        'duration': 24,
        'lessons': 38,
        'level': 'مبتدئ',
        'lastUpdated': 'نوفمبر 2024',
        'price': '175,000 S.P',
        'description':
            'دورة متكاملة لتعلم أساسيات UI/UX Design مع مشاريع عملية.',
        'tags': ['UI/UX', 'Design', 'Figma', 'Prototype'],
        'instructorImage': 'https://picsum.photos/seed/instructor3/200/200',
      },
    ];
  }
}