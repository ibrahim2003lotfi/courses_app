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
    // Ensure the course has an ID for state management
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
          backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
          body: BlocBuilder<CourseManagementBloc, CourseManagementState>(
            builder: (context, courseState) {
              final isEnrolled = courseState.enrolledCourses
                  .any((course) => course['id'] == widget.course['id']);
              
              if (isEnrolled) {
                final enrolledCourse = courseState.enrolledCourses
                    .firstWhere((course) => course['id'] == widget.course['id']);
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
        const SliverToBoxAdapter(
          child: SizedBox(height: 40),
        ),
      ],
    );
  }

  Widget _buildEnrolledCourseView(BuildContext context, Map<String, dynamic> enrolledCourse) {
    return CustomScrollView(
      slivers: [
        EnrolledCourseHeader(course: enrolledCourse),
        CourseProgressWidget(course: enrolledCourse),
        SliverToBoxAdapter(
          child: _buildContinueLearningButton(context, enrolledCourse),
        ),
        LessonsListWidget(course: enrolledCourse),
        const SliverToBoxAdapter(
          child: SizedBox(height: 40),
        ),
      ],
    );
  }

  Widget _buildContinueLearningButton(BuildContext context, Map<String, dynamic> course) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        final currentLesson = course['currentLesson'] ?? 0;
        final totalLessons = course['lessons'] ?? 1;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 60,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'واصل التعلم',
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'المحاضرة ${currentLesson + 1} من $totalLessons',
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'استمر',
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
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

  void _playLesson(BuildContext context, int lessonIndex, Map<String, dynamic> course) {
    // This would navigate to actual video player in real app
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'فتح مشغل الفيديو للمحاضرة ${lessonIndex + 1}',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
        'description': 'دورة شاملة لتعلم Flutter من الصفر حتى الاحتراف. ستتعلم بناء تطبيقات متقدمة باستخدام أحدث التقنيات.',
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
        'description': 'دورة متكاملة لتعلم أساسيات UI/UX Design مع مشاريع عملية.',
        'tags': ['UI/UX', 'Design', 'Figma', 'Prototype'],
        'instructorImage': 'https://picsum.photos/seed/instructor3/200/200',
      },
    ];
  }
}