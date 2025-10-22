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
              RelatedCourses(
                relatedCourses: _getRelatedCourses(),
                onCourseTap: _navigateToCourseDetails,
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),
            ],
          ),
        );
      },
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
      {
        'title': 'التسويق الرقمي الشامل',
        'image': 'https://picsum.photos/seed/marketing/400/300',
        'teacher': 'خالد حسن',
        'category': 'تسويق',
        'rating': 4.9,
        'reviews': 1563,
        'students': '12,459',
        'duration': 32,
        'lessons': 52,
        'level': 'متوسط',
        'lastUpdated': 'يناير 2025',
        'price': '150,000 S.P',
        'description': 'تعلم استراتيجيات التسويق الرقمي الفعالة لتعزيز وجودك على الإنترنت.',
        'tags': ['Digital Marketing', 'SEO', 'Social Media'],
        'instructorImage': 'https://picsum.photos/seed/instructor4/200/200',
      },
      {
        'title': 'إدارة المشاريع الاحترافية',
        'image': 'https://picsum.photos/seed/project/400/300',
        'teacher': 'سارة عبدالله',
        'category': 'إدارة',
        'rating': 4.7,
        'reviews': 734,
        'students': '6,892',
        'duration': 30,
        'lessons': 48,
        'level': 'متقدم',
        'lastUpdated': 'ديسمبر 2024',
        'price': '750,000 S.P',
        'description': 'إتقان مهارات إدارة المشاريع باستخدام منهجيات Agile و Scrum.',
        'tags': ['Project Management', 'Agile', 'Scrum'],
        'instructorImage': 'https://picsum.photos/seed/instructor5/200/200',
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