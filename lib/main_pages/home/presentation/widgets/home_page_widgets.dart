import 'package:courses_app/core/utils/theme_manager.dart';
import 'package:courses_app/data/notifiers.dart';
import 'package:courses_app/main_pages/courses/presentation/pages/course_details_page.dart';
import 'package:courses_app/main_pages/home/presentation/side%20pages/category_datail_page.dart';
import 'package:courses_app/main_pages/home/presentation/side%20pages/category_page.dart';
import 'package:courses_app/main_pages/home/presentation/side%20pages/university_pages/univiersities_page.dart';
import 'package:courses_app/main_pages/home/presentation/widgets/notifications_page.dart';
import 'package:courses_app/main_pages/search/presentation/pages/search_page.dart';
import 'package:courses_app/services/course_api.dart';
import 'package:courses_app/theme_cubit/theme_cubit.dart';
import 'package:courses_app/theme_cubit/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class TopSearchBar extends StatelessWidget implements PreferredSizeWidget {
  const TopSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return SafeArea(
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: themeState.isDarkMode
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    themeState.isDarkMode ? 0.1 : 0.05,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/logo_ed.png',
                      width: 43,
                      height: 43,
                      fit: BoxFit.cover,
                    ),

                    const SizedBox(width: 12),

                    // Title text with theme-aware color
                    Expanded(
                      child: Text(
                        'منصة الكورسات',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.tajawal(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: themeState.isDarkMode
                              ? Colors.white
                              : const Color(0xFF1F2937),
                        ),
                      ),
                    ),

                    // Bell Icon
                    IconButton(
                      icon: Icon(
                        Icons.notifications_none,
                        color: themeState.isDarkMode
                            ? Colors.white
                            : const Color(0xFF1F2937),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final bool isDarkMode = themeState.isDarkMode;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Material(
            elevation: isDarkMode ? 1 : 2,
            borderRadius: BorderRadius.circular(16),
            shadowColor: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.1),
            child: InkWell(
              onTap: () {
                selectedPageNotifier.value = 1;
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(
                      Icons.search,
                      color: isDarkMode
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'ابحث عن الكورسات, المحاضرات, و الدروس',
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: isDarkMode
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF6B7280),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class HeroCarousel extends StatefulWidget {
  final List<String> heroImages;

  const HeroCarousel({super.key, required this.heroImages});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  final PageController _heroController = PageController();
  int _heroPage = 0;

  // Updated content for each slider based on your requirements
  final List<Map<String, dynamic>> _sliderContent = [
    {
      'title': 'تعرف على قسم الجامعات',
      'buttonText': 'انتقل الى قسم الجامعات',
      'description': 'اختر جامعتك لمتابعة أفضل الكورسات لشرح المواد الجامعية',
      'route': '/universities',
      'localImage': 'assets/images/dUni.jpg',
    },
    {
      'title': 'كيفية استخدام برنامجنا 📚',
      'buttonText': 'تعرف على البرنامج',
      'description':
          'اكتشف كل الميزات والأدوات المتاحة لتحقيق أقصى استفادة من منصتنا التعليمية',
      'route': '/tutorial',
    },
    {
      'title': 'كيفية الدفع داخل التطبيق',
      'buttonText': 'طرق الدفع في كورساتي',
      'description': 'تعرف على طرق الدفع المتاحة داخل تطبيق كورساتي',
      'route': '/payment-methods',
    },
  ];

  @override
  void initState() {
    super.initState();
    _heroController.addListener(() {
      final page = _heroController.page?.round() ?? 0;
      if (page != _heroPage) {
        setState(() {
          _heroPage = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  void _navigateToPage(String route) {
    switch (route) {
      case '/universities':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UniversitiesPage()),
        );
        break;
      case '/tutorial':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchPage()),
        );
        break;
      case '/payment-methods':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchPage()),
        );
        break;
      default:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CategoriesPage()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final bool isDarkMode = themeState.isDarkMode;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              height: 220,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _heroController,
                    itemCount: widget.heroImages.length,
                    itemBuilder: (context, index) {
                      final content = _sliderContent[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Use local image for first container, network for others
                              index == 0 && content['localImage'] != null
                                  ? Image.asset(
                                      content['localImage']!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Image.network(
                                              widget.heroImages[index],
                                              fit: BoxFit.cover,
                                            );
                                          },
                                    )
                                  : Image.network(
                                      widget.heroImages[index],
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Container(
                                              color: isDarkMode
                                                  ? const Color(0xFF2D2D2D)
                                                  : const Color(0xFFF3F4F6),
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      color: isDarkMode
                                                          ? Colors.white70
                                                          : const Color(
                                                              0xFF3B82F6,
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
                                      Colors.black.withOpacity(
                                        isDarkMode ? 0.8 : 0.6,
                                      ),
                                      Colors.black.withOpacity(
                                        isDarkMode ? 0.4 : 0.2,
                                      ),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ),
                              // Centered content
                              Positioned(
                                bottom: 48,
                                right: 0,
                                left: 0,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      content['title'],
                                      style: GoogleFonts.tajawal(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        height: 1.3,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      content['description'],
                                      style: GoogleFonts.tajawal(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 16),
                                    // Bigger centered button
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF667EEA),
                                            Color(0xFF764BA2),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              isDarkMode ? 0.4 : 0.2,
                                            ),
                                            blurRadius: isDarkMode ? 4 : 2,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          _navigateToPage(content['route']);
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 14,
                                          ),
                                          child: Center(
                                            child: Text(
                                              content['buttonText'],
                                              style: GoogleFonts.tajawal(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Dots positioned below the content
                  Positioned(
                    bottom: 16,
                    right: 0,
                    left: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(widget.heroImages.length, (i) {
                        final active = i == _heroPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active
                                ? Colors.white
                                : Colors.white.withOpacity(
                                    isDarkMode ? 0.7 : 0.5,
                                  ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  isDarkMode ? 0.3 : 0.1,
                                ),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CategoriesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> categories;

  const CategoriesGrid({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final bool isDarkMode = themeState.isDarkMode;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الأقسام',
                        style: GoogleFonts.tajawal(
                          fontSize: Theme.of(
                            context,
                          ).textTheme.titleLarge!.fontSize,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode ? Colors.white : null,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoriesPage(),
                            ),
                          );
                        },
                        child: Text(
                          'عرض الكل',
                          style: GoogleFonts.tajawal(
                            color: const Color(0xFF2563EB),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    const crossAxisCount = 4;
                    final visibleCategories = categories.take(8).toList();

                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: visibleCategories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                      itemBuilder: (context, idx) {
                        final c = visibleCategories[idx];
                        return _buildCategoryCube(
                          context,
                          c,
                          constraints.maxWidth / crossAxisCount - 16,
                          isDarkMode: isDarkMode,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryCube(
    BuildContext context,
    Map<String, dynamic> category,
    double itemSize, {
    required bool isDarkMode,
  }) {
    return Material(
      elevation: isDarkMode ? 4 : 3,
      borderRadius: BorderRadius.circular(16),
      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.transparent,
      shadowColor: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: category['gradient'] as List<Color>,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (category['gradient'] as List<Color>).last.withOpacity(
                isDarkMode ? 0.5 : 0.3,
              ),
              blurRadius: isDarkMode ? 12 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryDetailPage(category: category),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(isDarkMode ? 0.3 : 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: Colors.white,
                    size: itemSize * 0.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category['name'],
                  style: GoogleFonts.tajawal(
                    color: Colors.white,
                    fontSize: itemSize * 0.12,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RecommendedCourses extends StatefulWidget {
  final List<Map<String, dynamic>> recommended;

  const RecommendedCourses({super.key, required this.recommended});

  @override
  State<RecommendedCourses> createState() => _RecommendedCoursesState();
}

class _RecommendedCoursesState extends State<RecommendedCourses> {
  final CourseApi _courseApi = CourseApi();
  bool _isLoading = false;

  Future<void> _navigateToCourseDetails(
    BuildContext context,
    Map<String, dynamic> course,
  ) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Fetch full course details with sections and lessons
      Map<String, dynamic> fullCourseData = {};
      int totalDuration = 0;
      int totalLessons = 0;

      // Try to fetch course details using the course slug or id
      final slug = (course['slug']?.toString().isNotEmpty == true) 
          ? course['slug'] 
          : course['id'];
      print('DEBUG - Recommended Course slug/id: $slug');
      
      if (slug != null && slug.toString().isNotEmpty) {
        try {
          final response = await _courseApi.getCourseDetails(slug.toString());
          print('DEBUG - Recommended API Response: $response');
          
          // Handle different response formats
          if (response['course'] != null) {
            fullCourseData = response['course'] as Map<String, dynamic>;
          } else if (response['data'] != null) {
            fullCourseData = response['data'] as Map<String, dynamic>;
          } else if (response['id'] != null) {
            fullCourseData = response;
          }

          // Calculate total duration and lessons from sections
          final sections = fullCourseData['sections'] as List? ?? [];
          for (final section in sections) {
            final lessons = section['lessons'] as List? ?? [];
            totalLessons += lessons.length;
            for (final lesson in lessons) {
              final duration = lesson['duration'] as int? ?? 0;
              totalDuration += duration;
            }
          }
        } catch (e) {
          print('Error fetching recommended course details: $e');
        }
      }

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Convert duration from seconds to hours (round up)
      final durationHours = totalDuration > 0 ? (totalDuration / 3600).ceil() : 0;

      Map<String, dynamic> enhancedCourse = {
        'id': course['id'] ?? fullCourseData['id'] ?? '',
        'slug': course['slug'] ?? fullCourseData['slug'] ?? '',
        'title': course['title'] ?? fullCourseData['title'] ?? 'دورة تعليمية',
        'image': course['image'] ?? fullCourseData['course_image_url'] ?? 'https://picsum.photos/400/300',
        'teacher': course['teacher'] ?? fullCourseData['instructor']?['name'] ?? 'مدرس متخصص',
        'instructor': course['instructor'] ?? fullCourseData['instructor'],
        'category': fullCourseData['category']?['name'] ?? course['category'] ?? 'عام',
        'rating': course['rating'] ?? (fullCourseData['rating'] ?? 4.5).toDouble(),
        'reviews': fullCourseData['total_ratings'] ?? 0,
        'students': course['students']?.toString() ?? (fullCourseData['total_students'] ?? 0).toString(),
        'duration': durationHours > 0 ? durationHours : (fullCourseData['duration_hours'] ?? 0),
        'lessons': totalLessons > 0 ? totalLessons : (fullCourseData['lessons_count'] ?? 0),
        'level': fullCourseData['level'] ?? course['level'] ?? 'متوسط',
        'lastUpdated': fullCourseData['updated_at']?.toString().substring(0, 4) ?? '2026',
        'price': course['price'] ?? fullCourseData['price']?.toString() ?? '',
        'description': fullCourseData['description'] ?? course['description'] ?? '',
        'tags': fullCourseData['category']?['name'] != null ? [fullCourseData['category']['name']] : (course['tags'] ?? []),
        'instructorImage': fullCourseData['instructor']?['avatar'] ?? course['instructorImage'] ?? 'https://picsum.photos/200/200',
        'sections': fullCourseData['sections'] ?? [],
        'category_id': fullCourseData['category_id'] ?? course['category_id'],
      };

      setState(() {
        _isLoading = false;
      });

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailsPage(course: enhancedCourse),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Navigation error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('حدث خطأ في فتح تفاصيل الدورة')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final bool isDarkMode = themeState.isDarkMode;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with horizontal padding
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'مقترح لك',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDarkMode ? Colors.white : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // ListView with edge-to-edge scrolling but padding for first and last items
                SizedBox(
                  height: _calculateCardHeight(context),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: widget.recommended.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final item = widget.recommended[index];
                      final cardWidth = _calculateCardWidth(context);

                      return SizedBox(
                        width: cardWidth,
                        height: _calculateCardHeight(context),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF1E1E1E)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  isDarkMode ? 0.1 : 0.05,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _buildCourseCard(
                            context,
                            item,
                            cardWidth,
                            isDarkMode,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _calculateCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      return screenWidth * 0.75;
    } else if (screenWidth < 900) {
      return 300;
    } else {
      return 260;
    }
  }

  double _calculateCardHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      return 260;
    } else if (screenWidth < 900) {
      return 240;
    } else {
      return 220;
    }
  }

  Widget _buildCourseCard(
    BuildContext context,
    Map<String, dynamic> item,
    double cardWidth,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Course Image with taller aspect ratio
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: constraints.maxHeight * 0.5,
                  child: Image.network(
                    item['image'],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported,
                          color: isDarkMode
                              ? Colors.grey[600]
                              : Colors.grey[400],
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Course Title
              Flexible(
                child: Text(
                  item['title'],
                  style: GoogleFonts.tajawal(
                    fontSize: _calculateTitleFontSize(context),
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),

              // Teacher Name
              Text(
                item['teacher'],
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white70 : const Color(0xFF6B7280),
                  fontSize: _calculateSubtitleFontSize(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // Rating and Students Row
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text(
                    item['rating'].toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white70 : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.people_outline,
                    size: 14,
                    color: isDarkMode
                        ? Colors.white60
                        : const Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    _formatStudentCount(item['students']),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white70 : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Details Button
              Container(
                height: 38,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isDarkMode
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: InkWell(
                  onTap: _isLoading
                      ? null
                      : () => _navigateToCourseDetails(context, item),
                  borderRadius: BorderRadius.circular(8),
                  child: Center(
                    child: Text(
                      'التفاصيل',
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ignore: unused_element
  double _calculateImageHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      return 120;
    } else if (screenWidth < 900) {
      return 110;
    } else {
      return 100;
    }
  }

  double _calculateTitleFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      return 13;
    } else if (screenWidth < 900) {
      return 12;
    } else {
      return 11;
    }
  }

  double _calculateSubtitleFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      return 12;
    } else if (screenWidth < 900) {
      return 11;
    } else {
      return 10;
    }
  }

  String _formatStudentCount(dynamic students) {
    if (students is int) {
      if (students > 1000) {
        return '${(students / 1000).toStringAsFixed(1)}K';
      }
      return students.toString();
    }
    return students?.toString() ?? '0';
  }
}

class TrendingCourses extends StatefulWidget {
  final List<Map<String, dynamic>> trending;

  const TrendingCourses({super.key, required this.trending});

  @override
  State<TrendingCourses> createState() => _TrendingCoursesState();
}

class _TrendingCoursesState extends State<TrendingCourses> {
  final CourseApi _courseApi = CourseApi();
  bool _isLoading = false;

  String? _extractYear(dynamic dateValue) {
    if (dateValue == null) return null;
    try {
      final dateStr = dateValue.toString();
      // Try to extract year from ISO date format (2024-01-15T10:30:00.000000Z)
      if (dateStr.contains('T')) {
        return dateStr.split('T')[0].split('-')[0];
      }
      // Try to extract year from date format (2024-01-15)
      if (dateStr.contains('-')) {
        return dateStr.split('-')[0];
      }
      return dateStr;
    } catch (e) {
      return null;
    }
  }

  Future<void> _navigateToCourseDetails(
    BuildContext context,
    Map<String, dynamic> course,
  ) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Fetch full course details with sections and lessons
      Map<String, dynamic> fullCourseData = {};
      int totalDuration = 0;
      int totalLessons = 0;

      // Try to fetch course details using the course slug or id
      // Use slug if available and not empty, otherwise fall back to id
      final slug = (course['slug']?.toString().isNotEmpty == true) 
          ? course['slug'] 
          : course['id'];
      print('DEBUG - Course slug/id: $slug');
      print('DEBUG - Original course data: $course');
      
      if (slug != null && slug.toString().isNotEmpty) {
        try {
          final response = await _courseApi.getCourseDetails(slug.toString());
          print('DEBUG - API Response: $response');
          print('DEBUG - Response keys: ${response.keys.toList()}');
          
          // Handle different response formats
          // Backend returns: { 'course': {...}, 'rating_info': {...}, 'message': '...' }
          if (response['course'] != null) {
            // Response wrapped in 'course' key (standard backend format)
            fullCourseData = response['course'] as Map<String, dynamic>;
          } else if (response['data'] != null) {
            // Response wrapped in 'data' key
            fullCourseData = response['data'] as Map<String, dynamic>;
          } else if (response['id'] != null) {
            // Response is the course object directly
            fullCourseData = response;
          }

          // Calculate total duration and lessons from sections
          final sections = fullCourseData['sections'] as List? ?? [];
          for (final section in sections) {
            final lessons = section['lessons'] as List? ?? [];
            totalLessons += lessons.length;
            for (final lesson in lessons) {
              final duration = lesson['duration'] as int? ?? 0;
              totalDuration += duration;
            }
          }
        } catch (e) {
          print('Error fetching course details: $e');
        }
      }

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Convert duration from seconds to hours (round up)
      final durationHours = totalDuration > 0 ? (totalDuration / 3600).ceil() : 0;

      Map<String, dynamic> enhancedCourse = {
        'id': course['id'] ?? fullCourseData['id'] ?? '',
        'slug': course['slug'] ?? fullCourseData['slug'] ?? '',
        'title': course['title'] ?? fullCourseData['title'] ?? 'دورة تعليمية',
        'image': course['image'] ?? fullCourseData['course_image_url'] ?? 'https://picsum.photos/400/300',
        'teacher': course['teacher'] ?? fullCourseData['instructor']?['name'] ?? 'مدرس متخصص',
        'instructor': course['instructor'] ?? fullCourseData['instructor'],
        'category': fullCourseData['category']?['name'] ?? course['category'] ?? 'عام',
        'rating': course['rating'] ?? (fullCourseData['rating'] ?? 4.5).toDouble(),
        'reviews': fullCourseData['total_ratings'] ?? 0,
        'students': course['students']?.toString() ?? (fullCourseData['total_students'] ?? 0).toString(),
        'duration': durationHours > 0 ? durationHours : (fullCourseData['duration_hours'] ?? 0),
        'lessons': totalLessons > 0 ? totalLessons : (fullCourseData['lessons_count'] ?? 0),
        'level': fullCourseData['level'] ?? course['level'] ?? 'متوسط',
        'lastUpdated': fullCourseData['updated_at']?.toString().substring(0, 4) ?? '2026',
        'price': course['price'] ?? fullCourseData['price']?.toString() ?? '',
        'description': fullCourseData['description'] ?? course['description'] ?? '',
        'tags': fullCourseData['category']?['name'] != null ? [fullCourseData['category']['name']] : (course['tags'] ?? []),
        'instructorImage': fullCourseData['instructor']?['avatar'] ?? course['instructorImage'] ?? 'https://picsum.photos/200/200',
        'sections': fullCourseData['sections'] ?? [],
        'category_id': fullCourseData['category_id'] ?? course['category_id'],
      };

      // Debug logging
      print('DEBUG - Full course data from API: $fullCourseData');
      print('DEBUG - Level from API: ${fullCourseData['level']}');
      print('DEBUG - Updated at from API: ${fullCourseData['updated_at']}');
      print('DEBUG - Sections from API: ${fullCourseData['sections']}');
      print('DEBUG - Enhanced course level: ${enhancedCourse['level']}');
      print('DEBUG - Enhanced course lastUpdated: ${enhancedCourse['lastUpdated']}');
      print('DEBUG - Enhanced course sections count: ${(enhancedCourse['sections'] as List?)?.length ?? 0}');

      setState(() {
        _isLoading = false;
      });

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailsPage(course: enhancedCourse),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Navigation error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('حدث خطأ في فتح تفاصيل الدورة')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        final theme = isDarkMode
            ? ThemeManager.darkTheme
            : ThemeManager.lightTheme;

        final safeTrending = widget.trending;
        if (safeTrending.isEmpty) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Text(
                      'الأكثر شيوعًا',
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onBackground,
                          ) ??
                          TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onBackground,
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'لا يوجد كورسات شائعة حاليا',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row with padding
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الأكثر شيوعًا',
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onBackground,
                          ) ??
                          TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onBackground,
                          ),
                    ),
                  ],
                ),
              ),

              // Vertical courses list
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: safeTrending.map((course) {
                    final safeCourse = course;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: _isLoading
                            ? null
                            : () => _navigateToCourseDetails(context, safeCourse),
                        borderRadius: BorderRadius.circular(16),
                        child: _buildVerticalCourseCard(
                          context,
                          safeCourse,
                          theme,
                          isDarkMode,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Vertical course card layout
  Widget _buildVerticalCourseCard(
    BuildContext context,
    Map<String, dynamic> course,
    ThemeData theme,
    bool isDarkMode,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.1 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          // Image section - fixed width
          SizedBox(
            width: 100,
            height: 100,
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
                right: Radius.circular(0),
              ),
              child: Stack(
                children: [
                  Image.network(
                    course['image'] ?? 'https://picsum.photos/400/300',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported,
                          color: isDarkMode
                              ? Colors.grey[600]
                              : Colors.grey[400],
                          size: 30,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Content section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title
                  Text(
                    course['title']?.toString() ?? 'دورة تعليمية',
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode
                          ? Colors.white
                          : const Color(0xFF1F2937),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Course info
                  _buildCourseInfo(context, course, isDarkMode),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseInfo(
    BuildContext context,
    Map<String, dynamic> course,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rating and students
        Row(
          children: [
            const Icon(Icons.star, size: 14, color: Colors.amber),
            const SizedBox(width: 2),
            Text(
              (course['rating'] ?? 4.5).toString(),
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : null,
                  ) ??
                  TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : Colors.black,
                  ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.people_outline,
              size: 14,
              color: isDarkMode ? Colors.white60 : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 2),
            Text(
              course['students']?.toString() ?? '1000',
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : null,
                  ) ??
                  TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : Colors.black,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Teacher name
        Text(
          course['teacher']?.toString() ?? 'مدرس متخصص',
          style:
              Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDarkMode ? Colors.white60 : const Color(0xFF6B7280),
              ) ??
              TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white60 : const Color(0xFF6B7280),
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class ContinueLearning extends StatefulWidget {
  final List<Map<String, dynamic>> courses;

  const ContinueLearning({super.key, required this.courses});

  @override
  State<ContinueLearning> createState() => _ContinueLearningState();
}

class _ContinueLearningState extends State<ContinueLearning> {
  final CourseApi _courseApi = CourseApi();
  bool _isLoading = false;

  Future<void> _navigateToCourseDetails(
    BuildContext context,
    Map<String, dynamic> course,
  ) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Fetch full course details with sections and lessons
      Map<String, dynamic> fullCourseData = {};
      int totalDuration = 0;
      int totalLessons = 0;

      // Try to fetch course details using the course slug or id
      final slug = (course['slug']?.toString().isNotEmpty == true) 
          ? course['slug'] 
          : course['id'];
      print('DEBUG - Continue Learning Course slug/id: $slug');
      
      if (slug != null && slug.toString().isNotEmpty) {
        try {
          final response = await _courseApi.getCourseDetails(slug.toString());
          print('DEBUG - Continue Learning API Response: $response');
          
          // Handle different response formats
          if (response['course'] != null) {
            fullCourseData = response['course'] as Map<String, dynamic>;
          } else if (response['data'] != null) {
            fullCourseData = response['data'] as Map<String, dynamic>;
          } else if (response['id'] != null) {
            fullCourseData = response;
          }

          // Calculate total duration and lessons from sections
          final sections = fullCourseData['sections'] as List? ?? [];
          for (final section in sections) {
            final lessons = section['lessons'] as List? ?? [];
            totalLessons += lessons.length;
            for (final lesson in lessons) {
              final duration = lesson['duration'] as int? ?? 0;
              totalDuration += duration;
            }
          }
        } catch (e) {
          print('Error fetching continue learning course details: $e');
        }
      }

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Convert duration from seconds to hours (round up)
      final durationHours = totalDuration > 0 ? (totalDuration / 3600).ceil() : 0;

      Map<String, dynamic> enhancedCourse = {
        'id': course['id'] ?? fullCourseData['id'] ?? '',
        'slug': course['slug'] ?? fullCourseData['slug'] ?? '',
        'title': course['title'] ?? fullCourseData['title'] ?? 'دورة تعليمية',
        'image': course['course_image_url'] ?? fullCourseData['course_image_url'] ?? 'https://picsum.photos/400/300',
        'teacher': course['instructor']?['name'] ?? fullCourseData['instructor']?['name'] ?? 'مدرس متخصص',
        'instructor': course['instructor'] ?? fullCourseData['instructor'],
        'category': fullCourseData['category']?['name'] ?? course['category']?['name'] ?? 'عام',
        'rating': course['rating'] ?? (fullCourseData['rating'] ?? 4.5).toDouble(),
        'reviews': fullCourseData['total_ratings'] ?? 0,
        'students': course['students']?.toString() ?? (fullCourseData['total_students'] ?? 0).toString(),
        'duration': durationHours > 0 ? durationHours : (fullCourseData['duration_hours'] ?? 0),
        'lessons': totalLessons > 0 ? totalLessons : (fullCourseData['lessons_count'] ?? 0),
        'level': fullCourseData['level'] ?? course['level'] ?? 'متوسط',
        'lastUpdated': fullCourseData['updated_at']?.toString().substring(0, 4) ?? '2026',
        'price': course['price'] ?? fullCourseData['price']?.toString() ?? '',
        'description': fullCourseData['description'] ?? course['description'] ?? '',
        'tags': fullCourseData['category']?['name'] != null ? [fullCourseData['category']['name']] : (course['tags'] ?? []),
        'instructorImage': fullCourseData['instructor']?['avatar'] ?? course['instructorImage'] ?? 'https://picsum.photos/200/200',
        'sections': fullCourseData['sections'] ?? [],
        'category_id': fullCourseData['category_id'] ?? course['category_id'],
      };

      setState(() {
        _isLoading = false;
      });

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailsPage(course: enhancedCourse),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Navigation error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('حدث خطأ في فتح تفاصيل الدورة')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final bool isDarkMode = themeState.isDarkMode;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with horizontal padding
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'أكمل التعلم',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDarkMode ? Colors.white : null,
                        ),
                      ),
                      Icon(
                        Icons.play_circle_fill,
                        color: const Color(0xFF667EEA),
                        size: 28,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // ListView with enrolled courses or empty message
                widget.courses.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'لا توجد كورسات مسجلة',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 180,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: widget.courses.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final course = widget.courses[index];
                            return _buildCourseCard(context, course, isDarkMode);
                          },
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCourseCard(
    BuildContext context,
    Map<String, dynamic> course,
    bool isDarkMode,
  ) {
    final imageUrl = course['course_image_url'] ?? '';
    final hasValidImage = imageUrl.isNotEmpty && imageUrl.startsWith('http');
    
    return SizedBox(
      width: 280,
      child: GestureDetector(
        onTap: _isLoading ? null : () => _navigateToCourseDetails(context, course),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.1 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Background Image
                if (hasValidImage)
                  Positioned.fill(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                          child: Icon(
                            Icons.image_not_supported,
                            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                            size: 40,
                          ),
                        );
                      },
                    ),
                  )
                else
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                // Gradient overlay for text readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.black.withOpacity(0.3),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        course['title'] ?? 'دورة تعليمية',
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            course['category'] ?? 'عام',
                            style: GoogleFonts.tajawal(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Continue button
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF667EEA),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.play_arrow,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'أكمل المشاهدة',
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
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
    );
  }
}

class ExtrasSection extends StatelessWidget {
  const ExtrasSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        final theme = isDarkMode
            ? ThemeManager.darkTheme
            : ThemeManager.lightTheme;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // University Lectures Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // الكتابة مع الأيقونة في السطر الأول
                      Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          const Icon(
                            Icons.school_outlined,
                            size: 40,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'طور مهاراتك الجامعية',
                                  style: GoogleFonts.tajawal(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'محاضرات ومواد دراسية متقدمة',
                                  style: GoogleFonts.tajawal(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // الزر في السطر الثاني
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UniversitiesPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF667EEA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(double.infinity, 48),
                          elevation: isDarkMode ? 4 : 2,
                          shadowColor: Colors.black.withOpacity(
                            isDarkMode ? 0.3 : 0.1,
                          ),
                        ),
                        child: Text(
                          'عرض المحاضرات',
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // أفضل الأساتذة
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'أفضل الأساتذة',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: 6,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    return SizedBox(
                      width: 80,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFF59E0B,
                                  ).withOpacity(isDarkMode ? 0.4 : 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(2),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundImage: NetworkImage(
                                'https://picsum.photos/seed/professor${i}/100/100',
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Text(
                              'د. أحمد ${i + 1}',
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // باقي الأقسام
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Add your other sections here with theme adaptation
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        final theme = isDarkMode
            ? ThemeManager.darkTheme
            : ThemeManager.lightTheme;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              gradient: isDarkMode
                  ? const LinearGradient(
                      colors: [Color(0xFF1F2937), Color(0xFF111827)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : LinearGradient(
                      colors: [
                        theme.primaryColor.withOpacity(0.1),
                        theme.scaffoldBackgroundColor,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
              color: isDarkMode ? null : theme.scaffoldBackgroundColor,
            ),
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              children: [
                // Responsive layout for main content
                LayoutBuilder(
                  builder: (context, constraints) {
                    final textColor = isDarkMode
                        ? Colors.white
                        : theme.colorScheme.onBackground;
                    final textSecondaryColor = isDarkMode
                        ? Colors.white70
                        : theme.colorScheme.onSurface.withOpacity(0.8);

                    if (constraints.maxWidth < 600) {
                      // Mobile layout - vertical
                      return Column(
                        children: [
                          // Logo and description
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF2563EB),
                                          Color(0xFF1D4ED8),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.school,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'منصة الكورسات',
                                    style: GoogleFonts.tajawal(
                                      color: textColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'منصة تعليمية رائدة تقدم أفضل الكورسات بأعلى جودة وبأسعار مناسبة',
                                style: GoogleFonts.tajawal(
                                  color: textSecondaryColor,
                                  fontSize: 14,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Quick links
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'روابط سريعة',
                                style: GoogleFonts.tajawal(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                children: [
                                  TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      'عن المنصة',
                                      style: GoogleFonts.tajawal(
                                        color: textSecondaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      'تواصل معنا',
                                      style: GoogleFonts.tajawal(
                                        color: textSecondaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      // Desktop layout - horizontal
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: TextDirection.rtl,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF2563EB),
                                            Color(0xFF1D4ED8),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: const Icon(
                                        Icons.school,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'منصة الكورسات',
                                      style: GoogleFonts.tajawal(
                                        color: textColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'منصة تعليمية رائدة تقدم أفضل الكورسات\nبأعلى جودة وبأسعار مناسبة',
                                  style: GoogleFonts.tajawal(
                                    color: textSecondaryColor,
                                    fontSize: 14,
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 40),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'روابط سريعة',
                                style: GoogleFonts.tajawal(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      'عن المنصة',
                                      style: GoogleFonts.tajawal(
                                        color: textSecondaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      "تواصل معنا",
                                      style: GoogleFonts.tajawal(
                                        color: textSecondaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 32),
                Divider(color: isDarkMode ? Colors.white12 : Colors.black12),
                const SizedBox(height: 20),
                // Bottom section with copyright and social icons
                LayoutBuilder(
                  builder: (context, constraints) {
                    final textColor = isDarkMode
                        ? Colors.white70
                        : theme.colorScheme.onSurface.withOpacity(0.8);
                    final iconColor = isDarkMode
                        ? Colors.white70
                        : theme.colorScheme.onSurface.withOpacity(0.7);

                    if (constraints.maxWidth < 600) {
                      // Mobile layout - vertical
                      return Column(
                        children: [
                          Text(
                            '© 2025 منصة الكورسات. جميع الحقوق محفوظة',
                            style: GoogleFonts.tajawal(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Instagram
                              IconButton(
                                onPressed: () {},
                                icon: FaIcon(
                                  FontAwesomeIcons.instagram,
                                  color: iconColor,
                                ),
                              ),
                              // LinkedIn
                              IconButton(
                                onPressed: () {},
                                icon: FaIcon(
                                  FontAwesomeIcons.linkedin,
                                  color: iconColor,
                                ),
                              ),
                              // Email
                              IconButton(
                                onPressed: () {},
                                icon: FaIcon(
                                  FontAwesomeIcons.envelope,
                                  color: iconColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      // Desktop layout - horizontal
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        textDirection: TextDirection.rtl,
                        children: [
                          Text(
                            '© 2025 منصة الكورسات. جميع الحقوق محفوظة',
                            style: GoogleFonts.tajawal(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.facebook, color: iconColor),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.link_rounded,
                                  color: iconColor,
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.alternate_email,
                                  color: iconColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
