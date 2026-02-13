import 'package:courses_app/bloc/course_management_bloc.dart';
import 'package:courses_app/main_pages/player/presentation/pages/video_player_page.dart';
import 'package:courses_app/presentation/widgets/course_image_widget.dart';
import 'package:courses_app/services/connectivity_service.dart';
import 'package:courses_app/services/course_api.dart';
import 'package:courses_app/services/video_download_service.dart';
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
                  CourseImageWidget(
                    imageUrl: course['image']?.toString(),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholderIcon: Icons.play_circle_outline,
                    showPlaceholderText: true,
                    placeholderText: 'صورة الدورة غير متوفرة',
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
class LessonsListWidget extends StatefulWidget {
  final Map<String, dynamic> course;
  final bool isEnrolled;

  const LessonsListWidget({
    super.key, 
    required this.course,
    this.isEnrolled = false,
  });

  @override
  State<LessonsListWidget> createState() => _LessonsListWidgetState();
}

class _LessonsListWidgetState extends State<LessonsListWidget> {
  final VideoDownloadService _downloadService = VideoDownloadService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final Map<String, bool> _isDownloaded = {};
  final Map<String, bool> _isDownloading = {};
  final Map<String, double> _downloadProgress = {};
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _checkDownloadedVideos();
    _loadDownloadedVideosInfo();
  }

  Future<void> _loadDownloadedVideosInfo() async {
    final courseId = widget.course['id']?.toString() ?? '';
    if (courseId.isNotEmpty) {
      final downloadedVideos = await _downloadService.getDownloadedVideosForCourse(courseId);
      if (mounted) {
        setState(() {
          _downloadedVideosInfo = downloadedVideos;
        });
      }
    }
  }

  List<Map<String, dynamic>> _downloadedVideosInfo = [];

  Future<void> _checkConnectivity() async {
    final isOnline = await _connectivityService.checkConnectivity();
    if (mounted) {
      setState(() {
        _isOffline = !isOnline;
      });
    }
  }

  Future<void> _checkDownloadedVideos() async {
    final sections = (widget.course['sections'] as List?) ?? [];
    final courseId = widget.course['id']?.toString() ?? '';

    for (final section in sections) {
      final lessons = (section['lessons'] as List?) ?? [];
      for (final lesson in lessons) {
        final lessonId = lesson['id']?.toString() ?? '';
        if (lessonId.isNotEmpty) {
          final isDownloaded = await _downloadService.isVideoDownloaded(courseId, lessonId);
          if (mounted) {
            setState(() {
              _isDownloaded['${courseId}_$lessonId'] = isDownloaded;
            });
          }
        }
      }
    }
  }

  Future<void> _downloadVideo(dynamic lesson) async {
    final courseId = widget.course['id']?.toString() ?? '';
    final lessonId = lesson['id']?.toString() ?? '';
    final lessonTitle = lesson['title']?.toString() ?? 'درس';
    final courseSlug = widget.course['slug']?.toString() ?? courseId;

    if (courseId.isEmpty || lessonId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'معلومات الدرس غير كاملة',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return;
    }

    final key = '${courseId}_$lessonId';
    
    setState(() {
      _isDownloading[key] = true;
      _downloadProgress[key] = 0.0;
    });

    String? videoUrl;
    try {
      final courseApi = CourseApi();
      final result = await courseApi.getLessonStream(courseSlug, lessonId);
      
      if (result['stream_url'] != null) {
        videoUrl = result['stream_url'] as String;
      } else if (result['video_url'] != null) {
        videoUrl = result['video_url'] as String;
      }
    } catch (e) {
      print('>>> Error fetching stream URL: $e');
    }

    if (videoUrl == null || videoUrl.isEmpty) {
      if (mounted) {
        setState(() {
          _isDownloading[key] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لا يمكن الوصول إلى الفيديو',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return;
    }

    final success = await _downloadService.downloadVideo(
      videoUrl: videoUrl,
      courseId: courseId,
      lessonId: lessonId,
      lessonTitle: lessonTitle,
      onProgress: (progress) {
        if (mounted) {
          setState(() {
            _downloadProgress[key] = progress;
          });
        }
      },
    );

    if (mounted) {
      setState(() {
        _isDownloading[key] = false;
        _isDownloaded[key] = success;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'تم تحميل "$lessonTitle" بنجاح' : 'فشل تحميل "$lessonTitle"',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _deleteVideo(dynamic lesson) async {
    final courseId = widget.course['id']?.toString() ?? '';
    final lessonId = lesson['id']?.toString() ?? '';
    final lessonTitle = lesson['title']?.toString() ?? 'درس';

    if (courseId.isEmpty || lessonId.isEmpty) return;

    final key = '${courseId}_$lessonId';
    
    final success = await _downloadService.deleteVideo(courseId, lessonId);
    
    if (mounted && success) {
      setState(() {
        _isDownloaded[key] = false;
        _downloadProgress[key] = 0.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم حذف "$lessonTitle"',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showDeleteConfirmation(dynamic lesson) {
    final lessonTitle = lesson['title']?.toString() ?? 'درس';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.delete_outline, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            Text(
              'حذف الفيديو',
              style: GoogleFonts.tajawal(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'هل تريد حذف "$lessonTitle" من التنزيلات؟',
          style: GoogleFonts.tajawal(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteVideo(lesson);
              },
              child: Text(
                'حذف',
                style: GoogleFonts.tajawal(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sections = (widget.course['sections'] as List?) ?? [];

    if (_isOffline) {
      // Offline: show downloaded videos only
      if (_downloadedVideosInfo.isNotEmpty) {
        return _buildDownloadedVideosList(context);
      }
      return _buildNoOfflineContentMessage(context);
    }

    // Online: show real sections from API or empty state
    if (sections.isEmpty) {
      return _buildNoContentMessage(context);
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final section = sections[index];
          return _buildSectionItem(context, section, index);
        },
        childCount: sections.length,
      ),
    );
  }

  Widget _buildNoContentMessage(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          final isDarkMode = themeState.isDarkMode;
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.1 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.video_library_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا يوجد محتوى متاح حالياً',
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : const Color(0xFF374151),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'سيتم إضافة الدروس قريباً',
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionItem(BuildContext context, dynamic section, int sectionIndex) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        final lessons = (section['lessons'] as List?) ?? [];
        
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF2D2D2D) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.folder_open,
                      color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        section['title'] ?? 'قسم ${sectionIndex + 1}',
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.white : const Color(0xFF374151),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${lessons.length} درس',
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...lessons.asMap().entries.map((entry) {
                final lessonIndex = entry.key;
                final lesson = entry.value;
                return _buildLessonItem(context, lesson, sectionIndex, lessonIndex);
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLessonItem(BuildContext context, dynamic lesson, int sectionIndex, int lessonIndex) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        final isCompleted = false;
        final isCurrent = sectionIndex == 0 && lessonIndex == 0;
        
        final courseId = widget.course['id']?.toString() ?? '';
        final lessonId = lesson['id']?.toString() ?? '';
        final key = '${courseId}_$lessonId';
        final downloaded = _isDownloaded[key] ?? false;
        final downloading = _isDownloading[key] ?? false;
        final progress = _downloadProgress[key] ?? 0.0;
        
        final isOfflineUndownloaded = _isOffline && !downloaded;
        final canPlay = !isOfflineUndownloaded;
        
        Widget downloadIcon;
        if (downloading) {
          downloadIcon = SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              value: progress > 0 ? progress : null,
              strokeWidth: 2,
              color: const Color(0xFF3B82F6),
            ),
          );
        } else if (downloaded) {
          downloadIcon = GestureDetector(
            onTap: () => _showDeleteConfirmation(lesson),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF10B981),
                size: 22,
              ),
            ),
          );
        } else if (!isOfflineUndownloaded) {
          downloadIcon = GestureDetector(
            onTap: () => _downloadVideo(lesson),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.download_outlined,
                color: Color(0xFF3B82F6),
                size: 22,
              ),
            ),
          );
        } else {
          downloadIcon = const Icon(
            Icons.download_outlined,
            color: Colors.grey,
            size: 22,
          );
        }
        
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isOfflineUndownloaded 
                  ? (isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[200])
                  : (isDarkMode ? const Color(0xFF1E1E1E) : Colors.white),
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
                         (isOfflineUndownloaded ? Colors.grey[400] : Colors.grey[300]),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted ? Icons.check : 
                  isCurrent ? Icons.play_arrow : 
                  (isOfflineUndownloaded ? Icons.wifi_off : Icons.play_circle_outline),
                  color: Colors.white,
                  size: 22,
                ),
              ),
              title: Text(
                lesson['title'] ?? 'درس ${lessonIndex + 1}',
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isOfflineUndownloaded 
                      ? (isDarkMode ? Colors.grey[600] : Colors.grey[500])
                      : (isDarkMode ? Colors.white : const Color(0xFF374151)),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (lesson['duration_seconds'] != null) ...[
                    Text(
                      _formatDuration(lesson['duration_seconds']),
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: isOfflineUndownloaded
                            ? (isDarkMode ? Colors.grey[700] : Colors.grey[400])
                            : (isDarkMode ? Colors.white70 : const Color(0xFF6B7280)),
                      ),
                    ),
                  ],
                  if (isOfflineUndownloaded) ...[
                    const SizedBox(height: 2),
                    Text(
                      'غير متوفر بدون إنترنت',
                      style: GoogleFonts.tajawal(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[500],
                      ),
                    ),
                  ] else if (isCompleted) ...[
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
                      'ابدأ هنا',
                      style: GoogleFonts.tajawal(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  downloadIcon,
                  const SizedBox(width: 8),
                  Icon(
                    Icons.play_circle_filled,
                    color: canPlay ? const Color(0xFF10B981) : Colors.grey[400],
                    size: 32,
                  ),
                ],
              ),
              onTap: canPlay ? () {
                _playVideoLesson(context, lesson, widget.course['slug'] ?? widget.course['id'].toString());
              } : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDownloadedVideosList(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final video = _downloadedVideosInfo[index];
          return _buildDownloadedVideoItem(context, video, index);
        },
        childCount: _downloadedVideosInfo.length,
      ),
    );
  }

  Widget _buildDownloadedVideoItem(BuildContext context, Map<String, dynamic> video, int index) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        final lessonTitle = video['lessonTitle'] ?? 'درس ${index + 1}';
        final lessonId = video['lessonId']?.toString() ?? '';
        final courseId = widget.course['id']?.toString() ?? '';

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
              border: index == 0 ? Border.all(
                color: const Color(0xFF3B82F6),
                width: 2,
              ) : null,
            ),
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: index == 0 ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  index == 0 ? Icons.play_arrow : Icons.check,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              title: Text(
                lessonTitle,
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
                    'محمل للعرض بدون إنترنت',
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: const Color(0xFF10B981),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (index == 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      'ابدأ هنا',
                      style: GoogleFonts.tajawal(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _showDeleteConfirmationForVideo(video),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Color(0xFF10B981),
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.play_circle_filled,
                    color: Color(0xFF10B981),
                    size: 32,
                  ),
                ],
              ),
              onTap: () {
                _playDownloadedVideo(context, video);
              },
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationForVideo(Map<String, dynamic> video) {
    final lessonTitle = video['lessonTitle']?.toString() ?? 'درس';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.delete_outline, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            Text(
              'حذف الفيديو',
              style: GoogleFonts.tajawal(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'هل تريد حذف "$lessonTitle" من التنزيلات؟',
          style: GoogleFonts.tajawal(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteDownloadedVideo(video);
              },
              child: Text(
                'حذف',
                style: GoogleFonts.tajawal(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDownloadedVideo(Map<String, dynamic> video) async {
    final courseId = video['courseId']?.toString() ?? '';
    final lessonId = video['lessonId']?.toString() ?? '';
    final lessonTitle = video['lessonTitle']?.toString() ?? 'درس';

    if (courseId.isEmpty || lessonId.isEmpty) return;

    final success = await _downloadService.deleteVideo(courseId, lessonId);

    if (mounted && success) {
      setState(() {
        _downloadedVideosInfo.removeWhere((v) => v['lessonId'] == lessonId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم حذف "$lessonTitle"',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _playDownloadedVideo(BuildContext context, Map<String, dynamic> video) {
    final lessonId = video['lessonId']?.toString() ?? '';
    final lessonTitle = video['lessonTitle'] ?? 'درس';
    final localPath = video['filePath']?.toString() ?? '';
    final courseSlug = widget.course['slug']?.toString() ?? widget.course['id']?.toString() ?? '';

    print('>>> PLAY DOWNLOADED: lessonId=$lessonId, localPath=$localPath');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerPage(
          courseSlug: courseSlug,
          lessonId: lessonId,
          lessonTitle: lessonTitle,
          lessonDescription: null,
          localVideoPath: localPath.isNotEmpty ? localPath : null,
        ),
      ),
    );
  }

  Widget _buildNoOfflineContentMessage(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          final isDarkMode = themeState.isDarkMode;
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.1 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.wifi_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا يوجد محتوى متوفر بدون إنترنت',
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : const Color(0xFF374151),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'قم بتحميل الفيديوهات عندما تكون متصلاً بالإنترنت للوصول إليها لاحقاً بدون اتصال',
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')} دقيقة';
    }
    return '$seconds ثانية';
  }

  void _playVideoLesson(BuildContext context, dynamic lesson, String courseSlug) async {
    final lessonId = lesson['id']?.toString() ?? '';
    final lessonTitle = lesson['title'] ?? 'درس';

    final courseId = widget.course['id']?.toString() ?? '';
    final localPath = await _downloadService.getLocalVideoPath(courseId, lessonId);

    print('>>> VIDEO: courseSlug=$courseSlug, lessonId=$lessonId');
    print('>>> VIDEO: localPath=$localPath');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerPage(
          courseSlug: courseSlug,
          lessonId: lessonId,
          lessonTitle: lessonTitle,
          lessonDescription: lesson['description'],
          localVideoPath: localPath,
        ),
      ),
    );
  }
}
