import 'package:courses_app/bloc/course_management_bloc.dart';
import 'package:courses_app/main_pages/courses/presentation/widgets/courses_details_widgets.dart';
import 'package:courses_app/main_pages/courses/presentation/widgets/enrolled_course_widgets.dart';
import 'package:courses_app/main_pages/player/presentation/pages/video_player_page.dart';
import 'package:courses_app/presentation/widgets/skeleton_widgets.dart';
import 'package:courses_app/services/course_api.dart';
import 'package:courses_app/services/review_service.dart';
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
  final CourseApi _courseApi = CourseApi();
  final ReviewService _reviewService = ReviewService();
  List<Map<String, dynamic>> _relatedCourses = [];
  bool _isLoadingRelated = false;
  bool _isLoading = true;
  Map<String, dynamic>? _fullCourseData;
  ValueNotifier<double?> _userRating = ValueNotifier<double?>(null);
  Map<String, dynamic>? _ratingInfo;
  bool _isSubmittingRating = false;

  @override
  void initState() {
    super.initState();
    _loadCourseDetails();
  }

  Future<void> _loadCourseDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch course details
      final response = await _courseApi.getCourseDetails(widget.course['slug'] ?? widget.course['id']);
      if (response['course'] != null) {
        setState(() {
          _fullCourseData = response['course'];
        });
      }
      // Fetch related courses
      await _fetchRelatedCourses();
    } catch (e) {
      print('Error loading course details: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    if (widget.course['id'] == null) {
      widget.course['id'] = 'course_${DateTime.now().millisecondsSinceEpoch}';
    }
    _fetchRelatedCourses();
    _fetchFullCourseDetails();
    _fetchUserRating();
  }

  Future<void> _fetchFullCourseDetails() async {
    setState(() => _isLoadingCourse = true);
    
    try {
      final slug = widget.course['slug']?.toString() ?? widget.course['id']?.toString();
      if (slug == null || slug.isEmpty) return;
      
      final response = await _courseApi.getCourseDetails(slug);
      
      if (response['course'] != null) {
        setState(() {
          _fullCourseData = response['course'] as Map<String, dynamic>;
          _ratingInfo = response['rating_info'] as Map<String, dynamic>?;
        });
      }
    } catch (e) {
      print('Error fetching course details: $e');
    } finally {
      setState(() => _isLoadingCourse = false);
    }
  }

  Future<void> _fetchUserRating() async {
    try {
      final courseId = widget.course['id']?.toString();
      print('>>> FLUTTER: _fetchUserRating called, courseId=$courseId');
      if (courseId == null) {
        print('>>> FLUTTER: courseId is null, returning');
        return;
      }
      
      print('>>> FLUTTER: Calling reviewService.getMyRating($courseId)');
      final response = await _reviewService.getMyRating(courseId);
      print('>>> FLUTTER: Rating response: $response');
      
      if (response['rating'] != null) {
        _userRating.value = (response['rating'] as num).toDouble();
      }
    } catch (e) {
      print('>>> FLUTTER: Error fetching user rating: $e');
    }
  }

  Future<void> _submitRating(double rating) async {
    // Prevent double submission
    if (_isSubmittingRating) return;
    
    try {
      setState(() => _isSubmittingRating = true);
      
      final courseId = widget.course['id']?.toString();
      if (courseId == null) {
        setState(() => _isSubmittingRating = false);
        return;
      }
      
      print('>>> SUBMIT: Starting submission for rating $rating');
      
      final response = await _reviewService.rateCourse(
        courseId: courseId,
        rating: rating.toInt(),
      );
      
      print('>>> SUBMIT: API response: $response');
      
      if (response['success'] == true || response['message']?.toString().contains('success') == true) {
        // Immediately update local state - must check mounted after async
        if (!mounted) {
          print('>>> SUBMIT: Widget not mounted, returning');
          return;
        }
        
        print('>>> SUBMIT: Setting _userRating to $rating');
        _userRating.value = rating;
        print('>>> SUBMIT: _userRating is now ${_userRating.value}');
        
        // Show snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم حفظ تقييمك بنجاح! لا يمكنك تغييره لاحقاً.',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        
        // Re-fetch from API to confirm
        await _fetchUserRating();
        
        // Refresh course details
        await _fetchFullCourseDetails();
      } else {
        setState(() => _isSubmittingRating = false);
        print('>>> SUBMIT: API returned failure: ${response['message']}');
      }
    } catch (e) {
      print('Error submitting rating: $e');
      setState(() => _isSubmittingRating = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'فشل إرسال التقييم: $e',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Get merged course data (widget data + API data)
  Map<String, dynamic> get _courseData {
    if (_fullCourseData != null) {
      return {
        ...widget.course,
        ..._fullCourseData!,
        'sections': _fullCourseData!['sections'] ?? widget.course['sections'] ?? [],
        'userRating': _userRating ?? widget.course['userRating'] ?? 0.0,
      };
    }
    return {
      ...widget.course,
      'userRating': _userRating ?? widget.course['userRating'] ?? 0.0,
    };
  }

  Future<void> _fetchRelatedCourses() async {
    final categoryId = widget.course['category_id']?.toString();
    final currentCourseId = widget.course['id']?.toString();
    
    // If no category ID, use the category name to find related courses
    final categoryName = widget.course['category']?.toString();
    
    if ((categoryId == null || categoryId.isEmpty) && 
        (categoryName == null || categoryName.isEmpty)) {
      return;
    }

    setState(() {
      _isLoadingRelated = true;
    });

    try {
      // Fetch courses with same category (excluding current course)
      final response = await _courseApi.getPublicCourses(
        categoryId: categoryId,
        perPage: 10,
      );

      if (response['data'] != null) {
        final courses = (response['data'] as List)
            .where((c) => c['id'].toString() != currentCourseId)
            .take(5)
            .map((c) => _mapCourseData(c))
            .toList();

        if (mounted) {
          setState(() {
            _relatedCourses = courses;
          });
        }
      }
    } catch (e) {
      print('Error fetching related courses: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRelated = false;
        });
      }
    }
  }

  Map<String, dynamic> _mapCourseData(dynamic course) {
    final rawImage = (course['course_image_url'] ?? '').toString();
    String imageUrl = '';
    if (rawImage.isNotEmpty) {
      if (rawImage.startsWith('http')) {
        imageUrl = rawImage;
      } else {
        imageUrl = 'http://192.168.1.5:8000$rawImage';
      }
    }

    return {
      'id': course['id'] ?? '',
      'slug': course['slug'] ?? '',
      'title': course['title'] ?? '',
      'image': imageUrl,
      'teacher': course['instructor']?['name'] ?? 'مدرس',
      'instructor': course['instructor'],
      'category': course['category']?['name'] ?? 'عام',
      'category_id': course['category_id'],
      'rating': (course['rating'] ?? 0).toDouble(),
      'reviews': course['total_ratings'] ?? 0,
      'students': (course['total_students'] ?? 0).toString(),
      'duration': course['duration_hours'] ?? 0,
      'lessons': course['lessons_count'] ?? 0,
      'level': course['level'] ?? 'متوسط',
      'lastUpdated': course['updated_at'] ?? '2026',
      'price': course['price']?.toString() ?? '0',
      'description': course['description'] ?? '',
    };
  }

  List<Map<String, dynamic>> _getRelatedCourses() {
    return _relatedCourses.isNotEmpty 
        ? _relatedCourses 
        : [];
  }

  Widget _buildSkeletonLoading(bool isDarkMode) {
    return CustomScrollView(
      slivers: [
        // Course Header skeleton
        SliverAppBar(
          expandedHeight: 250,
          floating: false,
          pinned: true,
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.grey[300],
              child: Center(
                child: SkeletonContainer(
                  width: 80,
                  height: 80,
                  borderRadius: 40,
                  isLoading: true,
                ),
              ),
            ),
          ),
        ),
        // Course Info skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonContainer(
                  width: double.infinity,
                  height: 24,
                  borderRadius: 4,
                  isLoading: true,
                ),
                const SizedBox(height: 12),
                SkeletonContainer(
                  width: 150,
                  height: 16,
                  borderRadius: 4,
                  isLoading: true,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    SkeletonContainer(
                      width: 60,
                      height: 32,
                      borderRadius: 16,
                      isLoading: true,
                    ),
                    const SizedBox(width: 8),
                    SkeletonContainer(
                      width: 80,
                      height: 32,
                      borderRadius: 16,
                      isLoading: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Tabs skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: SkeletonContainer(
                    width: double.infinity,
                    height: 40,
                    borderRadius: 8,
                    isLoading: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SkeletonContainer(
                    width: double.infinity,
                    height: 40,
                    borderRadius: 8,
                    isLoading: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Content skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SkeletonContainer(
                  width: double.infinity,
                  height: 100,
                  borderRadius: 12,
                  isLoading: true,
                ),
                const SizedBox(height: 16),
                SkeletonContainer(
                  width: double.infinity,
                  height: 60,
                  borderRadius: 12,
                  isLoading: true,
                ),
              ],
            ),
          ),
        ),
        // Related courses skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: SkeletonContainer(
              width: 150,
              height: 24,
              borderRadius: 4,
              isLoading: true,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SkeletonCourseCard(isDarkMode: isDarkMode),
                );
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
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
          body: _isLoading
              ? _buildSkeletonLoading(isDarkMode)
              : BlocBuilder<CourseManagementBloc, CourseManagementState>(
            builder: (context, courseState) {
              final isEnrolled = courseState.enrolledCourses.any(
                (course) => course['id'] == widget.course['id'],
              );

              if (isEnrolled) {
                // Get enrolled course from state
                final enrolledCourse = courseState.enrolledCourses.firstWhere(
                  (course) => course['id'] == widget.course['id'],
                );
                // Merge enrolled course data with full API data
                final mergedCourse = {
                  ...enrolledCourse,
                  ..._courseData,
                  'sections': _courseData['sections'] ?? enrolledCourse['sections'] ?? [],
                };
                return _buildEnrolledCourseView(context, mergedCourse);
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
        CourseHeader(
          key: ValueKey('course_header_${widget.course['id']}'),
          course: _courseData,
        ),
        CourseInfoCard(
          key: ValueKey('course_info_${widget.course['id']}'),
          course: _courseData,
        ),
        CourseTabs(
          key: ValueKey('course_tabs_${widget.course['id']}'),
          course: _courseData,
        ),
        RelatedCourses(
          key: ValueKey('related_courses_${widget.course['id']}'),
          course: widget.course,
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
        EnrolledCourseHeader(
          key: ValueKey('enrolled_header_${widget.course['id']}'),
          course: enrolledCourse,
        ),
        CourseProgressWidget(
          key: ValueKey('course_progress_${widget.course['id']}'),
          course: enrolledCourse,
        ),
        SliverToBoxAdapter(
          key: ValueKey('rating_section_${widget.course['id']}'),
          child: _buildRatingSection(context, enrolledCourse),
        ),
        SliverToBoxAdapter(
          key: ValueKey('continue_button_${widget.course['id']}'),
          child: _buildContinueLearningButton(context, enrolledCourse),
        ),
        LessonsListWidget(
          key: ValueKey('lessons_list_${widget.course['id']}'),
          course: enrolledCourse,
          isEnrolled: true,
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildRatingSection(
    BuildContext context,
    Map<String, dynamic> course,
  ) {
    return ValueListenableBuilder<double?>(
      valueListenable: _userRating,
      builder: (context, userRatingValue, child) {
        final currentRating = userRatingValue ?? 0.0;
        final hasRated = currentRating > 0;
        
        print('>>> RATING SECTION: _userRating=$userRatingValue, currentRating=$currentRating, hasRated=$hasRated');

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
                        ? _buildMobileRatingLayout(
                            context,
                            course,
                            currentRating,
                            hasRated,
                            isDarkMode,
                          )
                        : _buildDesktopRatingLayout(
                            context,
                            course,
                            currentRating,
                            hasRated,
                            isDarkMode,
                          ),
                  ],
                ),
              ),
            );
          },
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
            if (hasRated) ...[
              // Show non-interactive stars with saved rating
              _buildStarRatingDisplay(currentRating),
            ] else ...[
              // Show interactive stars for rating
              _buildStarRating(
                currentRating,
                onRatingChanged: (rating) {
                  _userRating.value = rating;
                  _showRatingConfirmationDialog(context, rating);
                },
              ),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (hasRated) ...[
                    Text(
                      'لقد قيّمت هذه الدورة مسبقاً',
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'تقييمك: ${currentRating.toInt()}/5 نجوم',
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.amber,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ] else ...[
                    Text(
                      'كيف كانت تجربتك مع هذه الدورة؟',
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: isDarkMode ? Colors.white70 : Color(0xFF666666),
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
          Text(
            'اضغط على النجوم لتقييم الدورة',
            style: GoogleFonts.tajawal(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white60 : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
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
        if (hasRated) ...[
          // Show non-interactive stars with saved rating
          _buildStarRatingDisplay(currentRating),
        ] else ...[
          // Show interactive stars for rating
          _buildStarRating(
            currentRating,
            onRatingChanged: (rating) {
              _userRating.value = rating;
              _showRatingConfirmationDialog(context, rating);
            },
          ),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (hasRated) ...[
                Text(
                  'لقد قيّمت هذه الدورة مسبقاً',
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                Text(
                  'تقييمك: ${currentRating.toInt()}/5 نجوم',
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.amber,
                  ),
                  textAlign: TextAlign.right,
                ),
              ] else ...[
                Text(
                  'كيف كانت تجربتك مع هذه الدورة؟',
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: isDarkMode ? Colors.white70 : Color(0xFF666666),
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showRatingConfirmationDialog(BuildContext context, double rating) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.star,
              color: Colors.amber,
              size: 32,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'تأكيد التقييم',
                style: GoogleFonts.tajawal(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF333333),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'لقد قيّمت هذه الدورة بـ ${rating.toInt()}/5 نجوم. هل أنت متأكد؟',
          style: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'إلغاء',
              style: GoogleFonts.tajawal(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: _isSubmittingRating ? null : () {
                Navigator.of(dialogContext).pop();
                _submitRating(rating);
              },
              child: _isSubmittingRating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'تأكيد',
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
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

  Widget _buildStarRatingDisplay(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return Icon(
          starIndex <= rating
              ? Icons.star_rounded
              : Icons.star_border_rounded,
          color: Colors.amber,
          size: 32,
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
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [Color(0xFF4C1D95), Color(0xFF5B21B6)]
                      : [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Color(0xFF4C1D95).withOpacity(0.3)
                        : Color(0xFF667EEA).withOpacity(0.3),
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
      RateCourseEvent(courseId: courseId, rating: rating),
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
    // Get sections and find the lesson
    final sections = course['sections'] ?? [];
    String? lessonId;
    String? lessonTitle;
    String? lessonDescription;
    
    // Find lesson across all sections
    int currentIndex = 0;
    for (var section in sections) {
      final lessons = section['lessons'] ?? [];
      for (var lesson in lessons) {
        if (currentIndex == lessonIndex) {
          lessonId = lesson['id']?.toString();
          lessonTitle = lesson['title']?.toString();
          lessonDescription = lesson['description']?.toString();
          break;
        }
        currentIndex++;
      }
      if (lessonId != null) break;
    }
    
    // Navigate to video player
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerPage(
          courseSlug: course['slug']?.toString() ?? course['id']?.toString() ?? '',
          lessonId: lessonId ?? lessonIndex.toString(),
          lessonTitle: lessonTitle ?? 'المحاضرة ${lessonIndex + 1}',
          lessonDescription: lessonDescription,
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
}
