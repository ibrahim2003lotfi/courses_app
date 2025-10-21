import 'package:courses_app/main_pages/courses/presentation/widgets/courses_details_widgets.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CourseDetailsPage extends StatefulWidget {
  final Map<String, dynamic> course;

  const CourseDetailsPage({super.key, required this.course});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        
        return Scaffold(
          backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
          body: CustomScrollView(
            slivers: [
              CourseHeader(course: widget.course),
              CourseInfoCard(course: widget.course),
              CourseTabs(course: widget.course),
              RelatedCourses(relatedCourses: _getRelatedCourses()),
              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getRelatedCourses() {
    return [
      {
        'title': 'تعلم Flutter من الصفر إلى الاحتراف',
        'image': 'https://picsum.photos/seed/flutter/400/300',
        'rating': 4.8,
        'price': '200,000 S.P',
      },
      {
        'title': 'UI/UX Design للمبتدئين',
        'image': 'https://picsum.photos/seed/design/400/300',
        'rating': 4.6,
        'price': '175,000 S.P',
      },
      {
        'title': 'التسويق الرقمي الشامل',
        'image': 'https://picsum.photos/seed/marketing/400/300',
        'rating': 4.9,
        'price': '150,000 S.P',
      },
      {
        'title': 'إدارة المشاريع الاحترافية',
        'image': 'https://picsum.photos/seed/project/400/300',
        'rating': 4.7,
        'price': '750,000 S.P',
      },
    ];
  }
}

// Sample course data for testing
Map<String, dynamic> sampleCourse = {
  'title': 'دورة Flutter المتقدمة - بناء تطبيقات احترافية',
  'image': 'https://picsum.photos/seed/course/800/600',
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
  'description': 'هذه الدورة الشاملة تغطي جميع جوانب تطوير تطبيقات Flutter بشكل احترافي. ستتعلم كيفية بناء تطبيقات متقدمة باستخدام أحدث التقنيات والممارسات. تشمل الدورة مشاريع عملية وأمثلة واقعية.',
  'tags': ['Flutter', 'Dart', 'Mobile', 'Firebase', 'API'],
  'instructorImage': 'https://picsum.photos/seed/instructor/200/200',
};