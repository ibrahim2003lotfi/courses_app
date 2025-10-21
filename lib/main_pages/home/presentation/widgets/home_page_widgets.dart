import 'package:courses_app/core/utils/theme_manager.dart';
import 'package:courses_app/data/notifiers.dart';
import 'package:courses_app/main_pages/courses/presentation/pages/course_details_page.dart';
import 'package:courses_app/main_pages/home/presentation/side%20pages/category_datail_page.dart';
import 'package:courses_app/main_pages/home/presentation/side%20pages/category_page.dart';
import 'package:courses_app/main_pages/home/presentation/side%20pages/university_pages/univiersities_page.dart';
import 'package:courses_app/main_pages/home/presentation/widgets/notifications_page.dart';
import 'package:courses_app/main_pages/search/presentation/pages/search_page.dart';
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
                  ? const Color(0xFF1E1E1E) // Use dark theme card color
                  : Colors.white, // Use light theme background
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
                      'assets/images/logo_ed.png', // Replace with your actual asset path
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
                              ? Colors
                                    .white // White text for dark mode
                              : const Color(
                                  0xFF1F2937,
                                ), // Original dark gray for light mode
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

  // Content for each slider
  final List<Map<String, dynamic>> _sliderContent = [
    {
      'title': 'كيفية استخدام برنامجنا 📚',
      'buttonText': 'تعرف على البرنامج',
      'description':
          'اكتشف كل الميزات والأدوات المتاحة لتحقيق أقصى استفادة من منصتنا التعليمية',
      'route': '/tutorial', // Replace with your actual tutorial page route
    },
    {
      'title': 'انضم إلى مجتمعنا التعليمي 👥',
      'buttonText': 'انضم الآن',
      'description':
          'تفاعل مع الطلاب والمدرسين وشارك في المناقشات لتعزيز تجربتك التعليمية',
      'route': '/community', // Replace with your actual community page route
    },
    {
      'title': 'خطط التعلم الشخصية 🎯',
      'buttonText': 'ابدأ التخطيط',
      'description': 'احصل على خطة تعلم مخصصة تناسب أهدافك ومستواك التعليمي',
      'route':
          '/learning-plan', // Replace with your actual learning plan page route
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
    // Replace this with your actual navigation logic
    // You can use Navigator.pushNamed or any other navigation method you prefer
    switch (route) {
      case '/tutorial':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchPage(),
          ), // Replace with your actual page
        );
        break;
      case '/community':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchPage(),
          ), // Replace with your actual page
        );
        break;
      case '/learning-plan':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchPage(),
          ), // Replace with your actual page
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

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SizedBox(
            height: 220, // Slightly increased height to accommodate description
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
                            Image.network(
                              widget.heroImages[index],
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: isDarkMode
                                          ? const Color(0xFF2D2D2D)
                                          : const Color(0xFFF3F4F6),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: isDarkMode
                                              ? Colors.white70
                                              : const Color(0xFF3B82F6),
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

        return Padding(
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
                        fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
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
                        context, // pass context here ✅
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
        );
      },
    );
  }

  Widget _buildCategoryCube(
    BuildContext context, // add context ✅
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

class RecommendedCourses extends StatelessWidget {
  final List<Map<String, dynamic>> recommended;

  const RecommendedCourses({super.key, required this.recommended});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final bool isDarkMode = themeState.isDarkMode;

        return Padding(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ), // Add padding to ListView
                  itemCount: recommended.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final item = recommended[index];
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
                  onTap: () {
                    Map<String, dynamic> enhancedCourse = {
                      ...item,
                      'category': item['category'] ?? 'برمجة',
                      'reviews': item['reviews'] ?? 100,
                      'duration': item['duration'] ?? 20,
                      'lessons': item['lessons'] ?? 30,
                      'level': item['level'] ?? 'متوسط',
                      'lastUpdated': item['lastUpdated'] ?? '2024',
                      'price': item['price'] ?? '200,000 S.P',
                      'description':
                          item['description'] ??
                          'دورة تعليمية شاملة تغطي أهم المفاهيم والمهارات في هذا المجال.',
                      'tags': item['tags'] ?? ['تعليم', 'تدريب', 'مهارات'],
                      'instructorImage':
                          item['instructorImage'] ??
                          'https://picsum.photos/seed/instructor/200/200',
                    };

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CourseDetailsPage(course: enhancedCourse),
                      ),
                    );
                  },
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

class TrendingCourses extends StatelessWidget {
  final List<Map<String, dynamic>> trending;

  const TrendingCourses({super.key, required this.trending});

  void _navigateToCourseDetails(BuildContext context, Map<String, dynamic> course) {
    try {
      // Create enhanced course data with all required fields
      Map<String, dynamic> enhancedCourse = {
        'title': course['title'] ?? 'دورة تعليمية',
        'image': course['image'] ?? 'https://picsum.photos/400/300',
        'teacher': course['teacher'] ?? 'مدرس متخصص',
        'category': course['category'] ?? 'برمجة',
        'rating': course['rating'] ?? 4.5,
        'reviews': course['reviews'] ?? 100,
        'students': course['students']?.toString() ?? '1,000',
        'duration': course['duration'] ?? 20,
        'lessons': course['lessons'] ?? 30,
        'level': course['level'] ?? 'متوسط',
        'lastUpdated': course['lastUpdated'] ?? '2024',
        'price': course['price'] ?? '200,000 S.P',
        'description': course['description'] ?? 'دورة تعليمية شاملة تغطي أهم المفاهيم والمهارات في هذا المجال.',
        'tags': course['tags'] ?? ['تعليم', 'تدريب', 'مهارات'],
        'instructorImage': course['instructorImage'] ?? 'https://picsum.photos/200/200',
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourseDetailsPage(course: enhancedCourse),
        ),
      );
    } catch (e) {
      print('Navigation error: $e');
      // Show error message or fallback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ في فتح تفاصيل الدورة'),
        ),
      );
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

        // Safe check for trending data
        final safeTrending = trending ?? [];
        if (safeTrending.isEmpty) {
          return Container(); // Return empty container if no data
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with padding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الأكثر شيوعًا',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onBackground,
                    ) ?? TextStyle(
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
                  final safeCourse = course ?? {};
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _navigateToCourseDetails(context, safeCourse),
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
        children: [
          // Image section - fixed width
          SizedBox(
            width: 100,
            height: 100, // Fixed height to match content
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(16),
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
                          color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                          size: 30,
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        course['price']?.toString() ?? '200,000 S.P',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
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
                      color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white70 : null,
              ) ?? TextStyle(
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white70 : null,
              ) ?? TextStyle(
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isDarkMode ? Colors.white60 : const Color(0xFF6B7280),
          ) ?? TextStyle(
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // University Lectures Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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

            // أفضل الأساتذة (بدلاً من أفضل المدربين)
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
                              color: theme
                                  .colorScheme
                                  .onSurface, // Use theme text color
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

            // باقي الأقسام زي ما هي (إنجازات - تحميل - نشرة بريدية)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Add your other sections here with theme adaptation
                  // Achievements, Download buttons, Newsletter...
                ],
              ),
            ),
          ],
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

        return Container(
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
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
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
                              icon: Icon(Icons.link_rounded, color: iconColor),
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
        );
      },
    );
  }
}
