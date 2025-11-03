import 'package:courses_app/bloc/course_management_bloc.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

// Enrolled Course Header
class EnrolledCourseHeader extends StatelessWidget {
  final Map<String, dynamic> course;

  const EnrolledCourseHeader({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    course['image'],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF3F4F6),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDarkMode ? Colors.white70 : const Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.black.withOpacity(0.2),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              BlocBuilder<CourseManagementBloc, CourseManagementState>(
                builder: (context, state) {
                  final isInWatchLater = state.watchLaterCourses
                      .any((c) => c['id'] == course['id']);
                  
                  return IconButton(
                    icon: Icon(
                      isInWatchLater ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      context.read<CourseManagementBloc>().add(
                        ToggleWatchLaterEvent(course),
                      );
                      
                      // Show snackbar feedback
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isInWatchLater ? 'تمت إزالة الدورة من قائمة المشاهدة لاحقاً' : 'تمت إضافة الدورة إلى قائمة المشاهدة لاحقاً',
                            style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: isInWatchLater ? Colors.orange : Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// Course Progress Widget
class CourseProgressWidget extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseProgressWidget({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        final progress = course['progress'] ?? 0.0;
        final totalLessons = course['lessons'] ?? 1;
        final completedLessons = (progress * totalLessons).round();

        return Directionality(
          textDirection: TextDirection.rtl,
          child: SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        'تقدمك في الكورس',
                        style: GoogleFonts.tajawal(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                        ),
                        child: Text(
                          '${(progress * 100).toInt()}%',
                          style: GoogleFonts.tajawal(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF065F46),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    color: const Color(0xFF10B981),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        '$completedLessons / $totalLessons محاضرة مكتملة',
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        'بدأت في ${_formatDate(course['enrolledAt'])}',
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white60 : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'تاريخ غير معروف';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'تاريخ غير معروف';
    }
  }
}

// Lessons List Widget
class LessonsListWidget extends StatelessWidget {
  final Map<String, dynamic> course;

  const LessonsListWidget({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final totalLessons = course['lessons'] ?? 10;
    final currentLesson = course['currentLesson'] ?? 0;
    final progress = course['progress'] ?? 0.0;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _buildLessonItem(context, index, totalLessons, currentLesson, progress);
        },
        childCount: totalLessons,
      ),
    );
  }

  Widget _buildLessonItem(BuildContext context, int index, int totalLessons, int currentLesson, double progress) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        final isCompleted = index < (progress * totalLessons);
        final isCurrent = index == currentLesson;
        final isLocked = index > currentLesson && !isCompleted;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.1 : 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              border: isCurrent ? Border.all(
                color: const Color(0xFF3B82F6),
                width: 2,
              ) : null,
            ),
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isCompleted ? const Color(0xFF10B981) : 
                         isCurrent ? const Color(0xFF3B82F6) : 
                         isLocked ? Colors.grey[400] : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted ? Icons.check : 
                             isCurrent ? Icons.play_arrow : 
                             isLocked ? Icons.lock_outline : Icons.play_circle_outline,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              title: Text(
                'المحاضرة ${index + 1}: ${_getLessonTitle(index, totalLessons)}',
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : const Color(0xFF374151),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_getLessonDuration(index)} دقيقة',
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                    ),
                  ),
                  if (isCompleted) ...[
                    const SizedBox(height: 2),
                    Text(
                      'مكتملة',
                      style: GoogleFonts.tajawal(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ] else if (isCurrent) ...[
                    const SizedBox(height: 2),
                    Text(
                      'المحاضرة الحالية',
                      style: GoogleFonts.tajawal(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ],
              ),
              trailing: Icon(
                Icons.play_circle_filled,
                color: isLocked ? 
                      (isDarkMode ? Colors.grey[500] : Colors.grey[400]) : 
                      const Color(0xFF10B981),
                size: 32,
              ),
              onTap: isLocked ? null : () {
                _playLesson(context, index, course);
              },
            ),
          ),
        );
      },
    );
  }

  String _getLessonTitle(int index, int totalLessons) {
    final titles = [
      'مقدمة في الكورس وأهداف التعلم',
      'الأساسيات والمفاهيم الرئيسية',
      'التطبيق العملي والمشاريع',
      'تقنيات متقدمة واستراتيجيات',
      'نصائح الخبراء والتطبيقات العملية',
      'مراجعة شاملة وتقييم النتائج',
    ];
    
    if (index == 0) return titles[0];
    if (index == totalLessons - 1) return titles[5];
    if (index < totalLessons / 3) return titles[1];
    if (index < (totalLessons * 2) / 3) return titles[2];
    return titles[3];
  }

  String _getLessonDuration(int index) {
    // Vary duration between 15-45 minutes
    final baseDuration = 15 + (index % 3) * 10;
    return (baseDuration + (index ~/ 5) * 5).toString();
  }

  void _playLesson(BuildContext context, int lessonIndex, Map<String, dynamic> course) {
    // Update progress
    final totalLessons = course['lessons'] ?? 1;
    final newProgress = ((lessonIndex + 1) / totalLessons).clamp(0.0, 1.0);
    
    context.read<CourseManagementBloc>().add(
      UpdateCourseProgressEvent(
        courseId: course['id'],
        progress: newProgress,
        currentLesson: lessonIndex,
      ),
    );
    
    // Show video player (simulated)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تشغيل المحاضرة ${lessonIndex + 1}: ${_getLessonTitle(lessonIndex, totalLessons)}',
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
}